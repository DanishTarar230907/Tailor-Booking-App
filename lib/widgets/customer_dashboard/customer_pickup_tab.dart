import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pickup_request.dart';
import '../../services/firestore_pickup_requests_service.dart';
import '../../utils/app_validators.dart';

class CustomerPickupTab extends StatefulWidget {
  final List<PickupRequest> pickupRequests;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final VoidCallback onRefresh;

  const CustomerPickupTab({
    super.key,
    required this.pickupRequests,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.onRefresh,
  });

  @override
  State<CustomerPickupTab> createState() => _CustomerPickupTabState();
}

class _CustomerPickupTabState extends State<CustomerPickupTab> with SingleTickerProviderStateMixin {
  final FirestorePickupRequestsService _pickupService = FirestorePickupRequestsService();
  final _pickupAddressController = TextEditingController();
  final _pickupNotesController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _riderPhoneController = TextEditingController();
  final _parcelDescriptionController = TextEditingController();
  
  String _pickupType = 'courier_pickup';
  String _deliveryMethod = 'courier'; // 'courier' or 'bykea'
  DateTime? _expectedDeliveryDate;
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _pickupNotesController.dispose();
    _trackingNumberController.dispose();
    _riderPhoneController.dispose();
    _parcelDescriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickExpectedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _expectedDeliveryDate = date);
    }
  }

  Future<void> _submitPickupRequest() async {
    // Delivery method specific validation for Date (not covered by Form field easily)
    if (_deliveryMethod == 'courier' && _expectedDeliveryDate == null) {
      _showError('Please select an expected delivery date');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      String? notes = _pickupNotesController.text.isNotEmpty 
          ? _pickupNotesController.text 
          : null;
      
      // Add delivery method specific info to notes
      if (_deliveryMethod == 'bykea') {
        final parcelInfo = 'Parcel: ${_parcelDescriptionController.text}';
        final riderInfo = 'Bykea Rider Phone: ${_riderPhoneController.text}';
        notes = [notes, parcelInfo, riderInfo].where((e) => e != null).join('\n');
      }

      final request = PickupRequest(
        customerName: widget.customerName ?? 'Anonymous',
        customerEmail: widget.customerEmail ?? '',
        customerPhone: widget.customerPhone ?? '',
        pickupAddress: _pickupAddressController.text,
        requestType: _pickupType,
        status: 'pending',
        charges: _pickupType == 'courier_pickup' ? 15.0 : 0.0,
        requestedDate: DateTime.now(),
        expectedDeliveryDate: _deliveryMethod == 'courier' 
            ? _expectedDeliveryDate 
            : DateTime.now().add(const Duration(hours: 4)), // Bykea same day
        trackingNumber: _deliveryMethod == 'courier' ? _trackingNumberController.text : null,
        courierName: _deliveryMethod == 'courier' ? 'Courier' : 'Bykea',
        description: _deliveryMethod == 'bykea' ? _parcelDescriptionController.text : null,
        notes: notes,
      );

      await _pickupService.addRequest(request);
      
      // Clear all fields
      _pickupAddressController.clear();
      _pickupNotesController.clear();
      _trackingNumberController.clear();
      _riderPhoneController.clear();
      _parcelDescriptionController.clear();
      setState(() {
        _pickupType = 'courier_pickup';
        _deliveryMethod = 'courier';
        _expectedDeliveryDate = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Pickup request submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      _showError('Error submitting request: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved':
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.pending;
      case 'approved':
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'completed': return Icons.done_all;
      default: return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

   Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.7 + (0.3 * animValue),
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(
              label, 
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statusStep(String label, bool isActive, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? color : Colors.grey),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? color : Colors.grey)),
      ],
    );
  }

  Widget _buildDeliveryMethodCard(String method, String title, String description, IconData icon, Color color) {
    final isSelected = _deliveryMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ] : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? color : Colors.grey[600], size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[800],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPickupCard(PickupRequest request) {
     return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: _getStatusColor(request.status), width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Text(
                request.requestType == 'sewing_request' ? 'Sewing Request' : 'Pickup Request',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (request.courierName != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: request.courierName == 'Bykea' ? Colors.teal[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    request.courierName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: request.courierName == 'Bykea' ? Colors.teal[700] : Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text('Status: ${request.status.toUpperCase()}'),
          leading: CircleAvatar(
             backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
             child: Icon(_getStatusIcon(request.status), color: _getStatusColor(request.status)),
          ),
          children: [
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _detailRow('Date', _formatDate(request.requestedDate)),
                   if (request.expectedDeliveryDate != null)
                     _detailRow('Expected', _formatDate(request.expectedDeliveryDate!)),
                   if (request.trackingNumber != null && request.trackingNumber!.isNotEmpty)
                     _detailRow('Tracking', request.trackingNumber!),
                   _detailRow('Charges', '\$${request.charges.toStringAsFixed(2)}'),
                   if (request.description != null && request.description!.isNotEmpty)
                     _detailRow('Parcel', request.description!),
                   if (request.notes != null) _detailRow('Notes', request.notes!),
                   const Divider(height: 24),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       _statusStep('Pending', request.status == 'pending' || request.status == 'accepted' || request.status == 'completed', Colors.orange),
                       _statusStep('Accepted', request.status == 'accepted' || request.status == 'completed', Colors.blue),
                       _statusStep('Received', request.status == 'completed', Colors.green),
                     ],
                   ),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int pending = widget.pickupRequests.where((r) => r.status == 'pending').length;
    int accepted = widget.pickupRequests.where((r) => r.status == 'accepted').length;
    int completed = widget.pickupRequests.where((r) => r.status == 'completed').length;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pickup & Delivery',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your incoming parcels',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Pending', pending.toString(), Icons.pending, Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Accepted', accepted.toString(), Icons.check_circle_outline, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Received', completed.toString(), Icons.home_filled, Colors.green)),
              ],
            ),

            const SizedBox(height: 24),

            // Request Form
            Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
               ),
               child: Form(
                 key: _formKey,
                 child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.indigo.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: const Icon(Icons.add_box, color: Colors.indigo, size: 20),
                       ),
                       const SizedBox(width: 12),
                       const Text('New Pickup Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   
                   const SizedBox(height: 20),
                   
                   // Delivery Method Selection
                   const Text('Delivery Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                   const SizedBox(height: 12),
                   Row(
                     children: [
                       Expanded(
                         child: _buildDeliveryMethodCard(
                           'courier',
                           'Courier',
                           'TCS, Leopards, etc.',
                           Icons.local_post_office,
                           Colors.blue,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: _buildDeliveryMethodCard(
                           'bykea',
                           'Bykea',
                           'Same day delivery',
                           Icons.two_wheeler,
                           Colors.teal,
                         ),
                       ),
                     ],
                   ),
                   
                   const SizedBox(height: 20),
                   
                   // Request Type
                   DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Request Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: const Icon(Icons.category, color: Colors.grey),
                    ),
                    value: _pickupType,
                    items: const [
                      DropdownMenuItem(value: 'courier_pickup', child: Text('Courier Pickup (Sending Fabric)')),
                      DropdownMenuItem(value: 'sewing_request', child: Text('Sewing Request')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _pickupType = v);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pickup Address
                  TextFormField(
                    controller: _pickupAddressController,
                    validator: (v) => AppValidators.validateRequired(v, 'Address'),
                    decoration: InputDecoration(
                      labelText: 'Pickup Address *',
                      hintText: 'Where should we pick up from?',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.grey[50],
                       prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Conditional Fields based on delivery method
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _deliveryMethod == 'courier' 
                        ? CrossFadeState.showFirst 
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        // Courier Fields
                        TextFormField(
                          controller: _trackingNumberController,
                          validator: (v) => _deliveryMethod == 'courier' ? AppValidators.validateRequired(v, 'Tracking Number') : null,
                          decoration: InputDecoration(
                            labelText: 'Tracking Number *',
                            hintText: 'Enter parcel tracking number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.qr_code, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickExpectedDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _expectedDeliveryDate == null 
                                        ? 'Select Expected Delivery Date *'
                                        : 'Expected: ${_formatDate(_expectedDeliveryDate!)}',
                                    style: TextStyle(
                                      color: _expectedDeliveryDate == null ? Colors.grey[600] : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    secondChild: Column(
                      children: [
                        // Bykea Fields
                        TextFormField(
                          controller: _riderPhoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) => _deliveryMethod == 'bykea' ? AppValidators.validatePhone(v) : null,
                          decoration: InputDecoration(
                            labelText: 'Bykea Rider Phone *',
                            hintText: '03XX XXXXXXX',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.phone_android, color: Colors.teal),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _parcelDescriptionController,
                          maxLines: 2,
                          validator: (v) => _deliveryMethod == 'bykea' ? AppValidators.validateRequired(v, 'Description') : null,
                          decoration: InputDecoration(
                            labelText: 'Parcel Description *',
                            hintText: 'e.g., 3-piece suit fabric, white shirt cloth',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.inventory_2, color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _pickupNotesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      hintText: 'Any special instructions...',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       filled: true,
                       fillColor: Colors.grey[50],
                       prefixIcon: const Icon(Icons.note, color: Colors.grey),
                    ),
                  ),
                  
                   const SizedBox(height: 20),
                   
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _submitPickupRequest,
                       style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         backgroundColor: _deliveryMethod == 'courier' ? Colors.indigo : Colors.teal,
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         elevation: 4,
                         shadowColor: (_deliveryMethod == 'courier' ? Colors.indigo : Colors.teal).withOpacity(0.4),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(_deliveryMethod == 'courier' ? Icons.local_shipping : Icons.two_wheeler),
                           const SizedBox(width: 8),
                           const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                   ),
                 ],
               ),
               ),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.history, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                const Text('Request History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            if (widget.pickupRequests.isEmpty)
               _buildEmptyState('No pickup history', 'Your requests will appear here', Icons.history)
            else
              Column(
                children: widget.pickupRequests.map((request) => _buildEnhancedPickupCard(request)).toList(),
              ),
              
          ],
        ),
      ),
    );
  }
}
