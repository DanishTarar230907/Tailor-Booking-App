import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cached_network_image/cached_network_image.dart';
import '../database_helper.dart';
import '../models/tailor.dart' as models;
import '../models/design.dart' as models;
import '../models/complaint.dart' as models;
import '../models/booking.dart' as models;
import '../models/measurement.dart' as models;
import '../models/pickup_request.dart' as models;
import '../services/firestore_bookings_service.dart';
import '../services/firestore_designs_service.dart';
import '../services/firestore_complaints_service.dart';
import '../services/firestore_pickup_requests_service.dart';
import '../services/firestore_tailor_service.dart';
import 'booking_screen.dart';
import 'visual_booking_screen.dart';
import 'measurements_screen.dart';
import 'pickup_request_screen.dart';
import '../widgets/measurement_dummy.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  // All entities now via Firestore services.
  final FirestoreBookingsService _bookingsService = FirestoreBookingsService();
  final FirestoreDesignsService _designsService = FirestoreDesignsService();
  final FirestoreComplaintsService _complaintsService =
      FirestoreComplaintsService();
  final FirestorePickupRequestsService _pickupService =
      FirestorePickupRequestsService();
  final FirestoreTailorService _tailorService = FirestoreTailorService();
  final AuthService _authService = AuthService();
  // Fixed: Add reference to local database for stats/measurements wrapper
  final _db = DatabaseHelper.instance.database;
  models.Tailor? _tailor;
  List<models.Design> _designs = [];
  List<models.Complaint> _allComplaints = [];
  List<models.Complaint> _myComplaints = [];
  List<models.Booking> _myBookings = [];
  List<models.Booking> _allBookings = []; // Added for calendar view
  List<models.PickupRequest> _myPickupRequests = [];
  String? _customerName;
  String? _customerEmail;
  String? _customerPhone;
  String? _filterCustomerName;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _customerName = userData['name'] as String? ?? user.displayName;
          _customerEmail = user.email;
        });
      } else {
        setState(() {
          _customerName = user.displayName;
          _customerEmail = user.email;
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tailor = await _tailorService.getTailor();
      final designs = await _designsService.getAllDesigns();
      final allComplaints = await _complaintsService.getAllComplaints();
      final allBookings = await _bookingsService.getAllBookings();
      final allPickupRequests = await _pickupService.getAllRequests();
      
      // Apply filter if set, otherwise show all complaints
      final filterName = _filterCustomerName ?? _customerName;
      final filteredComplaints = filterName != null && filterName.isNotEmpty
          ? allComplaints.where((c) => c.customerName.toLowerCase().contains(filterName.toLowerCase())).toList()
          : allComplaints;
      
      // Filter bookings by customer name if set
      final List<models.Booking> myBookings = _customerName != null
          ? allBookings.where((b) => b.customerName == _customerName).toList()
          : <models.Booking>[];
      
      // Filter pickup requests by customer email or name
      final List<models.PickupRequest> myPickupRequests = (_customerEmail != null || _customerName != null)
          ? allPickupRequests.where((p) => 
              (_customerEmail != null && p.customerEmail == _customerEmail) ||
              (_customerName != null && p.customerName == _customerName)
            ).toList()
          : <models.PickupRequest>[];
      
      setState(() {
        _tailor = tailor;
        _designs = designs;
        _allComplaints = allComplaints;
        _myComplaints = filteredComplaints;
        _myBookings = myBookings;
        _allBookings = allBookings; // Store all bookings for calendar view
        _myPickupRequests = myPickupRequests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showComplaintDialog() {
    final nameController = TextEditingController(text: _customerName ?? '');
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Complaint'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Your Complaint',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              final complaint = models.Complaint(
                customerName: _customerName ?? nameController.text.trim(),
                message: messageController.text.trim(),
              );
              await _db.insertComplaint(complaint);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint sent successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            title: const Text('Customer Dashboard'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: _showComplaintDialog,
                tooltip: 'Send Complaint',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _authService.signOut();
                  }
                },
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildTailorInfoTab(),
                _buildDesignsTab(),
                _buildBookingsTab(),
                _buildMeasurementsTab(),
                _buildPickupRequestsTab(),
                _buildComplaintsTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() => _selectedIndex = index);
          // Always refresh data when switching tabs
          if (index >= 2) {
            await _loadData();
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Tailor Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Designs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.straighten),
            label: 'Measurements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Pickup',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Complaints',
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showComplaintDialog,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.message, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Send Complaint',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTailorInfoTab() {
    if (_tailor == null) {
      return const Center(
        child: Text('Tailor information not available yet.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // Gradient Avatar Border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 76,
                backgroundImage: _tailor!.photo != null && _tailor!.photo!.isNotEmpty
                    ? (_tailor!.photo!.startsWith('data:')
                        ? MemoryImage(base64Decode(_tailor!.photo!.split(',')[1])) as ImageProvider
                        : CachedNetworkImageProvider(_tailor!.photo!) as ImageProvider)
                    : null,
                child: _tailor!.photo == null || _tailor!.photo!.isEmpty
                    ? Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary)
                    : null,
                onBackgroundImageError: _tailor!.photo != null && _tailor!.photo!.isNotEmpty
                    ? (exception, stackTrace) {
                        // Handle image error
                      }
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tailor!.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          // Enhanced About Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _tailor!.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.design_services, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Available Designs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                  onPressed: _loadData,
                  tooltip: 'Refresh',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _designs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.design_services,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No designs available yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _designs.length,
                  itemBuilder: (context, index) {
                    final design = _designs[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  design.photo != null && design.photo!.isNotEmpty
                                      ? (design.photo!.startsWith('data:')
                                          ? Image.memory(
                                              base64Decode(design.photo!.split(',')[1]),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey[300]!,
                                                      Colors.grey[200]!,
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: design.photo!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                                                    ],
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey[300]!,
                                                      Colors.grey[200]!,
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                              ),
                                            ))
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                              ],
                                            ),
                                          ),
                                          child: const Icon(Icons.image, size: 50, color: Colors.white),
                                        ),
                                  // Gradient overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Theme.of(context).colorScheme.primary.withOpacity(0.02),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    design.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF10B981).withOpacity(0.15),
                                              const Color(0xFF059669).withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '\$${design.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF059669),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).colorScheme.primary,
                                              Theme.of(context).colorScheme.secondary,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Booking Calendar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 28, color: Colors.blue),
                  onPressed: () => _openBookingScreen(DateTime.now(), ''), // Open with default
                  tooltip: 'Book Custom Date',
                ),
              ],
            ),
          ),
          _buildWeeklyBookingCalendar(),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Available', Colors.green[100]!, Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Your Booking', Colors.blue[100]!, Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Booked/Busy', Colors.grey[300]!, Colors.grey),
            ],
          ),
          if (_myBookings.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Your Upcoming Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            ..._myBookings.map((b) => _buildCustomerBookingCard(b)),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color bg, Color border) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyBookingCalendar() {
    // Generate next 7 days starting from today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingDays = List.generate(7, (index) => today.add(Duration(days: index)));
    
    // Fixed Slots
    final timeSlots = [
      '09:00 - 11:00',
      '11:00 - 13:00',
      '14:00 - 16:00',
      '16:00 - 18:00',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: upcomingDays.map((date) => _buildDayColumn(date, timeSlots)).toList(),
      ),
    );
  }

  Widget _buildDayColumn(DateTime date, List<String> timeSlots) {
    final isToday = date.day == DateTime.now().day && 
                    date.month == DateTime.now().month && 
                    date.year == DateTime.now().year;

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday ? Theme.of(context).primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _getConfiguredDateFormat('E').format(date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Slots
          ...timeSlots.map((slot) => _buildTimeSlotCard(date, slot)),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(DateTime date, String slotTime) {
    // Find booking for this slot from ALL bookings
    final booking = _allBookings.firstWhere(
      (b) => b.bookingDate.year == date.year && 
             b.bookingDate.month == date.month && 
             b.bookingDate.day == date.day &&
             b.timeSlot == slotTime,
      orElse: () => models.Booking(
        customerName: '', 
        customerEmail: '', 
        customerPhone: '', 
        bookingDate: date, 
        timeSlot: slotTime, 
        suitType: '', 
        isUrgent: false, 
        charges: 0,
        status: 'available', // Virtual status
      ),
    );

    final isAvailable = booking.status == 'available';
    // Check if it's MY booking
    final isMyBooking = booking.customerEmail == _customerEmail || 
                        (booking.customerName == _customerName && _customerName != null);
    
    // Status Logic for Customer View
    // Available -> Green
    // My Booking -> Blue (or Status specific color)
    // Others' Booking -> Grey/Red (Booked/Busy)

    Color bgColor;
    Color borderColor;
    IconData? icon;
    String label;

    if (isAvailable) {
      bgColor = Colors.green[50]!;
      borderColor = Colors.green;
      icon = Icons.add;
      label = 'Open';
    } else if (isMyBooking) {
      if (booking.status == 'pending') {
         bgColor = Colors.amber[50]!;
         borderColor = Colors.amber;
         icon = Icons.hourglass_empty;
         label = 'Pending';
      } else {
         bgColor = Colors.blue[50]!;
         borderColor = Colors.blue;
         icon = Icons.check;
         label = 'Yours';
      }
    } else {
      // Someone else's booking
      bgColor = Colors.grey[200]!;
      borderColor = Colors.grey[400]!;
      icon = Icons.block;
      label = 'Booked';
    }

    return GestureDetector(
      onTap: () {
        if (isAvailable) {
           // Provide standard visual booking screen pre-filled
           _openBookingScreen(date, slotTime);
        } else if (isMyBooking) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('You booked this slot. Status: ${booking.status.toUpperCase()}'))
           );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('This slot is already booked.'))
           );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              slotTime,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                   Icon(icon, size: 20, color: borderColor),
                   const SizedBox(height: 4),
                   Text(
                     label, 
                     style: TextStyle(
                       fontSize: 10, 
                       fontWeight: FontWeight.bold,
                       color: borderColor
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _openBookingScreen(DateTime date, String slot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualBookingScreen(
          customerName: _customerName,
          customerEmail: _customerEmail,
          customerPhone: _customerPhone,
          initialDate: date,
          initialSlot: slot, // Need to make sure VisualBookingScreen accepts these or update it
        ),
      ),
    );
    // Note: VisualBookingScreen might not accept initialDate/Slot yet. 
    // If not, the user will just have to select it again, which is acceptable but not ideal.
    // I will verify VisualBookingScreen logic next and update it if needed.
    // For now, let's load data on return.
    if (result == true) {
      _loadData();
    }
  }

  Widget _buildCustomerBookingCard(models.Booking booking) {
    Color statusColor;
    IconData statusIcon;
    switch (booking.status) {
      case 'pending': statusColor = Colors.orange; statusIcon = Icons.pending; break;
      case 'approved': statusColor = Colors.green; statusIcon = Icons.check_circle; break;
      case 'rejected': statusColor = Colors.red; statusIcon = Icons.cancel; break;
      case 'completed': statusColor = Colors.blue; statusIcon = Icons.done_all; break;
      default: statusColor = Colors.grey; statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.suitType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_formatDate(booking.bookingDate)} • ${booking.timeSlot}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Chip(
                  label: Text(booking.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hacky Date Format helper 
  dynamic _getConfiguredDateFormat(String pattern) {
    return _SimpleDateFormatter(pattern);
  }

  Widget _buildMeasurementsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Measurements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeasurementsScreen(
                        customerName: _customerName,
                        customerEmail: _customerEmail,
                        customerPhone: _customerPhone,
                      ),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add/Edit Measurements'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _customerEmail == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.straighten, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Please provide your email to view measurements',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : FutureBuilder<models.Measurement?>(
                  future: _db.getMeasurementByCustomer(_customerEmail!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.straighten, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No measurements found',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MeasurementsScreen(
                                      customerName: _customerName,
                                      customerEmail: _customerEmail,
                                      customerPhone: _customerPhone,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Measurements'),
                            ),
                          ],
                        ),
                      );
                    }
                    return MeasurementDummy(
                      measurement: snapshot.data,
                      isEditable: false,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPickupRequestsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pickup Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupRequestScreen(
                        customerName: _customerName,
                        customerEmail: _customerEmail,
                        customerPhone: _customerPhone,
                      ),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('New Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _myPickupRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No pickup requests yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PickupRequestScreen(
                                customerName: _customerName,
                                customerEmail: _customerEmail,
                                customerPhone: _customerPhone,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadData();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Request Pickup'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myPickupRequests.length,
                    itemBuilder: (context, index) {
                      final request = _myPickupRequests[index];
                      return _buildPickupRequestCard(request);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPickupRequestCard(models.PickupRequest request) {
    Color statusColor;
    IconData statusIcon;
    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requestType == 'sewing_request'
                            ? 'Sewing Request Pickup'
                            : 'Manual Pickup',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested: ${_formatDate(request.requestedDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(statusIcon, size: 16, color: Colors.white),
                  label: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.pickupAddress,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (request.trackingNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Tracking: ${request.trackingNumber}'),
                ],
              ),
            ],
            if (request.courierName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Courier: ${request.courierName}'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Charges: \$${request.charges.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Complaints',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: _showDatabaseInfoDialog,
                        tooltip: 'Database Info',
                      ),
                      if (_customerName != null)
                        Chip(
                          label: Text(_customerName!),
                          avatar: const Icon(Icons.person, size: 18),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Filter by customer name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _filterCustomerName != null && _filterCustomerName!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _filterCustomerName = null;
                            });
                            _loadData();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filterCustomerName = value.isEmpty ? null : value;
                  });
                  _loadData();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _myComplaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _filterCustomerName != null
                            ? 'No complaints found for "${_filterCustomerName}"'
                            : 'No complaints yet. Send your first complaint!',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_filterCustomerName == null) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showComplaintDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Send Your First Complaint'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _myComplaints[index];
                      final isMyComplaint = _customerName != null && complaint.customerName == _customerName;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: isMyComplaint ? 4 : 2,
                        color: isMyComplaint ? Colors.blue[50] : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Complaint #${complaint.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              complaint.customerName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: isMyComplaint ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            if (isMyComplaint) ...[
                                              const SizedBox(width: 8),
                                              Chip(
                                                label: const Text('You', style: TextStyle(fontSize: 10)),
                                                backgroundColor: Colors.blue[200],
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (complaint.isResolved)
                                    Chip(
                                      label: const Text('Replied'),
                                      backgroundColor: Colors.green[100],
                                      avatar: const Icon(Icons.check, size: 18),
                                    )
                                  else
                                    Chip(
                                      label: const Text('Pending'),
                                      backgroundColor: Colors.orange[100],
                                    ),
                                ],
                              ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your Message:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(complaint.message),
                                    ],
                                  ),
                                ),
                                if (complaint.reply != null && complaint.reply!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.reply, size: 16, color: Colors.green[700]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Tailor\'s Reply:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          complaint.reply!,
                                          style: TextStyle(
                                            color: Colors.green[900],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'Sent: ${_formatDate(complaint.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDatabaseInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage, color: Colors.blue),
            SizedBox(width: 8),
            Text('Database Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Database Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _getDatabasePath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return SelectableText(
                  snapshot.data ?? 'Unknown',
                  style: const TextStyle(fontFamily: 'monospace'),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Database Statistics:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, int>>(
              future: _getDatabaseStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final stats = snapshot.data ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tailors: ${stats['tailors'] ?? 0}'),
                    Text('Designs: ${stats['designs'] ?? 0}'),
                    Text('Complaints: ${stats['complaints'] ?? 0}'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<String> _getDatabasePath() async {
    try {
      if (kIsWeb) {
        return 'Web: Stored in browser IndexedDB (sql.js)\nDatabase Name: "db"\n\nTo view: Open browser DevTools > Application > IndexedDB > "db"';
      } else {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'todos.db'));
        return 'Mobile: ${file.path}\n\nYou can access this file using a file manager or ADB.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Map<String, int>> _getDatabaseStats() async {
    try {
      final tailor = await _db.getTailor();
      final designs = await _db.getAllDesigns();
      final complaints = await _db.getAllComplaints();
      return {
        'tailors': tailor != null ? 1 : 0,
        'designs': designs.length,
        'complaints': complaints.length,
      };
    } catch (e) {
      return {'error': 0};
    }
  }
}

class _SimpleDateFormatter {
  final String pattern;
  _SimpleDateFormatter(this.pattern);
  
  String format(DateTime date) {
    if (pattern == 'E') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
    if (pattern == 'd') {
      return date.day.toString();
    }
    return date.toString();
  }
}
