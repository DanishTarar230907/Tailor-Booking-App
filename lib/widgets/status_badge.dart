import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String type; // 'pickup', 'complaint', 'booking'

  const StatusBadge({
    Key? key,
    required this.status,
    this.type = 'pickup',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['bgColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config['borderColor'], width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            size: 14,
            color: config['textColor'],
          ),
          const SizedBox(width: 6),
          Text(
            config['label'],
            style: TextStyle(
              color: config['textColor'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    final statusLower = status.toLowerCase();

    // Pickup statuses
    if (type == 'pickup') {
      switch (statusLower) {
        case 'pending':
          return {
            'label': 'Pending',
            'bgColor': Colors.orange.shade50,
            'borderColor': Colors.orange.shade300,
            'textColor': Colors.orange.shade700,
            'icon': Icons.schedule,
          };
        case 'received':
          return {
            'label': 'Received',
            'bgColor': Colors.green.shade50,
            'borderColor': Colors.green.shade300,
            'textColor': Colors.green.shade700,
            'icon': Icons.check_circle,
          };
        case 'not_received':
          return {
            'label': 'Not Received',
            'bgColor': Colors.red.shade50,
            'borderColor': Colors.red.shade300,
            'textColor': Colors.red.shade700,
            'icon': Icons.cancel,
          };
        case 'delayed':
          return {
            'label': 'Delayed',
            'bgColor': Colors.amber.shade50,
            'borderColor': Colors.amber.shade300,
            'textColor': Colors.amber.shade700,
            'icon': Icons.access_time,
          };
        case 'completed':
          return {
            'label': 'Completed',
            'bgColor': Colors.blue.shade50,
            'borderColor': Colors.blue.shade300,
            'textColor': Colors.blue.shade700,
            'icon': Icons.done_all,
          };
        default:
          return {
            'label': status,
            'bgColor': Colors.grey.shade50,
            'borderColor': Colors.grey.shade300,
            'textColor': Colors.grey.shade700,
            'icon': Icons.info,
          };
      }
    }

    // Complaint statuses
    if (type == 'complaint') {
      switch (statusLower) {
        case 'open':
          return {
            'label': 'Open',
            'bgColor': Colors.blue.shade50,
            'borderColor': Colors.blue.shade300,
            'textColor': Colors.blue.shade700,
            'icon': Icons.mail,
          };
        case 'in_progress':
          return {
            'label': 'In Progress',
            'bgColor': Colors.orange.shade50,
            'borderColor': Colors.orange.shade300,
            'textColor': Colors.orange.shade700,
            'icon': Icons.pending,
          };
        case 'resolved':
          return {
            'label': 'Resolved',
            'bgColor': Colors.green.shade50,
            'borderColor': Colors.green.shade300,
            'textColor': Colors.green.shade700,
            'icon': Icons.check_circle,
          };
        default:
          return {
            'label': status,
            'bgColor': Colors.grey.shade50,
            'borderColor': Colors.grey.shade300,
            'textColor': Colors.grey.shade700,
            'icon': Icons.info,
          };
      }
    }

    // Booking statuses
    if (type == 'booking') {
      switch (statusLower) {
        case 'pending':
          return {
            'label': 'Pending',
            'bgColor': Colors.orange.shade50,
            'borderColor': Colors.orange.shade300,
            'textColor': Colors.orange.shade700,
            'icon': Icons.schedule,
          };
        case 'approved':
          return {
            'label': 'Approved',
            'bgColor': Colors.green.shade50,
            'borderColor': Colors.green.shade300,
            'textColor': Colors.green.shade700,
            'icon': Icons.check_circle,
          };
        case 'rejected':
          return {
            'label': 'Rejected',
            'bgColor': Colors.red.shade50,
            'borderColor': Colors.red.shade300,
            'textColor': Colors.red.shade700,
            'icon': Icons.cancel,
          };
        case 'completed':
          return {
            'label': 'Completed',
            'bgColor': Colors.blue.shade50,
            'borderColor': Colors.blue.shade300,
            'textColor': Colors.blue.shade700,
            'icon': Icons.done_all,
          };
        default:
          return {
            'label': status,
            'bgColor': Colors.grey.shade50,
            'borderColor': Colors.grey.shade300,
            'textColor': Colors.grey.shade700,
            'icon': Icons.info,
          };
      }
    }

    // Default
    return {
      'label': status,
      'bgColor': Colors.grey.shade50,
      'borderColor': Colors.grey.shade300,
      'textColor': Colors.grey.shade700,
      'icon': Icons.info,
    };
  }
}
