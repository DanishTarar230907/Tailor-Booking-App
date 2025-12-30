import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/tailor.dart' as models;
import '../models/design.dart' as models;
import '../models/booking.dart' as models;
import '../models/measurement.dart' as models;
import '../models/pickup_request.dart' as models;
import '../models/complaint.dart' as models;
import '../models/faq_item.dart';
import '../models/notification.dart';
import '../models/measurement_request.dart'; // Added
import '../utils/app_validators.dart';

import 'measurements_screen.dart';
import 'pickup_request_screen.dart';
import '../widgets/measurement_dummy.dart';
import '../services/auth_service.dart';
import '../widgets/announcement_card.dart';
import '../widgets/customer_dashboard/customer_tailor_info_tab.dart'; // Ensure this is imported too just in case
import '../widgets/customer_dashboard/customer_designs_tab.dart';
import '../widgets/customer_dashboard/customer_bookings_tab.dart';
import '../widgets/customer_dashboard/customer_measurements_tab.dart';
import '../widgets/customer_dashboard/customer_pickup_tab.dart';
import '../widgets/customer_dashboard/customer_complaints_tab.dart';
import '../widgets/unified_profile_card.dart';
import '../services/firestore_designs_service.dart';
import '../services/firestore_bookings_service.dart';
import '../services/firestore_complaints_service.dart';
import '../services/firestore_pickup_requests_service.dart';
import '../services/firestore_tailor_service.dart';
import '../services/firestore_measurements_service.dart';
import '../services/firestore_faq_service.dart';
import '../services/firestore_notification_service.dart';
import '../services/firestore_measurement_requests_service.dart'; // Added
import '../services/seed_data.dart'; // Added for self-healing
import '../widgets/communication_section.dart';
import '../widgets/unified_profile_card.dart';
import '../widgets/request_measurement_dialog.dart';
import '../widgets/measurement_receipt.dart';
import '../widgets/status_badge.dart';
import '../widgets/notification_bell.dart';
import '../widgets/conversation_thread.dart';
import '../widgets/customer_dashboard/customer_profile_section.dart';
import '../widgets/customer_dashboard/customer_bookings_tab.dart';
import '../widgets/customer_dashboard/customer_tailor_info_tab.dart';
import '../widgets/customer_dashboard/customer_designs_tab.dart';
import '../widgets/customer_dashboard/customer_measurements_tab.dart';
import '../widgets/customer_dashboard/customer_pickup_tab.dart';
import '../widgets/customer_dashboard/customer_complaints_tab.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/announcement_card.dart';
import '../widgets/app_footer.dart';
import '../widgets/animated_sewing_loader.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with SingleTickerProviderStateMixin {
  // All entities now via Firestore services.
  final AuthService _authService = AuthService();
  final FirestoreDesignsService _designsService = FirestoreDesignsService();
  final FirestoreBookingsService _bookingsService = FirestoreBookingsService();
  final FirestoreComplaintsService _complaintsService =
      FirestoreComplaintsService();
  final FirestorePickupRequestsService _pickupService =
      FirestorePickupRequestsService();
  final FirestoreTailorService _tailorService = FirestoreTailorService();
  final FirestoreMeasurementsService _measurementsService =
      FirestoreMeasurementsService();
  final FirestoreFaqService _faqService = FirestoreFaqService();
  final FirestoreNotificationService _notificationService =
      FirestoreNotificationService();
  final FirestoreMeasurementRequestsService _measurementRequestsService = FirestoreMeasurementRequestsService(); // Added
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  models.Tailor? _tailor;
  models.Measurement? _measurement;
  List<models.Design> _designs = [];
  List<models.Booking> _myBookings = [];
  List<models.Booking> _allBookings = []; // Added for calendar view
  List<models.PickupRequest> _myPickupRequests = [];
  List<models.Complaint> _myComplaints = [];
  List<MeasurementRequest> _myMeasurementRequests = []; // Added
  List<FaqItem> _faqs = [];
  String? _customerName;
  String? _customerEmail;
  String? _customerPhone;
  String? _customerWhatsapp;
  String? _customerProfilePic;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  int _selectedTabIndex = 0; // For Bottom Navigation

  // Form Controllers
  final _complaintSubjectController = TextEditingController();
  final _complaintMessageController = TextEditingController();
  String _complaintCategory = 'quality';

  final _pickupAddressController = TextEditingController();
  final _pickupNotesController = TextEditingController(); // Added for notes if needed
  String _pickupType = 'courier_pickup';

  // Booking Safeguards State
  DateTime? _pendingBookingDate;
  String? _pendingBookingSlot;


  
  // Design Carousel
  late PageController _designsController;
  Timer? _carouselTimer;
  int _currentDesignIndex = 0;
  
  // Fade Animation (Implicitly used or we explicitly define if needed, but error didn't complain about it specifically except maybe later? 
  // Wait, I saw _fadeAnimation in previous code. Step 215 removed it?)
  // Step 215 removed `_fadeAnimation` initialization in initState. Let's check if it's used elsewhere. 
  // Step 215 removed `_fadeAnimation = ...`
  // If `_fadeAnimation` is used elsewhere, it will error. 
  // But let's fix the reported errors first.


  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData(); // This loads designs etc.
    
    _animationController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1000),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Auto-Scroll Logic for Designs
    _designsController = PageController(viewportFraction: 0.85);
    // Start timer after a slight delay to allow data load, or reliant on data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _startAutoScroll();
    });
    _setupRealtimeListeners();
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_designs.isEmpty) return;
      if (_designsController.hasClients) {
        int nextPage = _currentDesignIndex + 1;
        if (nextPage >= _designs.length) {
          nextPage = 0;
          _designsController.jumpToPage(0);
        } else {
          _designsController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
        _currentDesignIndex = nextPage;
      }
    });
  }

  StreamSubscription<List<models.Design>>? _designsSubscription;
  StreamSubscription<List<models.Booking>>? _bookingsSubscription;
  StreamSubscription<List<models.PickupRequest>>? _pickupSubscription;
  StreamSubscription<List<models.Complaint>>? _complaintsSubscription;
  StreamSubscription<List<MeasurementRequest>>? _measurementRequestsSubscription; // Added
  DateTime _lastUpdate = DateTime.now();

  Future<void> _setupRealtimeListeners() async {
    // Call measurement requests listener setup
    await _loadMeasurementRequests();
    await Future.delayed(const Duration(milliseconds: 200));

    // Initialize listeners with small delays to avoid browser concurrent target limits
    _designsSubscription = _designsService.streamDesigns().listen(
      (designs) {
        if (mounted && DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
          _lastUpdate = DateTime.now();
          setState(() {
            _designs = designs;
          });
        } else if (mounted) {
          _designs = designs;
        }
      },
      onError: (e) => print('Designs Stream Error: $e'),
    );
    await Future.delayed(const Duration(milliseconds: 200));

    _bookingsSubscription = _bookingsService.streamAllBookings().listen(
      (allBookings) {
        if (mounted) {
          final myBookings = _customerName != null
              ? allBookings.where((b) => b.customerName == _customerName).toList()
              : <models.Booking>[];
          
          if (DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
            _lastUpdate = DateTime.now();
            setState(() {
              _myBookings = myBookings;
              _allBookings = allBookings; // Fix: Update allBookings for calendar
            });
          } else {
            _myBookings = myBookings;
            _allBookings = allBookings;
          }
        }
      },
      onError: (e) => print('Bookings Stream Error: $e'),
    );
    await Future.delayed(const Duration(milliseconds: 200));

    _pickupSubscription = _pickupService.streamRequests().listen(
      (allRequests) {
        if (mounted) {
          final myPickupRequests =
              (_customerEmail != null || _customerName != null)
                  ? allRequests
                      .where((p) =>
                          (_customerEmail != null && p.customerEmail == _customerEmail) ||
                          (_customerName != null && p.customerName == _customerName))
                      .toList()
                      : <models.PickupRequest>[];
          if (DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
            _lastUpdate = DateTime.now();
            setState(() {
              _myPickupRequests = myPickupRequests;
            });
          } else {
            _myPickupRequests = myPickupRequests;
          }
        }
      },
      onError: (e) => print('Pickup Stream Error: $e'),
    );
    await Future.delayed(const Duration(milliseconds: 200));

    _complaintsSubscription = _complaintsService.streamComplaints().listen(
      (allComplaints) {
        if (mounted) {
          final myComplaints = (_customerEmail != null || _customerName != null)
              ? allComplaints
                  .where((c) =>
                      (_customerEmail != null && c.customerEmail == _customerEmail) ||
                      (_customerName != null && c.customerName == _customerName))
                  .toList()
              : <models.Complaint>[];
          
          if (DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
            _lastUpdate = DateTime.now();
            setState(() {
              _myComplaints = myComplaints;
            });
          } else {
            _myComplaints = myComplaints;
          }
        }
      },
      onError: (e) => print('Complaints Stream Error: $e'),
    );
  }

  @override
  void dispose() {
    _designsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _pickupSubscription?.cancel();
    _complaintsSubscription?.cancel();
    _measurementRequestsSubscription?.cancel(); // Added
    _animationController.dispose();
    _scrollController.dispose();
    _complaintSubjectController.dispose();
    _complaintMessageController.dispose();
    _pickupAddressController.dispose();
    _pickupNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _customerName = userData['name'] as String? ?? user.displayName;
          _customerEmail = user.email;
          _customerPhone = userData['phone'] as String?;
          _customerWhatsapp = userData['whatsapp'] as String?;
          _customerProfilePic = userData['photoUrl'] as String?;
        });
      } else {
        setState(() {
          _customerName = user.displayName;
          _customerEmail = user.email;
        });
      }
      
      // Load measurement if email available
      if (_customerEmail != null) {
         try {
           final m = await _measurementsService.getByCustomerEmail(_customerEmail!);
           if (mounted) setState(() => _measurement = m);
         } catch (e) {
           print('Error fetching measurement: $e');
         }
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Load data in parallel for better performance
      final results = await Future.wait([
        _tailorService.getTailor(),
        _designsService.getAllDesigns(),
        _bookingsService.getAllBookings(),
        _pickupService.getAllRequests(),
      ], eagerError: false);
      
      if (!mounted) return;
      
      var tailor = results[0] as models.Tailor?;
      var designs = results[1] as List<models.Design>;

      // Self-healing: If data is missing (fresh install scenario), seed it now.
      if (tailor == null || designs.isEmpty) {
         print('Data missing, attempting to seed Firestore...');
         await SeedDataService.seedData(); 
         // Retry fetch for tailor and designs
         if (tailor == null) tailor = await _tailorService.getTailor();
         if (designs.isEmpty) designs = await _designsService.getAllDesigns();
      }
      
      final allBookings = results[2] as List<models.Booking>;
      final allPickupRequests = results[3] as List<models.PickupRequest>;

      final List<models.Booking> myBookings = _customerName != null
          ? allBookings.where((b) => b.customerName == _customerName).toList()
          : <models.Booking>[];

      final List<models.PickupRequest> myPickupRequests =
          (_customerEmail != null || _customerName != null)
              ? allPickupRequests
                  .where((p) =>
                      (_customerEmail != null && p.customerEmail == _customerEmail) ||
                      (_customerName != null && p.customerName == _customerName))
                  .toList()
              : <models.PickupRequest>[];

      setState(() {
        _tailor = tailor;
        _designs = designs;
        _myBookings = myBookings;
        _allBookings = allBookings;
        _myPickupRequests = myPickupRequests;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('🚨 ERROR LOADING CUSTOMER DASHBOARD DATA: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _loadData),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: AnimatedSewingLoader(
          message: 'Preparing your studio...',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grace Tailor Studio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
             icon: const Icon(Icons.notifications_none, color: Colors.white),
             onPressed: () {
                // Future: Notifications panel
             },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Tab 0: Home (Tailor Info + Announcement)
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                   CustomerTailorInfoTab(tailor: _tailor),
                   if (_tailor?.announcement != null && _tailor!.announcement!.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                       child: AnnouncementCard(announcement: _tailor!.announcement!),
                     ),
                   const SizedBox(height: 80), // Padding for bottom bar
                ],
              ),
            ),

            // Tab 1: Designs
            CustomerDesignsTab(
              designs: _designs,
              tailor: _tailor,
              customerName: _customerName,
              customerEmail: _customerEmail,
              customerPhone: _customerPhone,
            ),

            // Tab 2: Bookings
            CustomerBookingsTab(
                          tailor: _tailor,
                          allBookings: _allBookings,
                          myBookings: _myBookings,
                          customerName: _customerName,
                          customerEmail: _customerEmail,
                          customerPhone: _customerPhone,
                          onBookingAdded: (booking) {
                            setState(() {
                              _myBookings.add(booking);
                              _allBookings.add(booking);
                            });
                          },
                          onBookingRemoved: (booking) {
                            setState(() {
                              _myBookings.removeWhere((b) =>
                                  b.bookingDate == booking.bookingDate &&
                                  b.timeSlot == booking.timeSlot);
                              _allBookings.removeWhere((b) =>
                                  b.bookingDate == booking.bookingDate &&
                                  b.timeSlot == booking.timeSlot);
                            });
                          },
                        ),
            
            // Tab 3: Measurements
            CustomerMeasurementsTab(
                          tailor: _tailor,
                          measurement: _measurement,
                          measurementRequests: _myMeasurementRequests,
                          customerName: _customerName,
                          customerEmail: _customerEmail,
                          customerPhone: _customerPhone,
                          onUpdateMeasurement: (m) => setState(() => _measurement = m),
                        ),

            // Tab 4: Pickup
            CustomerPickupTab(
                           pickupRequests: _myPickupRequests,
                           customerName: _customerName,
                           customerEmail: _customerEmail,
                           customerPhone: _customerPhone,
                           onRefresh: _loadData,
            ),

            // Tab 5: Complaints
            CustomerComplaintsTab(
                          tailor: _tailor,
                          customerName: _customerName,
                          customerEmail: _customerEmail,
                          customerId: _authService.currentUser?.uid,
                          onRefresh: _loadData,
            ),
          ],
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          return BottomNavigationBar(
            currentIndex: _selectedTabIndex,
            onTap: (index) => setState(() => _selectedTabIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: isNarrow ? 10 : 12,
            unselectedFontSize: isNarrow ? 9 : 10,
            iconSize: isNarrow ? 20 : 24,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Designs'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
              BottomNavigationBarItem(icon: Icon(Icons.straighten), label: 'Measure'),
              BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Pickup'),
              BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Issues'),
            ],
          );
        },
      ),
    );
  }

  // Animation Helper
  Widget _buildAnimatedSection(Widget child, int index) {
    // Simple staggered fade in
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final delay = index * 0.1;
        final value = (_animationController.value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30.0 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    final activeBookings = _myBookings.where((b) => b.status != 'completed' && b.status != 'cancelled').length;
    final pendingPickups = _myPickupRequests.where((p) => p.status != 'delivered' && p.status != 'completed').length;
    final openComplaints = _myComplaints.where((c) => c.status.toLowerCase() != 'resolved').length;
    final totalDesigns = _designs.length;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Custom Header with Stats
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    // Profile Row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _openEditCustomerProfilePanel,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            backgroundImage: (_customerProfilePic != null) ? _getProfileImageProvider(_customerProfilePic!) : null,
                            child: (_customerProfilePic == null) ? const Icon(Icons.person, size: 32, color: Color(0xFF6366F1)) : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _customerName ?? 'Valued Customer',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _customerEmail ?? '',
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _openEditCustomerProfilePanel,
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDrawerStat('Bookings', activeBookings, Icons.calendar_today),
                          _buildDrawerStat('Designs', totalDesigns, Icons.checkroom),
                          _buildDrawerStat('Issues', openComplaints, Icons.forum),
                          _buildDrawerStat('Pickups', pendingPickups, Icons.local_shipping),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile(0, Icons.home_outlined, 'Home'),
                _buildDrawerTile(1, Icons.checkroom_outlined, 'Designs Library'),
                _buildDrawerTile(2, Icons.calendar_today_outlined, 'My Bookings'),
                _buildDrawerTile(3, Icons.straighten_outlined, 'Measurements'),
                _buildDrawerTile(4, Icons.local_shipping_outlined, 'Pickup Requests'),
                _buildDrawerTile(5, Icons.forum_outlined, 'Support & Complaints'),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
               Navigator.pop(context);
               _handleLogout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerStat(String label, int count, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildDrawerTile(int index, IconData icon, String title) {
    final isSelected = _selectedTabIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[700]),
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[800], 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() => _selectedTabIndex = index);
      },
      selected: isSelected,
      selectedTileColor: const Color(0xFF4F46E5).withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _scrollToSection(double offset) {
     // A naive scroll implementation. For precision, GlobalKeys would be better, but this suffices for "Implicit".
     _scrollController.animateTo(offset, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
  }

  Future<void> _handleLogout() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
          ],
        ),
      );
      if (confirm == true) {
        await _authService.signOut();
      }
  }

  void _openEditCustomerProfilePanel() {
    final nameController = TextEditingController(text: _customerName);
    final phoneController = TextEditingController(text: _customerPhone);
    final whatsappController = TextEditingController(text: _customerWhatsapp);
    final _formKey = GlobalKey<FormState>();
    XFile? selectedImage;
    bool isUploading = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 16,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
              ),
              child: StatefulBuilder(
                builder: (context, setPanelState) => Form(
                  key: _formKey,
                  child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                          ),
                          const SizedBox(width: 16),
                          const Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final image = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 70);
                                      if (image != null) setPanelState(() => selectedImage = image);
                                    },
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: selectedImage != null 
                                        ? (kIsWeb ? NetworkImage(selectedImage!.path) : FileImage(File(selectedImage!.path))) as ImageProvider
                                        : (_customerProfilePic != null ? _getProfileImageProvider(_customerProfilePic!) : null),
                                      child: (selectedImage == null && _customerProfilePic == null) ? const Icon(Icons.person, size: 60) : null,
                                    ),
                                  ),
                                  Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.blue, radius: 18, child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Activity Stats Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF4F46E5).withOpacity(0.1), const Color(0xFF6366F1).withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.analytics, color: const Color(0xFF4F46E5), size: 20),
                                      const SizedBox(width: 8),
                                      const Text('My Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: _buildProfileStatCard('Bookings', _myBookings.where((b) => b.status != 'completed' && b.status != 'cancelled').length, Icons.calendar_today, Colors.blue)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildProfileStatCard('Designs', _designs.length, Icons.checkroom, Colors.purple)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _buildProfileStatCard('Complaints', _myComplaints.where((c) => c.status.toLowerCase() != 'resolved').length, Icons.forum, Colors.orange)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildProfileStatCard('Pickups', _myPickupRequests.where((p) => p.status != 'delivered' && p.status != 'completed').length, Icons.local_shipping, Colors.green)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildPanelField('Name', nameController, Icons.person, validator: AppValidators.validateName),
                            const SizedBox(height: 16),
                            _buildPanelField('Phone', phoneController, Icons.phone, validator: AppValidators.validatePhone, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildPanelField('WhatsApp', whatsappController, Icons.chat, validator: AppValidators.validateOptionalPhone, keyboardType: TextInputType.phone),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        onPressed: isUploading ? null : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setPanelState(() => isUploading = true);
                          try {
                            String? photoUrl = _customerProfilePic;
                            if (selectedImage != null) {
                              final bytes = await selectedImage!.readAsBytes();
                              photoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                            }
                            await _authService.updateUserData(_authService.currentUser!.uid, {
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'whatsapp': whatsappController.text.trim(),
                              'photoUrl': photoUrl,
                            });
                            await _loadUserData();
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            setPanelState(() => isUploading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        child: isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, a, sa, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(a), child: child),
    );
  }

  ImageProvider? _getProfileImageProvider(String photo) {
    if (photo.startsWith('data:')) {
      final parts = photo.split(',');
      if (parts.length > 1) {
        return MemoryImage(base64Decode(parts[1]));
      }
    }
    return CachedNetworkImageProvider(photo);
  }

  Widget _buildPanelField(String label, TextEditingController controller, IconData icon, {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
    );
  }

  Widget _buildProfileStatCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }


  Future<void> _loadMeasurementRequests() async {
     await _measurementRequestsSubscription?.cancel();
     final user = _authService.currentUser;
     if (user != null) {
       _measurementRequestsSubscription = _measurementRequestsService
           .streamCustomerRequests(user.uid)
           .listen(
         (requests) {
           if (mounted) {
             setState(() {
               _myMeasurementRequests = requests;
             });
           }
         },
         onError: (e) => print('Measurement Requests Stream Error: $e'),
       );
     }
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 450;
          if (isNarrow) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Bookings',
                            _myBookings.where((b) => b.status != 'completed' && b.status != 'cancelled').length.toString(),
                            Icons.event,
                            Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Designs',
                            _designs.length.toString(),
                            Icons.design_services,
                            Colors.purple)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Complaints',
                            _myComplaints.where((c) => c.status != 'resolved').length.toString(),
                            Icons.message,
                            Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Pickups',
                            _myPickupRequests.where((p) => p.status != 'delivered').length.toString(),
                            Icons.local_shipping,
                            Colors.green)),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Bookings',
                  _myBookings.where((b) => b.status != 'completed' && b.status != 'cancelled').length.toString(),
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Designs',
                  _designs.length.toString(),
                  Icons.design_services,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Complaints',
                  _myComplaints.where((c) => c.status != 'resolved').length.toString(),
                  Icons.message,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pickups',
                   _myPickupRequests.where((p) => p.status != 'delivered').length.toString(),
                  Icons.local_shipping,
                  Colors.green,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.purple : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.purple : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
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
