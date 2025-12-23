import 'package:flutter/material.dart';
import '../models/measurement.dart';
import 'measurement_card.dart';
import 'measurement_request_card.dart';

class CustomerDetailPanel extends StatelessWidget {
  final Measurement? measurement;
  final VoidCallback onRefresh;
  final Function(Measurement) onUpdate;

  const CustomerDetailPanel({
    super.key,
    required this.measurement,
    required this.onRefresh,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (measurement == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Select a customer to view details',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final m = measurement!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Request / Appointment Card (Top Priority)
          MeasurementRequestCard(
            measurement: m,
            onAccept: () {
               onUpdate(m.copyWith(status: 'Accepted', updateRequested: false));
            },
            onReject: () {
               onUpdate(m.copyWith(status: 'Rejected', updateRequested: false, rejectionReason: 'Slot unavailable'));
            },
            onProposeTime: (newDate) {
               onUpdate(m.copyWith(status: 'Pending', updateRequested: true, appointmentDate: newDate));
            },
          ),
          
          if (m.requestType != null) const SizedBox(height: 16),

          // 2. Main Measurement Card (Grid + Communication)
          // We wrap it to constrain width if needed, but it handles itself.
          MeasurementCard(
            measurement: m,
            onDelete: () {
              // Delete logic usually handled by parent or dialog, assume internal or callback 
              // For now just refresh
              onRefresh();
            },
            onRefresh: onRefresh,
          ),
          
          // 3. Extra space at bottom
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
