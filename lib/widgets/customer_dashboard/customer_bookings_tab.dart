import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking.dart';
import '../../models/tailor.dart';
import '../../services/firestore_bookings_service.dart';

class CustomerBookingsTab extends StatefulWidget {
  final Tailor? tailor;
  final List<Booking> allBookings;
  final List<Booking> myBookings;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final Function(Booking) onBookingAdded;
  final Function(Booking) onBookingRemoved;

  const CustomerBookingsTab({
    super.key,
    required this.tailor,
    required this.allBookings,
    required this.myBookings,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.onBookingAdded,
    required this.onBookingRemoved,
  });

  @override
  State<CustomerBookingsTab> createState() => _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends State<CustomerBookingsTab> {
  final FirestoreBookingsService _bookingsService = FirestoreBookingsService();
  String _selectedSuitType = 'Formal Suit'; // Default for dialog
  final ScrollController _scrollController = ScrollController();

  final List<String> _suitTypes = [
    'Formal Suit',
    'Casual Blazer',
    'Wedding Suit',
    'Tuxedo',
    'Designer Suit',
    'Custom Tailored',
  ];

  final List<String> _timeSlots = [
    '09:00 - 11:00',
    '11:00 - 13:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
  ];

  @override
  Widget build(BuildContext context) {
    // Generate dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingWindow = widget.tailor?.bookingWindowDays ?? 14; // Default 2 weeks view
    final upcomingDays = List.generate(
      bookingWindow, 
      (index) => today.add(Duration(days: index))
    );

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: upcomingDays.length,
            itemBuilder: (context, index) {
              return _buildDaySection(upcomingDays[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Booking Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the button
            children: [
              // No Settings Icon here as per request
              ElevatedButton.icon(
                onPressed: _scrollToFirstAvailable,
                icon: const Icon(Icons.arrow_downward, size: 18),
                label: const Text('Choose Your Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA), // Purple
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure slots take full width
      children: [
        // Date Header
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12, top: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF6B21A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9333EA).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEEE').format(date).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('d MMMM, yyyy').format(date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Slots
        ..._timeSlots.map((slot) => _buildSlotCard(date, slot)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSlotCard(DateTime date, String slotTime) {
    // Check Status
    final booking = widget.allBookings.firstWhere(
      (b) => b.bookingDate.year == date.year && 
             b.bookingDate.month == date.month && 
             b.bookingDate.day == date.day &&
             b.timeSlot == slotTime &&
             (b.status == 'pending' || b.status == 'approved' || b.status == 'completed'),
      orElse: () => Booking(
        customerName: '', customerEmail: '', customerPhone: '', 
        bookingDate: date, timeSlot: slotTime, suitType: '', 
        isUrgent: false, charges: 0, status: 'available',
      ),
    );

    final isAvailable = booking.status == 'available';
    final isMyBooking = booking.userId == FirebaseAuth.instance.currentUser?.uid;

    if (isAvailable) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showConfirmationDialog(date, slotTime),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_circle_outline, color: Color(0xFF22C55E), size: 24),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slotTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Available for Booking',
                          style: TextStyle(
                            color: Color(0xFF15803D), 
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
                ],
              ),
            ),
          ),
        ),
      );
    } 
    
    if (isMyBooking) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFFFF7ED), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFED7AA), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.stars, color: Color(0xFFF97316), size: 26),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        slotTime,
                        style: TextStyle(
                          color: Colors.grey.shade600, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'YOUR APPOINTMENT',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 9, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 17,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    booking.suitType,
                    style: TextStyle(
                      color: Colors.grey.shade600, 
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: booking.status == 'approved' ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: booking.status == 'approved' ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  color: booking.status == 'approved' ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      );
    } 
    
    // Other's Booking (Unavailable)
     return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_person_outlined, color: Color(0xFF94A3B8), size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slotTime,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8), 
                      fontSize: 15, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'SCHEDULED',
                    style: TextStyle(
                      color: Color(0xFF64748B), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 10, 
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  void _scrollToFirstAvailable() {
    // Scroll to top or first available logic
    // For now simple scroll to top
     _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _showConfirmationDialog(DateTime date, String slot) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) { // Use StatefulBuilder to update dropdown
          return AlertDialog(
            title: const Text('Add Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Date', DateFormat('MMM d, yyyy').format(date)),
                _detailRow('Time', slot),
                const SizedBox(height: 16),
                const Text('Select Service:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSuitType,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSuitType = val);
                  },
                  items: _suitTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processBooking(date, slot);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA)),
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _processBooking(DateTime date, String slot) async {
      if (widget.customerName == null || widget.customerName!.isEmpty ||
        widget.customerEmail == null || widget.customerEmail!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please update your profile with name and email first.')),
        );
        return;
      }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final booking = Booking(
      userId: userId,
      customerName: widget.customerName!,
      customerEmail: widget.customerEmail!,
      customerPhone: widget.customerPhone ?? '',
      bookingDate: date,
      timeSlot: slot,
      suitType: _selectedSuitType,
      isUrgent: false, 
      charges: 299.99, 
      status: 'pending',
    );

    widget.onBookingAdded(booking);

    try {
      await _bookingsService.addBooking(booking);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Booking Confirmed!'), backgroundColor: Colors.green),
         );
      }
    } catch (e) {
      widget.onBookingRemoved(booking);
      debugPrint('Booking Error (Full): $e');
      if (mounted) {
         String message = 'Could not confirm booking.';
         if (e.toString().contains('FIRESTORE')) {
           message = 'Connection issue. Please refresh the page and try again.';
         }
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(message), backgroundColor: Colors.red),
         );
      }
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
