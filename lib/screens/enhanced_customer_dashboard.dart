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

import 'measurements_screen.dart';
import 'pickup_request_screen.dart';
import '../widgets/measurement_dummy.dart';
import '../services/auth_service.dart';
import '../services/firestore_designs_service.dart';
import '../services/firestore_bookings_service.dart';
import '../services/firestore_complaints_service.dart';
import '../services/firestore_pickup_requests_service.dart';
import '../services/firestore_tailor_service.dart';
import '../services/firestore_measurements_service.dart';
import '../services/firestore_faq_service.dart';
import '../services/firestore_notification_service.dart';
import '../services/firestore_measurement_requests_service.dart'; // Added
import '../widgets/communication_section.dart';
import '../widgets/unified_profile_card.dart';
import '../widgets/request_measurement_dialog.dart';
import '../widgets/measurement_receipt.dart';
import '../widgets/status_badge.dart';
import '../widgets/notification_bell.dart';
import '../widgets/conversation_thread.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class EnhancedCustomerDashboard extends StatefulWidget {
  const EnhancedCustomerDashboard({super.key});

  @override
  State<EnhancedCustomerDashboard> createState() => _EnhancedCustomerDashboardState();
}

class _EnhancedCustomerDashboardState extends State<EnhancedCustomerDashboard>
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
  int _selectedTabIndex = 0; // For bottom navigation

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

  void _setupRealtimeListeners() {
    // Call measurement requests listener setup
    _loadMeasurementRequests();

    // Debounce updates to prevent excessive rebuilds (max once per 500ms)
    _designsSubscription = _designsService.streamDesigns().listen((designs) {
      if (mounted && DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
        _lastUpdate = DateTime.now();
        setState(() {
          _designs = designs;
        });
      } else if (mounted) {
        _designs = designs;
      }
    });

    _bookingsSubscription = _bookingsService.streamAllBookings().listen((allBookings) {
      if (mounted) {
        final myBookings = _customerName != null
            ? allBookings.where((b) => b.customerName == _customerName).toList()
            : <models.Booking>[];
        if (DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
          _lastUpdate = DateTime.now();
          setState(() {
            _myBookings = myBookings;
          });
        } else {
          _myBookings = myBookings;
        }
      }
    });

    _pickupSubscription = _pickupService.streamRequests().listen((allRequests) {
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
    });

    _complaintsSubscription = _complaintsService.streamComplaints().listen((allComplaints) {
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
    });
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
      
      final tailor = results[0] as models.Tailor?;
      final designs = results[1] as List<models.Design>;
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
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, $_customerName',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)], // Indigo gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          const NotificationBell(),
  // Logout logic moved to helper
            IconButton(
             icon: const Icon(Icons.logout, color: Colors.white),
             onPressed: _handleLogout,
            ),
          ],
        ),

              // Drawer for "Implicit Access"
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(_customerName ?? 'Valued Customer'),
                      accountEmail: Text(_customerEmail ?? ''),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: _customerProfilePic != null ? NetworkImage(_customerProfilePic!) : null,
                        child: _customerProfilePic == null ? const Icon(Icons.person, size: 40) : null,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                      ),
                    ),
                    ListTile(leading: const Icon(Icons.store), title: const Text('Shop'), onTap: () { Navigator.pop(context); _scrollToSection(0); }),
                    // Added Profile Edit Item
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.indigo),
                      title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      onTap: () {
                         Navigator.pop(context); // Close drawer
                         _openEditCustomerProfilePanel(); 
                      },
                    ),
                    ListTile(leading: const Icon(Icons.checkroom), title: const Text('Designs'), onTap: () { Navigator.pop(context); _scrollToSection(280); }),
                    ListTile(leading: const Icon(Icons.calendar_today), title: const Text('Bookings'), onTap: () { Navigator.pop(context); _scrollToSection(550); }),
                    ListTile(leading: const Icon(Icons.straighten), title: const Text('Measurements'), onTap: () { Navigator.pop(context); _scrollToSection(900); }),
                    ListTile(leading: const Icon(Icons.local_shipping), title: const Text('Pickup Requests'), onTap: () { Navigator.pop(context); _scrollToSection(1300); }),
                    ListTile(leading: const Icon(Icons.forum), title: const Text('Support'), onTap: () { Navigator.pop(context); _scrollToSection(1800); }),
                    const Divider(),
                    ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: () => _handleLogout()),
                  ],
                ),
              ),

              // Single Scroll Body with Animations
              body: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animate Sections
                      _buildAnimatedSection(_buildTailorInfoSection(), 0),
                      const SizedBox(height: 24),
                      
                      _buildAnimatedSection(_buildDesignsSection(), 1),
                      const SizedBox(height: 24),
                      
                      _buildAnimatedSection(_buildBookingsSection(), 2),
                      const SizedBox(height: 24),
                      
                      _buildAnimatedSection(_buildMeasurementsSection(), 3),
                      const SizedBox(height: 24),

                      _buildAnimatedSection(_buildPickupRequestsSection(), 4),
                      const SizedBox(height: 24),
                      
                      _buildAnimatedSection(_buildComplaintsSection(), 5),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // BottomNavigationBar Removed
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


  Widget _buildTailorInfoSection() {
    final tailor = _tailor;
    if (tailor == null) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: Text('Tailor information not available yet.'),
        ),
      );
    }

    return UnifiedProfileCard(
      name: tailor.name,
      description: tailor.description,
      photoUrl: tailor.photo,
      infoChips: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1f455b).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF1f455b)),
              const SizedBox(width: 8),
              Text(
                tailor.shopHours ?? 'Mon-Sat: 9 AM - 7 PM',
                style: const TextStyle(
                  color: Color(0xFF1f455b),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
      quickActions: [
        ProfileQuickAction(
          icon: Icons.chat_bubble_outline,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () async {
            if (tailor.whatsapp != null && tailor.whatsapp!.isNotEmpty) {
              final clean = tailor.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '');
              final url = Uri.parse('https://wa.me/$clean');
              if (await canLaunchUrl(url)) launchUrl(url);
            }
          },
        ),
        ProfileQuickAction(
          icon: Icons.phone_outlined,
          label: 'Call',
          color: const Color(0xFF1f455b),
          onTap: () async {
            if (tailor.phone != null && tailor.phone!.isNotEmpty) {
              final url = Uri.parse('tel:${tailor.phone}');
              if (await canLaunchUrl(url)) launchUrl(url);
            }
          },
        ),
        ProfileQuickAction(
          icon: Icons.mail_outline,
          label: 'Email',
          color: Colors.blueAccent,
          onTap: () async {
            if (tailor.email != null && tailor.email!.isNotEmpty) {
              final url = Uri.parse('mailto:${tailor.email}');
              if (await canLaunchUrl(url)) launchUrl(url);
            }
          },
        ),
        ProfileQuickAction(
          icon: Icons.location_on_outlined,
          label: 'Map',
          color: Colors.redAccent,
          onTap: () async {
            if (tailor.location != null && tailor.location!.isNotEmpty) {
              final query = Uri.encodeComponent(tailor.location!);
              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
              if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomerProfileSection() {
    return UnifiedProfileCard(
      name: _customerName ?? 'Valued Customer',
      description: 'Member since 2024',
      photoUrl: _customerProfilePic,
      onEdit: _openEditCustomerProfilePanel,
      infoChips: [
        if (_customerPhone != null && _customerPhone!.isNotEmpty)
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
            child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                 const SizedBox(width: 4),
                 Text(_customerPhone!, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
               ],
            ),
           ),
        if (_customerWhatsapp != null && _customerWhatsapp!.isNotEmpty)
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.chat_bubble, size: 14, color: Colors.green),
                 const SizedBox(width: 4),
                 Text(_customerWhatsapp!, style: TextStyle(fontSize: 12, color: Colors.green[700])),
               ],
            ),
           ),
        if (_customerEmail != null)
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
            child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.email, size: 14, color: Colors.grey[600]),
                 const SizedBox(width: 4),
                 Text(_customerEmail!, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
               ],
            ),
           ),
      ],
      extraContent: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.tune, color: Colors.indigo),
            ),
            title: const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Style and fit preferences'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences coming soon!')));
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.straighten, color: Colors.teal),
            ),
            title: const Text('My Measurements', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('View and update your body stats'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
             onTap: () {
               setState(() => _selectedTabIndex = 4); // Switch to Measurement Tab
             },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
               await _authService.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Book Now button removed as per dashboard integration
          /*
          Expanded(
            child: _buildActionCard(
              'Book Now',
              Icons.event,
              Colors.blue,
              () {
                 // Scroll to booking section if meaningful, or just remove.
                 // For now, disabling to fix compilation.
              },
            ),
          ),
          */
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              'Measurements',
              Icons.straighten,
              Colors.purple,
              () async {
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
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              'Pickup',
              Icons.local_shipping,
              Colors.orange,
              () async {
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesignsSection() {
    return _buildSection(
      title: 'Available Designs',
      icon: Icons.design_services,
      child: _designs.isEmpty
          ? _buildEmptyState('No designs available', 'Check back later!', Icons.design_services)
          : SizedBox(
              height: 240, // Increased height for scale effect
              child: PageView.builder(
                controller: _designsController,
                itemCount: _designs.length,
                onPageChanged: (index) {
                   _currentDesignIndex = index;
                },
                itemBuilder: (context, index) {
                   // Calculate scale for carousel effect
                   return AnimatedBuilder(
                     animation: _designsController,
                     builder: (context, child) {
                       double value = 1.0;
                       if (_designsController.position.haveDimensions) {
                         value = _designsController.page! - index;
                         value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                       }
                       return Center(
                         child: SizedBox(
                           height: Curves.easeOut.transform(value) * 240,
                           width: Curves.easeOut.transform(value) * 350,
                           child: child,
                         ),
                       );
                     },
                     child: _buildDesignCard(_designs[index], index),
                   );
                },
              ),
            ),
    );
  }

  Widget _buildDesignCard(models.Design design, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: design.photo != null && design.photo!.isNotEmpty
                      ? (design.photo!.startsWith('data:')
                          ? Image.memory(
                              base64Decode(design.photo!.split(',')[1]),
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: design.photo!,
                              fit: BoxFit.cover,
                            ))
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      design.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${design.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsSection() {
    return _buildSection(
      title: 'Booking Calendar',
      icon: Icons.event,
      child: Column(
        children: [
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
             Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Upcoming Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_myBookings.length > 2)
                      TextButton(
                        onPressed: () => _showAllBookings(),
                        child: const Text('View All'),
                      ),
                  ],
                ),
              ),
            ..._myBookings.take(2).map((b) => _buildBookingCard(b)),
          ],
        ],
      ),
    );
  }

  void _showAllBookings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
             Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('All Bookings (${_myBookings.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _myBookings.length,
                itemBuilder: (context, index) => _buildBookingCard(_myBookings[index]),
              ),
            ),
          ],
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instant Booking Preferences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suitTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final type = _suitTypes[index];
                    final isSelected = _selectedSuitType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedSuitType = selected ? type : _suitTypes.first);
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   // Urgency toggle removed as per request
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: upcomingDays.map((date) => _buildDayColumn(date, timeSlots)).toList(),
          ),
        ),
      ],
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
          ...timeSlots.map((slot) => _buildTimeSlotCard(date, slot)).toList(),
        ],
      ),
    );
  }

  // Booking State
  String _selectedSuitType = 'Formal Suit';
  // Urgency removed as per Silent UX requirements

  final List<String> _suitTypes = [
    'Formal Suit',
    'Casual Blazer',
    'Wedding Suit',
    'Tuxedo',
    'Designer Suit',
    'Custom Tailored',
  ];

  Future<void> _processBooking(DateTime date, String slot) async {
    // 1. Validate User Info
    if (_customerName == null || _customerName!.isEmpty ||
        _customerEmail == null || _customerEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please update your profile with name and email first.')),
      );
      return;
    }

    // 2. Check if already booked (Optimistic)
    final isBooked = _allBookings.any((b) => 
      b.bookingDate.year == date.year && 
      b.bookingDate.month == date.month && 
      b.bookingDate.day == date.day &&
      b.timeSlot == slot && 
      (b.status == 'pending' || b.status == 'approved' || b.status == 'completed')
    );

    if (isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This slot is already booked.')),
      );
      return;
    }

    // 3. Create Booking
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final booking = models.Booking(
      userId: userId,
      customerName: _customerName!,
      customerEmail: _customerEmail!,
      customerPhone: _customerPhone ?? '',
      bookingDate: date,
      timeSlot: slot,
      suitType: _selectedSuitType,
      isUrgent: false, 
      charges: 299.99, 
      status: 'pending',
    );

    try {
      // Optimistic Update
      setState(() {
        _allBookings.add(booking);
        if (_customerName != null) {
          _myBookings.add(booking);
        }
        _pendingBookingSlot = null; // Clear selection
        _pendingBookingDate = null;
      });

      final createdBooking = await _bookingsService.addBooking(booking);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
              textColor: Colors.white,
              onPressed: () => _undoBooking(createdBooking.docId),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update
      setState(() {
        _allBookings.remove(booking);
        _myBookings.remove(booking);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    }
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
      // Let stream handle UI updates, just show error
      debugPrint('Undo failed: $e');
    }
  }

  void _showConfirmationDialog(DateTime date, String slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Date', DateFormat('MMM d, yyyy').format(date)),
            _detailRow('Time', slot),
            _detailRow('Service', _selectedSuitType),
            _detailRow('Price', '\$299.99'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Confirm Booking', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ... (keeping helper)

  Widget _buildTimeSlotCard(DateTime date, String slotTime) {
    // Find booking for this slot
    final booking = _allBookings.firstWhere(
      (b) => b.bookingDate.year == date.year && 
             b.bookingDate.month == date.month && 
             b.bookingDate.day == date.day &&
             b.timeSlot == slotTime &&
             (b.status == 'pending' || b.status == 'approved' || b.status == 'completed'),
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
    final isMyBooking = booking.userId == FirebaseAuth.instance.currentUser?.uid;
    
    // Selection Logic
    final bool isSelected = isAvailable && 
                            _pendingBookingDate != null && 
                            _pendingBookingSlot == slotTime &&
                            _pendingBookingDate!.year == date.year &&
                            _pendingBookingDate!.month == date.month &&
                            _pendingBookingDate!.day == date.day;

    // Visuals
    Color borderColor;
    Color bgColor;
    Color iconColor;
    
    if (isAvailable) {
      if (isSelected) {
        borderColor = Colors.blue;
        bgColor = Colors.blue.withOpacity(0.05);
        iconColor = Colors.blue;
      } else {
        borderColor = Colors.grey.shade300;
        bgColor = Colors.white;
        iconColor = Colors.grey;
      }
    } else if (isMyBooking) {
      borderColor = Colors.green;
      bgColor = Colors.white;
      iconColor = Colors.green;
    } else {
      borderColor = Colors.purple;
      bgColor = Colors.white;
      iconColor = Colors.purple;
    }

    return GestureDetector(
      onTap: isAvailable ? () {
        // Trigger Dialog Immediately + Select
        setState(() {
          _pendingBookingDate = date;
          _pendingBookingSlot = slotTime;
        });
        _showConfirmationDialog(date, slotTime);
      } : null,
      onLongPress: isAvailable ? () {
        setState(() {
            _pendingBookingDate = date;
            _pendingBookingSlot = slotTime;
        });
        _showConfirmationDialog(date, slotTime);
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 3 : (isAvailable ? 1 : 2),
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(
              isAvailable ? Icons.dry_cleaning : Icons.checkroom, 
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              slotTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAvailable 
                ? (isSelected ? 'SELECTED' : 'AVAILABLE')
                : (isMyBooking ? 'YOURS' : 'BOOKED'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: iconColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper
  dynamic _getConfiguredDateFormat(String pattern) {
    return _SimpleDateFormatter(pattern);
  }

  Widget _buildBookingCard(models.Booking booking) {
    final statusColor = AppTheme.getStatusColor(booking.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceSm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppTheme.spaceMd),
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.15),
            radius: 24,
            child: Icon(
              _getStatusIcon(booking.status),
              color: statusColor,
              size: 24,
            ),
          ),
          title: Text(
            booking.suitType,
            style: AppTheme.titleLarge,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppTheme.spaceXs),
            child: Text(
              '${_formatDate(booking.bookingDate)} • \$${booking.charges.toStringAsFixed(2)}',
              style: AppTheme.bodySmall,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceXs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              booking.status.toUpperCase(),
              style: AppTheme.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Measurements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f455b),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showRequestMeasurementDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Request New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1f455b),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
        
        // Active Requests
        if (_myMeasurementRequests.isNotEmpty)
          Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _myMeasurementRequests.length,
              itemBuilder: (context, index) {
                final req = _myMeasurementRequests[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge(status: req.status),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d').format(req.requestedAt),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${req.requestType == 'new' ? 'New Measurement' : 'Renewal Request'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        req.notes ?? 'No notes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        _customerEmail == null
            ? _buildEmptyState('Email required', 'Please provide your email', Icons.email)
            : (_measurement == null
                ? _buildDefaultMeasurementCard()
                : _buildCustomerMeasurementDetail(_measurement!)),
      ],
    );
  }

  Widget _buildCustomerMeasurementDetail(models.Measurement m) {
    bool isAccepted = m.status == 'Accepted';
    
    // Combine standard and dynamic measurements for display
    Map<String, double> displayed = Map.from(m.measurements);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.person, color: Colors.teal.shade700, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Measured: ${_formatDate(m.createdAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button (like in template)
                if (!isAccepted)
                  IconButton(
                    onPressed: () {
                      // TODO: Show update measurements dialog
                    },
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                  ),
              ],
            ),

            const SizedBox(height: 24),
            
            // Request Button
            if (!m.updateRequested && m.status != 'Accepted') 
               Container(
                 margin: const EdgeInsets.only(bottom: 24),
                 width: double.infinity,
                 child: ElevatedButton.icon(
                   onPressed: () {
                     showDialog(
                       context: context,
                       builder: (c) => RequestMeasurementDialog(
                         onSubmit: (type, date, notes) async {
                           final updated = m.copyWith(
                             updateRequested: true,
                             requestType: type,
                             appointmentDate: date,
                             messages: [
                               ...m.messages, 
                               if (notes.isNotEmpty) 
                                 {'sender': 'customer', 'text': 'Request Notes: $notes', 'timestamp': DateTime.now().toIso8601String()}
                             ],
                             status: 'Pending', 
                           );
                           await _measurementsService.insertOrUpdate(updated);
                           setState(() {});
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent to tailor!')));
                           }
                         },
                       ),
                     );
                   },
                   icon: const Icon(Icons.touch_app),
                   label: const Text('Request Measurements / Visit'),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppTheme.accentAmber, 
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.all(AppTheme.spaceMd),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                   ),
                 ),
               ),

            // Enhanced Measurement Display (Responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildMeasurementList(displayed)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildVisualGuide()),
                    ],
                  );
                } else {
                  return Column(
                     children: [
                       _buildVisualGuide(),
                       const SizedBox(height: 24),
                       _buildMeasurementList(displayed),
                     ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showUpdateMeasurementsDialog(m);
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Update / Request Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeasurementReceipt(
                            measurement: m,
                            tailorName: _tailor?.name,
                            tailorPhone: _tailor?.phone,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print, size: 20),
                    label: const Text('Print Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Status info
            if (!isAccepted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Review your measurements and accept to start stitching',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Accept Measurements'),
                        content: const Text('Are you sure you want to accept these measurements? Once accepted, stitching will begin.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final updated = m.copyWith(status: 'Accepted');
                      await _measurementsService.insertOrUpdate(updated);
                      setState(() {});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Measurements accepted! Stitching will begin.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accept Measurements'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Measurements accepted - Stitching in progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Communication / Messages Section
            if (m.messages.isNotEmpty || m.updateRequested) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Communication with Tailor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (m.updateRequested)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Update Requested - Waiting for tailor response',
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              CommunicationSection(
                measurement: m,
                isTailor: false,
                onUpdate: (updated) async {
                  setState(() => _measurement = updated);
                  await _measurementsService.insertOrUpdate(updated);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementList(Map<String, double> displayed) {
    return Column(
      children: displayed.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${e.value.toStringAsFixed(1)}"', 
                style: TextStyle(color: AppTheme.primaryIndigo, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisualGuide() {
    return Container(
      height: 300, 
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder for Mannequin Image
          Icon(Icons.accessibility, size: 180, color: Colors.grey.shade300),
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Visual Guide', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateMeasurementsDialog(models.Measurement m) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Measurement Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need changes? Send a request to the tailor explaining what needs to be adjusted.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message to Tailor',
                hintText: 'e.g., Please increase chest size by 1 inch...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;
              
              final newMessage = {
                'sender': 'customer',
                'text': messageController.text.trim(),
                'timestamp': DateTime.now().toIso8601String(),
              };
              
              final List<Map<String, dynamic>> updatedMessages = List.from(m.messages)..add(newMessage);
              
              final updatedMeasurement = m.copyWith(
                updateRequested: true,
                messages: updatedMessages,
              );
              
              await _measurementsService.insertOrUpdate(updatedMeasurement);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent to tailor!')),
                );
              }
              // Force refresh
              setState(() {}); 
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementChip(String label, double value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.teal[800]), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _showAcceptConfirmation(models.Measurement m) {
    final noteController = TextEditingController(text: m.specialInstructions);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Measurements?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Once accepted, you cannot change these details. The tailor will begin stitching based on these measurements.'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Final Instructions / Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
               // Update status and special instructions
               final updated = m.copyWith(
                 status: 'Accepted',
                 stitchingStarted: true, // Auto start logic per requirements? "Stitching process must start". Usually manual for tailor, but requirements say "When customer accepts... stitching_started: true".
                 stitchingStartDate: DateTime.now(),
                 specialInstructions: noteController.text,
               );
               await _measurementsService.insertOrUpdate(updated);
               if (context.mounted) Navigator.pop(context);
               setState(() {});
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Measurements Accepted! Stitching Started.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Confirm & Accept'),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupRequestsSection() {
    int pending = _myPickupRequests.where((r) => r.status == 'pending').length;
    int accepted = _myPickupRequests.where((r) => r.status == 'accepted').length;
    int completed = _myPickupRequests.where((r) => r.status == 'completed').length;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
         if(false) ...[ // Using false to hide original simplistic header logic if present, keeping custom header below
         ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Dashboard',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your pickups and deliveries',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Summary Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Pending', pending.toString(), Icons.pending, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Accepted', accepted.toString(), Icons.check_circle_outline, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Received', completed.toString(), Icons.home_filled, Colors.green)),
            ],
          ),

          const SizedBox(height: 24),

          // Inline Request Form (Collapsible/Card)
          ExpansionTile(
            title: const Text('Request New Pickup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            leading: const Icon(Icons.add_circle, color: Colors.indigo),
            backgroundColor: Colors.indigo.withOpacity(0.05),
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.indigo.withOpacity(0.1))),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildPickupForm(), // Helper to be added
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Request History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (_myPickupRequests.isEmpty)
             _buildEmptyState('No pickup history', 'Your requests will appear here', Icons.history)
          else
            Column(
              children: _myPickupRequests.map((request) => _buildEnhancedPickupCard(request)).toList(), // Using enhanced card
            ),
        ],
      ),
    );
  }

  // Temporary placeholder for form until next step, preventing errors if I split this up
  Widget _buildPickupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Request Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          value: _pickupType,
          items: const [
            DropdownMenuItem(value: 'courier_pickup', child: Text('Courier Pickup (Sending Fabric)')),
            DropdownMenuItem(value: 'sewing_request', child: Text('Sewing Request')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _pickupType = v);
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pickupAddressController,
          decoration: InputDecoration(
            labelText: 'Address',
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
             filled: true,
             fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pickupNotesController,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
             filled: true,
             fillColor: Colors.white,
          ),
        ),
         const SizedBox(height: 16),
         ElevatedButton(
           onPressed: _submitPickupRequest,
           style: ElevatedButton.styleFrom(
             padding: const EdgeInsets.symmetric(vertical: 16),
             backgroundColor: Colors.indigo,
             foregroundColor: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           ),
           child: const Text('Submit Request'),
         ),
      ],
    );
  }

  // Reusing the enhanced card logic from Tailor dashboard but safe for customer
  Widget _buildEnhancedPickupCard(models.PickupRequest request) {
     return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _getStatusColor(request.status), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        title: Text(request.requestType == 'sewing_request' ? 'Sewing Request' : 'Pickup Request', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: ${request.status.toUpperCase()}'),
        leading: CircleAvatar(
           backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
           child: Icon(_getStatusIcon(request.status), color: _getStatusColor(request.status)),
        ),
        children: [
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 _detailRow('Date', _formatDate(request.requestedDate)),
                 _detailRow('Charges', '\$${request.charges.toStringAsFixed(2)}'),
                 if (request.notes != null) _detailRow('Notes', request.notes!),
                 const Divider(),
                 // Timeline visualization
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                     _statusStep('Pending', request.status == 'pending' || request.status == 'accepted' || request.status == 'completed', Colors.orange),
                     _statusStep('Accepted', request.status == 'accepted' || request.status == 'completed', Colors.blue),
                     _statusStep('Received', request.status == 'completed', Colors.green),
                   ],
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }
  
  Widget _statusStep(String label, bool isActive, Color color) {
    return Column(
      children: [
        Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? color : Colors.grey),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? color : Colors.grey)),
      ],
    );
  }

  void _showAddPickupRequestDialog() async {
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
  }

  // Stat card helper
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }




  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, {Widget? actionButton}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 24),
            actionButton,
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'approved':
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show measurement card with default values and "Request Measurement" button
  Widget _buildDefaultMeasurementCard() {
    // Default measurements matching tailor's template
    final defaultMeasurements = {
      'Chest': 0.0,
      'Shoulder': 0.0,
      'Sleeve': 0.0,
      'Neck': 0.0,
      'Waist': 0.0,
      'Hip': 0.0,
      'Kurta Length': 0.0,
      'Inseam': 0.0,
    };

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.person, color: Colors.teal.shade700, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customerName ?? 'Customer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'No measurements yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Measurement grid (Force Wrapped Row or Grid for better mobile look)
            LayoutBuilder(builder: (context, constraints) {
               return Wrap(
                 spacing: 12,
                 runSpacing: 12,
                 children: defaultMeasurements.entries.map((e) {
                    final width = (constraints.maxWidth - 24) / 2; // 2 cols
                    return SizedBox(
                       width: width.floorToDouble(),
                       child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 4),
                              const Text('--', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                       ),
                    );
                 }).toList(),
               );
            }),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRequestMeasurementDialog,
                    icon: const Icon(Icons.location_on, size: 20),
                    label: const Text('Request Measurement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Info text
            Center(
              child: Text(
                'Request an appointment with the tailor to get your measurements',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildComplaintsSection() {
    int open = _myComplaints.where((c) => !c.isResolved && (c.reply == null || c.reply!.isEmpty)).length;
    int inProgress = _myComplaints.where((c) => !c.isResolved && c.reply != null && c.reply!.isNotEmpty).length;
    int resolved = _myComplaints.where((c) => c.isResolved).length;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support Center',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We are here to help you',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Forced Row for Stats (User Request: "align the 3 boxes on a single row")
          Row(
            children: [
              Expanded(child: _buildStatCard('Open', open.toString(), Icons.error_outline, Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('In Progress', inProgress.toString(), Icons.timelapse, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Resolved', resolved.toString(), Icons.check_circle, Colors.green)),
            ],
          ),

          const SizedBox(height: 24),

          ExpansionTile(
            title: const Text('File a Complaint', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            leading: const Icon(Icons.edit_document, color: Colors.indigo),
            backgroundColor: Colors.indigo.withOpacity(0.05),
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.indigo.withOpacity(0.1))),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildComplaintForm(),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Complaint History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (_myComplaints.isEmpty)
             _buildEmptyState('No complaints filed', 'We hope you never need to!', Icons.sentiment_satisfied_alt)
          else
            Column(
              children: _myComplaints.map((c) => _buildEnhancedComplaintCard(c)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          value: _complaintCategory,
          items: const [
            DropdownMenuItem(value: 'quality', child: Text('Quality Issue')),
            DropdownMenuItem(value: 'delivery', child: Text('Delivery Delay')),
            DropdownMenuItem(value: 'fitting', child: Text('Fitting Problem')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _complaintCategory = v);
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _complaintSubjectController,
          decoration: InputDecoration(
            labelText: 'Subject',
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
             filled: true,
             fillColor: Colors.white,
          ),
        ),
         const SizedBox(height: 12),
        TextFormField(
          controller: _complaintMessageController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Message',
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
             filled: true,
             fillColor: Colors.white,
          ),
        ),
         const SizedBox(height: 16),
         ElevatedButton(
           onPressed: _submitComplaint,
           style: ElevatedButton.styleFrom(
             padding: const EdgeInsets.symmetric(vertical: 16),
             backgroundColor: Colors.indigo,
             foregroundColor: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           ),
           child: const Text('Submit Complaint'),
         ),
      ],
    );
  }

  Widget _buildEnhancedComplaintCard(models.Complaint c) {
    Color statusColor = c.isResolved ? Colors.green : (c.reply != null ? Colors.orange : Colors.red);
    IconData statusIcon = c.isResolved ? Icons.check_circle : (c.reply != null ? Icons.chat : Icons.warning);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        title: Text(c.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(c.category.toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        leading: CircleAvatar(
           backgroundColor: statusColor.withOpacity(0.1),
           child: Icon(statusIcon, color: statusColor),
        ),
        children: [
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(c.message, style: const TextStyle(color: Colors.black87)),
                 const SizedBox(height: 12),
                 if (c.reply != null && c.reply!.isNotEmpty) ...[
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.blue.shade50,
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: Colors.blue.shade100),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             const Icon(Icons.support_agent, size: 16, color: Colors.blue),
                             const SizedBox(width: 8),
                             Text('Tailor Response', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                           ],
                         ),
                         const SizedBox(height: 4),
                         Text(c.reply!, style: TextStyle(color: Colors.blue.shade900)),
                       ],
                     ),
                   ),
                 ] else if (!c.isResolved) ...[
                   Text('Waiting for response...', style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                 ],
               ],
             ),
           ),
        ],
      ),
    );
  }
  Future<void> _submitComplaint() async {
    if (_complaintSubjectController.text.isEmpty || _complaintMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final complaint = models.Complaint(
        customerName: _customerName ?? 'Anonymous',
        customerEmail: _customerEmail ?? '',
        subject: _complaintSubjectController.text,
        message: _complaintMessageController.text,
        category: _complaintCategory,
        status: 'open',
        createdAt: DateTime.now(),
        isResolved: false,
        replies: [],
      );

      await _complaintsService.addComplaint(complaint);
      
      _complaintSubjectController.clear();
      _complaintMessageController.clear();
      setState(() => _complaintCategory = 'quality');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting complaint: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitPickupRequest() async {
    if (_pickupAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an address'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final request = models.PickupRequest(
        customerName: _customerName ?? 'Anonymous',
        customerEmail: _customerEmail ?? '',
        customerPhone: _customerPhone ?? '',
        pickupAddress: _pickupAddressController.text,
        requestType: _pickupType,
        status: 'pending',
        charges: _pickupType == 'courier_pickup' ? 15.0 : 0.0,
        requestedDate: DateTime.now(),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
        notes: _pickupNotesController.text.isNotEmpty ? _pickupNotesController.text : null,
      );

      await _pickupService.addRequest(request);
      
      // Keep address for convenience, maybe? No, let's clear or keep as per typical UX.
      // Keeping address as it might be same.
      setState(() => _pickupType = 'courier_pickup');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup request submitted successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _openEditCustomerProfilePanel() {
    final nameController = TextEditingController(text: _customerName ?? '');
    final phoneController = TextEditingController(text: _customerPhone ?? '');
    final whatsappController = TextEditingController(text: _customerWhatsapp ?? '');
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
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
                builder: (context, setPanelState) {
                  Future<void> pickImage() async {
                    try {
                      final image = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 600,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setPanelState(() {
                          selectedImage = image;
                          selectedImageBytes = bytes;
                        });
                      }
                    } catch (e) {
                      print('Error picking image: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error selecting image: $e')),
                        );
                      }
                    }
                  }

                  return Column(
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
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Image Helper
                            Center(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: pickImage, // Use shared handler
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.primaryIndigo, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey[100],
                                        backgroundImage: selectedImageBytes != null
                                            ? MemoryImage(selectedImageBytes!)
                                            : ((_customerProfilePic != null && _customerProfilePic!.isNotEmpty)
                                                ? (_customerProfilePic!.startsWith('data:')
                                                    ? MemoryImage(base64Decode(_customerProfilePic!.split(',')[1]))
                                                    : CachedNetworkImageProvider(_customerProfilePic!) as ImageProvider)
                                                : null),
                                        child: (selectedImageBytes == null && (_customerProfilePic == null || _customerProfilePic!.isEmpty))
                                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: pickImage, // Make camera icon clickable
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryIndigo,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Fields
                            const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: whatsappController,
                              decoration: InputDecoration(
                                labelText: 'WhatsApp Number',
                                prefixIcon: const Icon(Icons.chat_bubble_outline),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, -4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isUploading ? null : () async {
                          setPanelState(() => isUploading = true);
                          try {
                            String? photoUrl = _customerProfilePic;
                            if (selectedImageBytes != null) {
                              final base64String = base64Encode(selectedImageBytes!);
                              photoUrl = 'data:image/jpeg;base64,$base64String';
                            }

                            final user = _authService.currentUser;
                            if (user != null) {
                              await _authService.updateUserData(user.uid, {
                                'name': nameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'whatsapp': whatsappController.text.trim(),
                                'photoUrl': photoUrl,
                              });

                              if (context.mounted) Navigator.pop(context);
                              if (mounted) {
                                // Optimistically update state
                                setState(() {
                                  _customerName = nameController.text.trim();
                                  _customerPhone = phoneController.text.trim();
                                  _customerWhatsapp = whatsappController.text.trim();
                                  _customerProfilePic = photoUrl;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              setPanelState(() => isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: AppTheme.primaryIndigo,
                          foregroundColor: Colors.white,
                        ),
                        child: isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              },
            ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  void _showRequestMeasurementDialog() {
    String requestType = 'new';
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Request Measurement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: requestType,
                items: [
                  DropdownMenuItem(value: 'new', child: Text('New Measurement')),
                  DropdownMenuItem(value: 'renewal', child: Text('Renewal')),
                ],
                onChanged: (v) => setDialogState(() => requestType = v!),
                decoration: const InputDecoration(
                  labelText: 'Request Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes', 
                  hintText: 'E.g., for wedding suit',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (_authService.currentUser == null) return;
                 
                setDialogState(() => isSubmitting = true);
                try {
                  final req = MeasurementRequest(
                    customerId: _authService.currentUser!.uid,
                    customerName: _customerName ?? 'Valued Customer',
                    customerEmail: _customerEmail ?? '',
                    customerPhone: _customerPhone ?? '',
                    customerPhoto: _customerProfilePic,
                    requestType: requestType,
                    requestedAt: DateTime.now(),
                    notes: notesController.text.trim(),
                    status: 'pending',
                  );
                  
                  await _measurementRequestsService.addRequest(req);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request Sent Successfully!'), backgroundColor: Colors.green),
                    );
                    _loadMeasurementRequests(); 
                  }
                } catch (e) {
                   if (mounted) {
                    setDialogState(() => isSubmitting = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sending request: $e'), backgroundColor: Colors.red),
                    );
                   }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1f455b),
                foregroundColor: Colors.white,
              ),
              child: isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Send Request'),
            )
          ]
        ),
      )
    );
 }

  Future<void> _loadMeasurementRequests() async {
     await _measurementRequestsSubscription?.cancel();
     final user = _authService.currentUser;
     if (user != null) {
       _measurementRequestsSubscription = _measurementRequestsService
           .streamCustomerRequests(user.uid)
           .listen((requests) {
         if (mounted) {
           setState(() {
             _myMeasurementRequests = requests;
           });
         }
       });
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
