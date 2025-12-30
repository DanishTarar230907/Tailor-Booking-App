import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/measurement.dart';
import '../../models/measurement_request.dart'; 
import '../../models/tailor.dart';
import '../../services/firestore_measurements_service.dart';
import '../../services/firestore_measurement_requests_service.dart';
import '../status_badge.dart';
import '../request_measurement_dialog.dart';
import '../measurement_receipt.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class CustomerMeasurementsTab extends StatefulWidget {
  final Tailor? tailor;
  final Measurement? measurement;
  final List<MeasurementRequest> measurementRequests;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final Function(Measurement) onUpdateMeasurement;

  const CustomerMeasurementsTab({
    super.key,
    required this.tailor,
    required this.measurement,
    required this.measurementRequests,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.onUpdateMeasurement,
  });

  @override
  State<CustomerMeasurementsTab> createState() => _CustomerMeasurementsTabState();
}

class _CustomerMeasurementsTabState extends State<CustomerMeasurementsTab> {
  final FirestoreMeasurementsService _measurementsService = FirestoreMeasurementsService();
  final FirestoreMeasurementRequestsService _requestsService = FirestoreMeasurementRequestsService();
  final AuthService _authService = AuthService();

  void _showRequestMeasurementDialog() {
    showDialog(
      context: context,
      builder: (context) => RequestMeasurementDialog(
        onSubmit: (type, date, notes) async {
          final req = MeasurementRequest(
            customerId: widget.customerEmail ?? 'unknown', // Using email/id as identifier
            // Note: Adjust based on real constructor. Assuming standard fields.
            tailorId: widget.tailor?.docId ?? '',
            customerName: widget.customerName ?? 'Valued Customer',
            customerEmail: widget.customerEmail ?? '',
            customerPhone: widget.customerPhone ?? '',
            customerPhoto: null,
            requestType: type,
            status: 'pending',
            requestedAt: DateTime.now(),
            scheduledDate: date,
            notes: notes,
          );

          await _requestsService.addRequest(req);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Request sent successfully!')),
            );
          }
        },
      ),
    );
  }

  void _showEditMeasurementDialog(String part, double currentVal) {
    final controller = TextEditingController(text: currentVal.toString());
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.straighten, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update $part',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Request measurement change',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Enter new measurement (in inches). The tailor will review this request.',
                          style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Input field
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'New $part Measurement',
                    suffixText: 'inches',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: const Icon(Icons.edit, color: Colors.blue),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newVal = double.tryParse(controller.text);
                          if (newVal == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid number')),
                            );
                            return;
                          }
                          
                          Navigator.pop(context);
                          
                          final req = MeasurementRequest(
                            customerId: _authService.currentUser?.uid ?? 'unknown',
                            tailorId: widget.tailor?.docId ?? '',
                            customerName: widget.customerName ?? 'Customer',
                            customerEmail: widget.customerEmail ?? '',
                            customerPhone: widget.customerPhone ?? '',
                            requestType: 'renewal',
                            status: 'pending',
                            notes: 'Please update $part to $newVal inches.',
                          );

                          await _requestsService.addRequest(req);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Update request for $part sent to tailor!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 18),
                            SizedBox(width: 8),
                            Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showUpdateMeasurementsDialog(Measurement m) {
    // This was previously a placeholder, redirecting to the general list interaction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Click on any measurement part below to request a change.')),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // Padding for bottom nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Measurements',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showRequestMeasurementDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Request New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1f455b), // Dark Teal/Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          
          // Active Requests Section
          if (widget.measurementRequests.isNotEmpty)
            ...widget.measurementRequests.map((req) => _buildRequestCard(req)),

          // Measurement Details or Empty State
          if (widget.customerEmail == null)
             _buildEmptyState('Email required', 'Please provide your email', Icons.email)
          else if (widget.measurement == null)
              _buildDefaultMeasurementCard()
          else
              _buildCustomerMeasurementDetail(widget.measurement!),
        ],
      ),
    );
  }

  Widget _buildRequestCard(MeasurementRequest req) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      req.status.toLowerCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d').format(req.requestedAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            req.requestType == 'new' ? 'New Measurement' : 'Renewal Request',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            req.notes ?? 'Take my measurement',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMeasurementDetail(Measurement m) {
    Map<String, double> displayed = Map.from(m.measurements);

    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 0, // Flat styling as per image background seems seamless or light
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFB2DFDB), // Light Teal
                  child: const Icon(Icons.person, color: Color(0xFF00695C), size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.customerName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      'Measured: ${_formatDate(m.createdAt)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Visual Guide
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.accessibility, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Visual Guide',
                    style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Measurement List
            Column(
              children: displayed.entries.map((e) {
                return InkWell(
                  onTap: () {
                    _showEditMeasurementDialog(e.key, e.value);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // Very light grey
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 14, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              e.key,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                        Text(
                          '${e.value} In',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
             const SizedBox(height: 24),
             if (m.status != 'Accepted')
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.orange[50],
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.orange[200]!)
                 ),
                 child: const Text('Visit tailor to confirm these measurements', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange)),
               )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultMeasurementCard() {
     return Center(
       child: Container(
         margin: const EdgeInsets.all(20),
         padding: const EdgeInsets.all(32),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
         ),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(Icons.straighten, size: 48, color: Colors.grey[300]),
             const SizedBox(height: 16),
             const Text('No measurements yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
             const SizedBox(height: 8),
             const Text('Request a new measurement to get started.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: _showRequestMeasurementDialog,
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFF1f455b),
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
               child: const Text('Request Now'),
             ),
           ],
         ),
       ),
     );
  }
}
