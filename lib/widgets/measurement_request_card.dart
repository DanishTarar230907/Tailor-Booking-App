import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/measurement.dart';

class MeasurementRequestCard extends StatelessWidget {
  final Measurement measurement;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final Function(DateTime) onProposeTime;

  const MeasurementRequestCard({
    super.key,
    required this.measurement,
    required this.onAccept,
    required this.onReject,
    required this.onProposeTime,
  });

  @override
  Widget build(BuildContext context) {
    if (measurement.requestType == null && !measurement.updateRequested) {
        // If not a specific request type and generic update not requested, minimal view or hide
        // But we want to show Appointment details if accepted.
        if (measurement.status == 'Accepted' && measurement.appointmentDate != null) {
            return _buildAppointmentCard(context);
        }
        return const SizedBox.shrink(); 
    }

    final isVisit = measurement.requestType == 'visit';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.indigoAccent, width: 1.5),
      ),
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isVisit ? Icons.store : Icons.straighten,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                Text(
                  isVisit ? 'Shop Visit Request' : 'Measurement Update Request',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(
                    measurement.status.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (measurement.appointmentDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      'Requested Date: ${DateFormat('EEE, MMM d • h:mm a').format(measurement.appointmentDate!)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

             if (measurement.rejectionReason != null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 8),
                 child: Text(
                   'Previous Rejection: ${measurement.rejectionReason}',
                   style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                 ),
               ),
            
             // Actions
             const SizedBox(height: 12),
             Row(
               children: [
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: onAccept,
                     icon: const Icon(Icons.check, size: 18),
                     label: const Text('Accept'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       foregroundColor: Colors.white,
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: OutlinedButton.icon(
                     onPressed: onReject,
                     icon: const Icon(Icons.close, size: 18),
                     label: const Text('Reject'),
                     style: OutlinedButton.styleFrom(
                       foregroundColor: Colors.red,
                       side: const BorderSide(color: Colors.red),
                     ),
                   ),
                 ),
               ],
             ),
             // Propose time link
             Center(
               child: TextButton(
                 onPressed: () {
                    // Show date picker
                    showDatePicker(
                      context: context, 
                      initialDate: measurement.appointmentDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30))
                    ).then((date) {
                      if (date != null && context.mounted) {
                          showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                              if (time != null) {
                                  onProposeTime(DateTime(date.year, date.month, date.day, time.hour, time.minute));
                              }
                          });
                      }
                    });
                 },
                 child: const Text('Propose Alternative Time'),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context) {
      return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
             const Icon(Icons.event_available, color: Colors.green, size: 28),
             const SizedBox(width: 12),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text('Confirmed Appointment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                   const SizedBox(height: 4),
                   Text(
                      DateFormat('EEE, MMM d • h:mm a').format(measurement.appointmentDate!),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                 ],
               ),
             ),
          ],
        ),
      ),
      );
  }
}
