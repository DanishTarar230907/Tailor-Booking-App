import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestMeasurementDialog extends StatefulWidget {
  final Function(String type, DateTime? date, String notes) onSubmit;

  const RequestMeasurementDialog({super.key, required this.onSubmit});

  @override
  State<RequestMeasurementDialog> createState() => _RequestMeasurementDialogState();
}

class _RequestMeasurementDialogState extends State<RequestMeasurementDialog> {
  String _selectedType = 'visit'; // 'visit' or 'online'
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date != null) {
      if (mounted) {
         final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
         if (time != null) {
            setState(() {
              _selectedDate = date;
              _selectedTime = time;
            });
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Measurements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Type Selection
            const Text('How would you like to provide measurements?', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    'visit', 
                    'Shop Visit', 
                    Icons.store,
                    'Book a time to visit the tailor.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    'online', 
                    'Send Existing', 
                    Icons.perm_media,
                    'Submit measurements you already have.',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Logic based on type
            if (_selectedType == 'visit') ...[
               const Text('Preferred Date & Time', style: TextStyle(fontWeight: FontWeight.w500)),
               const SizedBox(height: 8),
               InkWell(
                 onTap: _pickDate,
                 child: Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.grey.shade300),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.calendar_today, size: 20, color: Colors.indigo),
                       const SizedBox(width: 8),
                       Text(
                         _selectedDate == null 
                           ? 'Select Date & Time' 
                           : '${DateFormat('MMM d, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                         style: TextStyle(
                           color: _selectedDate == null ? Colors.grey : Colors.black87,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
            ] else ...[
               // Online / Existing - maybe just notes?
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.blue.shade50,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Text(
                   'You can enter your measurement values manually after creating this request, or describe them in the notes below.',
                   style: TextStyle(fontSize: 12, color: Colors.blue),
                 ),
               ),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes / Instructions',
                hintText: 'Any specific requests or details...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Validation
                    if (_selectedType == 'visit' && _selectedDate == null) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
                       return;
                    }
                    
                    DateTime? finalDate;
                    if (_selectedDate != null && _selectedTime != null) {
                      finalDate = DateTime(
                        _selectedDate!.year, 
                        _selectedDate!.month, 
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );
                    }
                    
                    widget.onSubmit(_selectedType, finalDate, _notesController.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon, String desc) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.indigo : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isSelected ? Colors.indigo : Colors.black87
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
