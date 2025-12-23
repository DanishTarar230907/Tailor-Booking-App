import 'package:flutter/material.dart';
import '../models/measurement.dart' as models;
import '../widgets/measurement_dummy.dart';
import '../services/firestore_measurements_service.dart';

class MeasurementsScreen extends StatefulWidget {
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;

  const MeasurementsScreen({
    super.key,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
  });

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final FirestoreMeasurementsService _measurementsService =
      FirestoreMeasurementsService();
  models.Measurement? _measurement;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeasurement();
  }

  Future<void> _loadMeasurement() async {
    if (widget.customerEmail == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final measurement =
          await _measurementsService.getByCustomerEmail(widget.customerEmail!);
      setState(() {
        _measurement = measurement;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading measurement: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMeasurement(models.Measurement measurement) async {
    try {
      final nameController = TextEditingController(text: widget.customerName ?? '');
      final emailController = TextEditingController(text: widget.customerEmail ?? '');
      final phoneController = TextEditingController(text: widget.customerPhone ?? '');

      if (nameController.text.isEmpty || emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide customer name and email'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final updatedMeasurement = measurement.copyWith(
        customerName: nameController.text.trim(),
        customerEmail: emailController.text.trim(),
        customerPhone: phoneController.text.trim().isEmpty
            ? (measurement.customerPhone ?? '')
            : phoneController.text.trim(),
      );

      await _measurementsService.insertOrUpdate(updatedMeasurement);
      await _loadMeasurement();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurements saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving measurements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCustomerInfoDialog() {
    final nameController = TextEditingController(text: widget.customerName ?? '');
    final emailController = TextEditingController(text: widget.customerEmail ?? '');
    final phoneController = TextEditingController(text: widget.customerPhone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and Email are required'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final newMeasurement = models.Measurement(
                customerId: '',
                customerName: nameController.text.trim(),
                customerEmail: emailController.text.trim(),
                customerPhone: phoneController.text.trim().isEmpty
                    ? ''
                    : phoneController.text.trim(),
              );

              setState(() {
                _measurement = newMeasurement;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showCustomerInfoDialog,
            tooltip: 'Customer Info',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _measurement != null
                ? () => _saveMeasurement(_measurement!)
                : null,
            tooltip: 'Save Measurements',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _measurement == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.straighten, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No measurements found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCustomerInfoDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Measurements'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: MeasurementDummy(
                        measurement: _measurement,
                        isEditable: true,
                        onMeasurementUpdated: (updated) {
                          setState(() {
                            _measurement = updated;
                          });
                        },
                      ),
                    ),
                    if (_measurement!.notes != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notes:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(_measurement!.notes!),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}

