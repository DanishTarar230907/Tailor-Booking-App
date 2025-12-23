import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pickup_request.dart' as models;
import '../services/firestore_pickup_requests_service.dart';

class TailorPickupRequestsTab extends StatefulWidget {
  const TailorPickupRequestsTab({super.key});

  @override
  State<TailorPickupRequestsTab> createState() => _TailorPickupRequestsTabState();
}

class _TailorPickupRequestsTabState extends State<TailorPickupRequestsTab> {
  final FirestorePickupRequestsService _pickupService =
      FirestorePickupRequestsService();
  List<models.PickupRequest> _requests = [];
  String _filterStatus = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _pickupService.getAllRequests();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pickup requests: $e');
      setState(() => _isLoading = false);
    }
  }

  List<models.PickupRequest> get _filteredRequests {
    if (_filterStatus == 'all') return _requests;
    return _requests.where((r) => r.status == _filterStatus).toList();
  }

  Future<void> _updateRequestStatus(models.PickupRequest request, String status) async {
    try {
      final updated = request.copyWith(
        status: status,
        completedDate: status == 'completed' ? DateTime.now() : request.completedDate,
      );
      await _pickupService.updateRequest(updated);
      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${status} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pickup Requests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadRequests,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('pending', 'Pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('accepted', 'Accepted'),
                    const SizedBox(width: 8),
                    _buildFilterChip('completed', 'Completed'),
                    const SizedBox(width: 8),
                    _buildFilterChip('rejected', 'Rejected'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRequests.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No pickup requests',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRequests.length,
                        itemBuilder: (context, index) {
                          final request = _filteredRequests[index];
                          return _buildRequestCard(request);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = status);
      },
      selectedColor: Colors.blue[200],
    );
  }

  Widget _buildRequestCard(models.PickupRequest request) {
    final statusColor = _getStatusColor(request.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.customerEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: request.requestType == 'sewing_request'
                              ? Colors.orange[100]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          request.requestType == 'sewing_request'
                              ? 'Sewing Request'
                              : 'Manual Pickup',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: request.requestType == 'sewing_request'
                                ? Colors.orange[900]
                                : Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    request.status == 'pending'
                        ? Icons.pending
                        : request.status == 'accepted'
                            ? Icons.check_circle
                            : request.status == 'completed'
                                ? Icons.done_all
                                : Icons.cancel,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.pickupAddress,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Requested: ${DateFormat('MMM d, yyyy').format(request.requestedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (request.trackingNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Tracking: ${request.trackingNumber}'),
                ],
              ),
            ],
            if (request.courierName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Courier: ${request.courierName}'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Charges: \$${request.charges.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (request.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _updateRequestStatus(request, 'rejected'),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Reject'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updateRequestStatus(request, 'accepted'),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ] else if (request.status == 'accepted') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateRequestStatus(request, 'completed'),
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark as Completed'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

