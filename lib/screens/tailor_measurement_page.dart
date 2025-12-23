import 'package:flutter/material.dart';
import '../models/measurement.dart';
import '../services/firestore_measurements_service.dart';
import '../widgets/customer_list_panel.dart';
import '../widgets/customer_detail_panel.dart';

class TailorMeasurementPage extends StatefulWidget {
  const TailorMeasurementPage({super.key});

  @override
  State<TailorMeasurementPage> createState() => _TailorMeasurementPageState();
}

class _TailorMeasurementPageState extends State<TailorMeasurementPage> {
  final _service = FirestoreMeasurementsService();
  String? _selectedMeasurementDocId;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: StreamBuilder<List<Measurement>>(
        stream: _service.getMeasurementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final measurements = snapshot.data ?? [];

          // Find selected measurement object
          Measurement? selected;
          if (_selectedMeasurementDocId != null) {
            try {
              selected = measurements.firstWhere((m) => m.docId == _selectedMeasurementDocId);
            } catch (e) {
              // Selected might have been deleted
              _selectedMeasurementDocId = null;
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;

              if (!isWide) {
                // Mobile View: List Only, Navigate on Tap
                return CustomerListPanel(
                  measurements: measurements,
                  selectedId: null, // Don't highlight in list on mobile
                  onSelect: (docId) {
                    final selected = measurements.firstWhere((m) => m.docId == docId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StreamBuilder<List<Measurement>>(
                          stream: _service.getMeasurementsStream(),
                          initialData: measurements,
                          builder: (context, snapshot) {
                            final currentList = snapshot.data ?? [];
                            final updatedSelected = currentList.firstWhere(
                              (m) => m.docId == selected.docId,
                              orElse: () => selected,
                            );
                            
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(updatedSelected.customerName),
                                backgroundColor: const Color(0xFF4F46E5),
                                iconTheme: const IconThemeData(color: Colors.white),
                                foregroundColor: Colors.white,
                              ),
                              body: CustomerDetailPanel(
                                measurement: updatedSelected,
                                onRefresh: () {
                                  // Stream handles updates automatically
                                },
                                onUpdate: (updated) async {
                                  await _service.insertOrUpdate(updated);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              // Desktop/Tablet View: Split Screen
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel: Customer List
                  SizedBox(
                    width: 350,
                    child: CustomerListPanel(
                      measurements: measurements,
                      selectedId: _selectedMeasurementDocId,
                      onSelect: (docId) {
                        setState(() {
                          _selectedMeasurementDocId = docId;
                        });
                      },
                    ),
                  ),
                  
                  // Right Panel: Details
                  Expanded(
                    child: Container(
                      color: Colors.indigo.withOpacity(0.02),
                      child: CustomerDetailPanel(
                        measurement: selected,
                        onRefresh: () => setState(() {}),
                        onUpdate: (updated) async {
                          await _service.insertOrUpdate(updated);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
