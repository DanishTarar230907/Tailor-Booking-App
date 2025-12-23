import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart' as models;
import '../services/firestore_bookings_service.dart';

class VisualBookingScreen extends StatefulWidget {
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final DateTime? initialDate;

  const VisualBookingScreen({
    super.key,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.initialDate,
  });

  @override
  State<VisualBookingScreen> createState() => _VisualBookingScreenState();
}

class _VisualBookingScreenState extends State<VisualBookingScreen> {
  final FirestoreBookingsService _bookingsService = FirestoreBookingsService();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String? _selectedSuitType;
  bool _isUrgent = false; 
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  
  bool _isLoading = true;
  List<models.Booking> _bookingsForSelectedDate = [];
  StreamSubscription<List<models.Booking>>? _bookingsSubscription;

  final List<String> _timeSlots = [
    '09:00-11:00',
    '11:00-13:00',
    '13:00-15:00',
    '15:00-17:00',
  ];

  final List<String> _suitTypes = [
    'Formal Suit',
    'Casual Blazer',
    'Wedding Suit',
    'Tuxedo',
    'Designer Suit',
    'Custom Tailored',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _nameController.text = widget.customerName ?? '';
    _emailController.text = widget.customerEmail ?? '';
    _phoneController.text = widget.customerPhone ?? '';
    _selectedSuitType = _suitTypes.first;
    
    _subscribeToBookings(_selectedDate);
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _subscribeToBookings(DateTime date) {
    setState(() => _isLoading = true);
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _bookingsService.streamBookingsForDate(date).listen(
      (bookings) {
        if (mounted) {
          setState(() {
            _bookingsForSelectedDate = bookings;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        print('Error loading bookings: $error');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _subscribeToBookings(picked);
    }
  }

  bool _isSlotBooked(String slot) {
    return _bookingsForSelectedDate.any((b) => 
      b.timeSlot == slot && (b.status == 'pending' || b.status == 'approved'));
  }
  
  Color _getSlotColor(String slot) {
    if (_isSlotBooked(slot)) {
      return Colors.purple; 
    }
    return Colors.grey;
  }

  double _calculateCharges() {
    double basePrice = 299.99;
    if (_isUrgent) {
      basePrice += 150.00;
    }
    return basePrice;
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your details below before selecting a slot.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    if (_selectedSuitType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a suit type below.'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    return true;
  }

  void _onSlotTap(String slot) {
    if (_validateInputs()) {
      if (_selectedTimeSlot == slot) {
        _showConfirmationDialog(slot);
      } else {
        setState(() => _selectedTimeSlot = slot);
      }
    }
  }

  void _showConfirmationDialog(String slot) {
    // Double check validation just in case
    if (!_validateInputs()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMM d, yyyy').format(_selectedDate)}'),
            const SizedBox(height: 8),
            Text('Time: $slot'),
            const SizedBox(height: 8),
            Text('Service: $_selectedSuitType'),
            const SizedBox(height: 8),
            Text('Price: \$${_calculateCharges().toStringAsFixed(2)}'),
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
              _processBooking(slot);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Confirm Booking', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _undoBooking(String? docId) async {
    if (docId == null) return;
    try {
      await _bookingsService.deleteBooking(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking undone successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to undo: $e')),
        );
      }
    }
  }

  Future<void> _processBooking(String slot) async {
    // 2. Optimistic Check
    if (_isSlotBooked(slot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot is already booked.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 4. Create Booking
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get UID
      final booking = models.Booking(
        userId: userId, // Pass UID
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        bookingDate: _selectedDate,
        timeSlot: slot,
        suitType: _selectedSuitType!,
        isUrgent: _isUrgent,
        charges: _calculateCharges(),
        specialInstructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        status: 'pending',
      );

      final createdBooking = await _bookingsService.addBooking(booking);
      
      // Stream will auto-update the UI color

      if (mounted) {
        setState(() => _selectedTimeSlot = null); // Reset selection
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Booking Confirmed!'),
              ],
            ),
            action: SnackBarAction(
               label: 'Undo',
               onPressed: () => _undoBooking(createdBooking.docId),
               textColor: Colors.white,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false); // Ensure spinner stops on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking slot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Suit'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selected Date', style: TextStyle(color: Colors.grey)),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Change'),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),

            // Cinema Style Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Tap a Suit to Book Instantly',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _timeSlots[index];
                          final isBooked = _isSlotBooked(slot);
                          final isSelected = _selectedTimeSlot == slot;
                          final baseColor = _getSlotColor(slot);
                          // Determine visual state
                          final borderColor = isSelected ? Colors.blue : baseColor;
                          final bgColor = isSelected ? Colors.blue.withOpacity(0.05) : Colors.white;
                          
                          return GestureDetector(
                            onTap: isBooked ? null : () => _onSlotTap(slot),
                            onLongPress: isBooked ? null : () {
                              if (_validateInputs()) _showConfirmationDialog(slot);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: borderColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isBooked ? Icons.checkroom : Icons.dry_cleaning, // Suit/Hanger icon
                                    size: 40,
                                    color: borderColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      color: borderColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isBooked ? 'BOOKED' : (isSelected ? 'SELECTED' : 'AVAILABLE'),
                                    style: TextStyle(
                                      color: borderColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                  const SizedBox(height: 30),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.grey, 'Available'),
                      const SizedBox(width: 20),
                      _buildLegendItem(Colors.purple, 'Booked'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Colors.black12),

            // Options Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Suit Type
                  const Text('Suit Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _suitTypes.map((type) {
                      final isSelected = _selectedSuitType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedSuitType = selected ? type : null);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Urgency
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Urgent Booking (+ \$150.00)'),
                    subtitle: const Text('Get it stitched in 24 hours'),
                    value: _isUrgent,
                    onChanged: (val) => setState(() => _isUrgent = val),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flash_on, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 8, color: Colors.black12),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Ensure these are correct before tapping a slot.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.dry_cleaning, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
