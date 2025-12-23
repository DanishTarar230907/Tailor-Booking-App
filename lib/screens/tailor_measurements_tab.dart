import 'package:flutter/material.dart';
import '../models/measurement.dart' as models;
import '../widgets/measurement_dummy.dart';
import '../services/firestore_measurements_service.dart';

class TailorMeasurementsTab extends StatefulWidget {
  const TailorMeasurementsTab({super.key});

  @override
  State<TailorMeasurementsTab> createState() => _TailorMeasurementsTabState();
}

class _TailorMeasurementsTabState extends State<TailorMeasurementsTab> {
  final FirestoreMeasurementsService _measurementsService =
      FirestoreMeasurementsService();
  List<models.Measurement> _measurements = [];
  String? _selectedCustomerEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    try {
      final measurements = await _measurementsService.getAllMeasurements();
      setState(() {
        _measurements = measurements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading measurements: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Measurements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMeasurements,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _measurements.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.straighten, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No measurements found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _selectedCustomerEmail == null
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _measurements.length,
                          itemBuilder: (context, index) {
                            final measurement = _measurements[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: const Icon(Icons.person, size: 40),
                                title: Text(measurement.customerName),
                                subtitle: Text(measurement.customerEmail),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  setState(() => _selectedCustomerEmail = measurement.customerEmail);
                                },
                              ),
                            );
                          },
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => setState(() => _selectedCustomerEmail = null),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _measurements.firstWhere((m) => m.customerEmail == _selectedCustomerEmail).customerName,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: MeasurementDummy(
                                measurement: _measurements.firstWhere((m) => m.customerEmail == _selectedCustomerEmail),
                                isEditable: false,
                              ),
                            ),
                          ],
                        ),
        ),
      ],
    );
  }
}

