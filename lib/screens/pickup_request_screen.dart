import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pickup_request.dart' as models;
import '../models/booking.dart' as models;
import '../services/firestore_pickup_requests_service.dart';

class PickupRequestScreen extends StatefulWidget {
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final models.Booking? relatedBooking;

  const PickupRequestScreen({
    super.key,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.relatedBooking,
  });

  @override
  State<PickupRequestScreen> createState() => _PickupRequestScreenState();
}

class _PickupRequestScreenState extends State<PickupRequestScreen> {
  final FirestorePickupRequestsService _pickupService =
      FirestorePickupRequestsService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _trackingController = TextEditingController();
  final _courierController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _requestType = 'manual'; // 'sewing_request' or 'manual'
  DateTime _requestedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.customerName ?? '';
    _emailController.text = widget.customerEmail ?? '';
    _phoneController.text = widget.customerPhone ?? '';
    
    if (widget.relatedBooking != null) {
      _requestType = 'sewing_request';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _trackingController.dispose();
    _courierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateCharges() {
    // Base charge for pickup
    double baseCharge = 25.00;
    
    // Additional charge if linked to sewing request
    if (_requestType == 'sewing_request') {
      baseCharge += 15.00; // Extra charge for sewing-related pickup
    }
    
    return baseCharge;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _requestedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _requestedDate) {
      setState(() => _requestedDate = picked);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = models.PickupRequest(
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        requestType: _requestType,
        relatedBookingDocId: widget.relatedBooking?.docId,
        pickupAddress: _addressController.text.trim(),
        trackingNumber: _trackingController.text.trim().isEmpty
            ? null
            : _trackingController.text.trim(),
        courierName: _courierController.text.trim().isEmpty
            ? null
            : _courierController.text.trim(),
        status: 'pending',
        charges: _calculateCharges(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        requestedDate: _requestedDate,
      );

      await _pickupService.addRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup request submitted! Charges: \$${_calculateCharges().toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Pickup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Request Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Type',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('Manual Pickup'),
                        subtitle: const Text('For online orders or general parcels'),
                        value: 'manual',
                        groupValue: _requestType,
                        onChanged: (value) => setState(() => _requestType = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Sewing Request Pickup'),
                        subtitle: Text(widget.relatedBooking != null
                            ? 'Linked to your booking'
                            : 'When tailor accepts your dress request'),
                        value: 'sewing_request',
                        groupValue: _requestType,
                        onChanged: widget.relatedBooking != null
                            ? (value) => setState(() => _requestType = value!)
                            : null,
                        enabled: widget.relatedBooking != null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Related Booking Info
              if (widget.relatedBooking != null && _requestType == 'sewing_request')
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Related Booking:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Suit: ${widget.relatedBooking!.suitType}'),
                        Text('Date: ${DateFormat('MMM d, yyyy').format(widget.relatedBooking!.bookingDate)}'),
                        Text('Time: ${widget.relatedBooking!.timeSlot}'),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Customer Information
              const Text(
                'Your Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your phone' : null,
              ),
              const SizedBox(height: 24),

              // Pickup Address
              const Text(
                'Pickup Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter full address where parcel should be picked up',
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter pickup address' : null,
              ),
              const SizedBox(height: 12),

              // Requested Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Requested Pickup Date *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('EEEE, MMMM d, yyyy').format(_requestedDate)),
                ),
              ),
              const SizedBox(height: 12),

              // Tracking Info (Optional)
              TextField(
                controller: _trackingController,
                decoration: const InputDecoration(
                  labelText: 'Tracking Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _courierController,
                decoration: const InputDecoration(
                  labelText: 'Courier Name (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                  hintText: 'e.g., DHL, FedEx, etc.',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Charges Summary
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Charges Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Base Pickup Charge:'),
                          Text('\$${25.00.toStringAsFixed(2)}'),
                        ],
                      ),
                      if (_requestType == 'sewing_request') ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sewing Request Fee:'),
                            Text(
                              '\$${15.00.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Charges:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${_calculateCharges().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRequest,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Submitting...' : 'Submit Pickup Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

