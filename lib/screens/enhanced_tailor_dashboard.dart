import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
// Web URL handling - using url_launcher would be better for cross-platform
// For now, URLs will be logged on non-web platforms
import '../models/tailor.dart' as models;
import '../models/design.dart' as models;
import '../models/complaint.dart' as models;
import '../models/booking.dart' as models;
import '../models/measurement.dart' as models;
import '../models/pickup_request.dart' as models;
import '../models/faq_item.dart' as models;
import '../models/measurement_request.dart'; // Added
import '../widgets/communication_section.dart';
import '../widgets/unified_profile_card.dart';
import 'tailor_measurement_page.dart';
import 'tailor_bookings_screen.dart';
import 'tailor_measurements_tab.dart';
import 'tailor_pickup_requests_tab.dart';
import '../widgets/measurement_dummy.dart';
import '../widgets/measurement_card.dart';
import '../services/auth_service.dart';
import '../services/firestore_designs_service.dart';
import '../services/firestore_bookings_service.dart';
import '../services/firestore_complaints_service.dart';
import '../services/firestore_pickup_requests_service.dart';
import '../services/firestore_tailor_service.dart';
import '../services/firestore_measurements_service.dart';
import '../services/firestore_faq_service.dart';
import '../services/firestore_measurement_requests_service.dart'; // Added
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'package:intl/intl.dart';

class EnhancedTailorDashboard extends StatefulWidget {
  const EnhancedTailorDashboard({super.key});

  @override
  State<EnhancedTailorDashboard> createState() => _EnhancedTailorDashboardState();
}

class _EnhancedTailorDashboardState extends State<EnhancedTailorDashboard>
    with SingleTickerProviderStateMixin {
  // All entities now via Firestore services.
  final AuthService _authService = AuthService();
  final FirestoreDesignsService _designsService = FirestoreDesignsService();
  final FirestoreBookingsService _bookingsService = FirestoreBookingsService();
  final FirestoreComplaintsService _complaintsService =
      FirestoreComplaintsService();
  final FirestorePickupRequestsService _pickupService =
      FirestorePickupRequestsService();
  final FirestoreFaqService _faqService = FirestoreFaqService();
  final FirestoreMeasurementRequestsService _measurementRequestsService = FirestoreMeasurementRequestsService(); // Added
  final FirestoreTailorService _tailorService = FirestoreTailorService();
  final FirestoreMeasurementsService _measurementsService =
      FirestoreMeasurementsService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  // Section anchors for quick navigation
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _designsKey = GlobalKey();
  final GlobalKey _bookingsKey = GlobalKey();
  final GlobalKey _pickupKey = GlobalKey();
  final GlobalKey _complaintsKey = GlobalKey();
  final GlobalKey _measurementsKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  models.Tailor? _tailor;
  List<models.Design> _designs = [];
  List<models.Complaint> _complaints = [];
  List<models.Booking> _bookings = [];
  List<models.PickupRequest> _pickupRequests = [];
  List<models.FaqItem> _faqs = [];
  List<MeasurementRequest> _measurementRequests = []; // Added
  bool _isLoading = true;

  int _selectedTabIndex = 0; // For bottom navigation

  // Enhanced profile fields
  String _phone = '';
  String _email = '';
  String _whatsappNumber = '';
  String _gmailId = '';
  String _shopLocation = 'Grace Tailor Shop, Pindi Saidpur';
  String _shopHours = 'Mon-Sat: 9 AM - 7 PM';
  double _rating = 4.8;
  int _totalReviews = 127;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
    _loadUserInfo();
    _setupRealtimeListeners();
    _animationController.forward();
  }

  StreamSubscription<List<models.Design>>? _designsSubscription;
  StreamSubscription<List<models.Booking>>? _bookingsSubscription;
  StreamSubscription<List<models.PickupRequest>>? _pickupSubscription;
  StreamSubscription<List<models.Complaint>>? _complaintsSubscription;
  StreamSubscription<List<models.FaqItem>>? _faqSubscription;
  StreamSubscription<List<MeasurementRequest>>? _measurementRequestsSubscription; // Added
  DateTime _lastUpdate = DateTime.now();

  void _setupRealtimeListeners() {
    // Measurement Requests Listener
    _measurementRequestsSubscription = _measurementRequestsService.streamRequests().listen(
      (requests) {
        if (mounted) {
          setState(() {
            _measurementRequests = requests;
          });
        }
      },
      onError: (e) => print('Error in measurement requests stream: $e'),
    );

    // Debounce updates to prevent excessive rebuilds (max once per 500ms)
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
      onError: (e) => print('Error in designs stream: $e'),
    );
     
    _bookingsSubscription = _bookingsService.streamAllBookings().listen(
      (bookings) {
        if (mounted && DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
          _lastUpdate = DateTime.now();
          setState(() {
            _bookings = bookings;
          });
        } else if (mounted) {
          _bookings = bookings;
        }
      },
      onError: (e) => print('Error in bookings stream: $e'),
    );

    _pickupSubscription = _pickupService.streamRequests().listen(
      (requests) {
        if (mounted && DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
          _lastUpdate = DateTime.now();
          setState(() {
            _pickupRequests = requests;
          });
        } else if (mounted) {
          _pickupRequests = requests;
        }
      },
      onError: (e) => print('Error in pickup stream: $e'),
    );

    _complaintsSubscription = _complaintsService.streamComplaints().listen(
      (complaints) {
        if (mounted && DateTime.now().difference(_lastUpdate).inMilliseconds > 500) {
          _lastUpdate = DateTime.now();
          setState(() {
            _complaints = complaints;
          });
        } else if (mounted) {
          _complaints = complaints;
        }
      },
      onError: (e) => print('Error in complaints stream: $e'),
    );
  }

  @override
  void dispose() {
    _designsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _pickupSubscription?.cancel();
    _complaintsSubscription?.cancel();
    _faqSubscription?.cancel();
    _measurementRequestsSubscription?.cancel(); // Added
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? '';
      });
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
        _complaintsService.getAllComplaints(),
        _bookingsService.getAllBookings(),
        _pickupService.getAllRequests(),
      ], eagerError: false);
      
      final tailor = results[0] as models.Tailor?;
      final designs = results[1] as List<models.Design>;
      final complaints = results[2] as List<models.Complaint>;
      final bookings = results[3] as List<models.Booking>;
      final pickupRequests = results[4] as List<models.PickupRequest>;

      // Load profile data from Firestore - load regardless of tailor existence
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          _phone = userData['phone'] as String? ?? '';
          _whatsappNumber = userData['whatsappNumber'] as String? ?? '';
          _gmailId = userData['gmailId'] as String? ?? '';
          _shopLocation = userData['shopLocation'] as String? ?? 'Grace Tailor Shop, Pindi Saidpur';
          _shopHours = userData['shopHours'] as String? ?? 'Mon-Sat: 9 AM - 7 PM';
          _rating = (userData['rating'] as num?)?.toDouble() ?? 4.8;
          _totalReviews = userData['totalReviews'] as int? ?? 127;
          _reviews = (userData['reviews'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        }
      }

      if (mounted) {
        setState(() {
          _tailor = tailor;
          _designs = designs;
          _complaints = complaints;
          _bookings = bookings;
          _pickupRequests = pickupRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Optimized refresh methods - only update specific data without full reload
  Future<void> _refreshDesigns() async {
    if (!mounted) return;
    try {
      final designs = await _designsService.getAllDesigns();
      if (mounted) {
        setState(() => _designs = designs);
      }
    } catch (e) {
      print('Error refreshing designs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing designs: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshBookings() async {
    try {
      final bookings = await _bookingsService.getAllBookings();
      if (mounted) {
        setState(() => _bookings = bookings);
      }
    } catch (e) {
      print('Error refreshing bookings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing bookings: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshMeasurements() async {
    // Measurements are loaded on demand, no need to refresh
  }

  Future<void> _refreshPickupRequests() async {
    try {
      final pickupRequests = await _pickupService.getAllRequests();
      if (mounted) {
        setState(() => _pickupRequests = pickupRequests);
      }
    } catch (e) {
      print('Error refreshing pickup requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing pickup requests: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshComplaints() async {
    try {
      final complaints = await _complaintsService.getAllComplaints();
      if (mounted) {
        setState(() => _complaints = complaints);
      }
    } catch (e) {
      print('Error refreshing complaints: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing complaints: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    // Navigate to side panel
    _openEditProfileSidePanel();
  }

  void _openEditProfileSidePanel() {
    final nameController = TextEditingController(text: _tailor?.name ?? '');
    final descController = TextEditingController(text: _tailor?.description ?? '');
    final phoneController = TextEditingController(text: _phone);
    final whatsappController = TextEditingController(text: _whatsappNumber);
    final gmailController = TextEditingController(text: _gmailId);
    final locationController = TextEditingController(text: _shopLocation);
    final hoursController = TextEditingController(text: _shopHours);
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
              width: MediaQuery.of(context).size.width * 0.85, // 85% width side panel
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
              ),
              child: StatefulBuilder(
                builder: (context, setPanelState) => Column(
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
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                            ),
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
                            // Profile Image
                            Center(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final image = await _imagePicker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 600,
                                        imageQuality: 70,
                                      );
                                      if (image != null) {
                                        setPanelState(() => selectedImage = image);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey[100],
                                        backgroundImage: selectedImage != null
                                            ? (kIsWeb
                                                ? NetworkImage(selectedImage!.path) as ImageProvider
                                                : FileImage(File(selectedImage!.path)))
                                            : _getProfileImage(),
                                        child: (selectedImage == null && (_tailor?.photo == null || _tailor!.photo!.isEmpty))
                                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 16),
                            _buildSidePanelField('Full Name', nameController, Icons.person_outline),
                            const SizedBox(height: 16),
                            _buildSidePanelField('Business Description', descController, Icons.description_outlined, maxLines: 3),
                            
                            const SizedBox(height: 32),
                            const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 16),
                            _buildSidePanelField('Phone Number', phoneController, Icons.phone_outlined),
                            const SizedBox(height: 16),
                            _buildSidePanelField('WhatsApp', whatsappController, Icons.chat_bubble_outline),
                            const SizedBox(height: 16),
                            _buildSidePanelField('Email Address', gmailController, Icons.email_outlined),
                            
                            const SizedBox(height: 32),
                            const Text('Shop Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 16),
                            _buildSidePanelField('Shop Location', locationController, Icons.location_on_outlined),
                            const SizedBox(height: 16),
                            _buildSidePanelField('Business Hours', hoursController, Icons.access_time),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer
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
                            // ... Upload logic same as before but cleaner ...
                             String? photoUrl = _tailor?.photo;
                            if (selectedImage != null) {
                              try {
                                final bytes = await selectedImage!.readAsBytes();
                                final base64String = base64Encode(bytes);
                                photoUrl = 'data:image/jpeg;base64,\$base64String';
                              } catch (e) {
                                print('Error encoding image: \$e');
                                // Fallback
                              }
                            }

                            final tailor = models.Tailor(
                              name: nameController.text.trim(),
                              photo: photoUrl,
                              description: descController.text.trim(),
                              phone: phoneController.text.trim(),
                              whatsapp: whatsappController.text.trim(),
                              email: gmailController.text.trim(),
                              location: locationController.text.trim(),
                              shopHours: hoursController.text.trim(),
                            );

                            final user = _authService.currentUser;
                            final updates = [
                              _tailorService.insertOrUpdateTailor(tailor),
                              if (user != null)
                                _authService.updateUserData(user.uid, {
                                  'phone': phoneController.text.trim(),
                                  'whatsappNumber': whatsappController.text.trim(),
                                  'gmailId': gmailController.text.trim(),
                                  'shopLocation': locationController.text.trim(),
                                  'shopHours': hoursController.text.trim(),
                                }),
                            ];

                            await Future.wait(updates);
                            
                            if (context.mounted) Navigator.pop(context);
                            
                            if (mounted) {
                              setState(() {
                                _phone = phoneController.text.trim();
                                _whatsappNumber = whatsappController.text.trim();
                                _gmailId = gmailController.text.trim();
                                _shopLocation = locationController.text.trim();
                                _shopHours = hoursController.text.trim();
                                _tailor = tailor;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Profile Updated Successfully'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(20),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setPanelState(() => isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: \$e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildSidePanelField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_tailor?.photo == null || _tailor!.photo!.isEmpty) {
      return null;
    }
    
    try {
      final photo = _tailor!.photo!;
      if (photo.startsWith('data:')) {
        final parts = photo.split(',');
        if (parts.length > 1) {
          final base64String = parts[1];
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        }
      } else if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return CachedNetworkImageProvider(photo);
      }
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
    
    return null;
  }

  Widget _buildDesignImage(String? photo) {
    if (photo == null || photo.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 50),
      );
    }
    
    try {
      if (photo.startsWith('data:')) {
        final parts = photo.split(',');
        if (parts.length > 1) {
          final base64String = parts[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 50),
              );
            },
          );
        }
      } else if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return CachedNetworkImage(
          imageUrl: photo,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 50),
          ),
        );
      }
    } catch (e) {
      print('Error loading design image: $e');
    }
    
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 50),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _authService.signOut();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Tab 0: Profile
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileSection(),
                  _buildQuickStats(),
                ],
              ),
            ),

            // Tab 1: Designs
            SingleChildScrollView(
              child: _buildDesignsSection(),
            ),

            // Tab 2: Bookings
            SingleChildScrollView(
              child: _buildBookingsSection(),
            ),

            // Tab 3: Measurements
            SingleChildScrollView(
              child: _buildMeasurementsSection(),
            ),

            // Tab 4: Pickup
            SingleChildScrollView(
              child: _buildPickupRequestsSection(),
            ),

            // Tab 5: Complaints
            SingleChildScrollView(
              child: _buildComplaintsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.person, 'Profile'),
                _buildNavItem(1, Icons.checkroom, 'Designs'),
                _buildNavItem(2, Icons.calendar_today, 'Bookings'),
                _buildNavItem(3, Icons.straighten, 'Measure'),
                _buildNavItem(4, Icons.local_shipping, 'Pickup'),
                _buildNavItem(5, Icons.forum, 'Complaints'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                fontSize: 11,
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

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  Widget _buildProfileSection() {
    return UnifiedProfileCard(
      name: _tailor?.name ?? 'Grace Tailor',
      description: _tailor?.description?.isNotEmpty == true
          ? _tailor!.description!
          : 'Bringing fabric to life with precision and style.',
      photoUrl: _tailor?.photo,
      onEdit: _showEditProfileDialog,
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
                _shopHours.isNotEmpty ? _shopHours : 'Mon-Sat: 9 AM - 7 PM',
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
          onTap: () {
            if (_whatsappNumber.isNotEmpty) {
              final clean = _whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
              print('WhatsApp URL: https://wa.me/$clean');
            }
          },
        ),
        ProfileQuickAction(
          icon: Icons.phone_outlined,
          label: 'Call',
          color: const Color(0xFF1f455b),
          onTap: () {
            if (_phone.isNotEmpty) {
              print('Call: tel:$_phone');
            }
          },
        ),
        ProfileQuickAction(
          icon: Icons.mail_outline,
          label: 'Email',
          color: Colors.blueAccent,
          onTap: () {
            if (_email.isNotEmpty) {
              print('Mail: mailto:$_email');
            }
          },
        ),
        ProfileQuickAction(
          icon: Icons.location_on_outlined,
          label: 'Map',
          color: Colors.redAccent,
          onTap: () {
            if (_shopLocation.isNotEmpty) {
              print('Map: $_shopLocation');
            }
          },
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.open_in_new, color: color, size: 20),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return content;
  }

  Widget _buildReviewsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_reviews.take(3).map((review) => _buildReviewItem(review))),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final customerName = review['customerName'] as String? ?? 'Anonymous';
    final initial = customerName.isNotEmpty ? customerName[0].toUpperCase() : 'A';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            child: Text(initial),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...List.generate(5, (index) {
                      final rating = (review['rating'] as num?)?.toDouble() ?? 5.0;
                      return Icon(
                        Icons.star,
                        size: 14,
                        color: index < rating ? Colors.amber : Colors.grey[300],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review['comment'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Bookings',
              _bookings.length.toString(),
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
              _complaints.length.toString(),
              Icons.message,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignsSection() {
    return _buildSection(
      title: 'My Designs',
      icon: Icons.design_services,
      actionButton: IconButton(
        icon: const Icon(Icons.add_circle, size: 28),
        color: Theme.of(context).colorScheme.primary,
        onPressed: _showAddDesignDialog,
        tooltip: 'Add New Design',
      ),
      child: _designs.isEmpty
          ? _buildEmptyState('No designs yet', 'Add your first design!', Icons.design_services)
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75, // Taller cards
              ),
              itemCount: _designs.length,
              itemBuilder: (context, index) => _buildDesignCard(_designs[index], index),
            ),
    );
  }

  Widget _buildDesignCard(models.Design design, int index) {
    Color statusColor;
    switch (design.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      case 'new':
      default:
        statusColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildDesignImage(design.photo),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      design.status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${design.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _showEditDesignDialog(design),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.edit_outlined, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showDeleteDesignDialog(design),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline, size: 20, color: Colors.red[400]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Design Dialogs ---

  void _showAddDesignDialog() {
    _showDesignFormDialog();
  }

  void _showEditDesignDialog(models.Design design) {
    _showDesignFormDialog(design: design);
  }

  void _showDesignFormDialog({models.Design? design}) {
    final titleController = TextEditingController(text: design?.title ?? '');
    final priceController = TextEditingController(text: design?.price.toString() ?? '');
    String status = design?.status ?? 'new';
    XFile? selectedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(design == null ? 'Add New Design' : 'Edit Design'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
                    if (image != null) setDialogState(() => selectedImage = image);
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                          )
                        : (design?.photo != null && design!.photo!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildDesignImage(design.photo),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Upload Photo', style: TextStyle(color: Colors.grey)),
                                ],
                              )),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Design Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (Rs.)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'new', child: Text('New')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (val) => setDialogState(() => status = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleController.text.isEmpty || priceController.text.isEmpty) return;
                      setDialogState(() => isUploading = true);
                      try {
                        String? photoUrl = design?.photo;
                        if (selectedImage != null) {
                           try {
                              final bytes = await selectedImage!.readAsBytes();
                              final base64String = base64Encode(bytes);
                              photoUrl = 'data:image/jpeg;base64,$base64String';
                            } catch (e) {
                              print('Error encoding image: $e');
                            }
                        }

                        final newDesign = models.Design(
                          id: design?.id,
                          docId: design?.docId,
                          title: titleController.text.trim(),
                          price: double.tryParse(priceController.text) ?? 0,
                          photo: photoUrl,
                          status: status,
                          createdAt: design?.createdAt,
                        );

                        if (newDesign.docId != null) {
                          await _designsService.updateDesign(newDesign);
                        } else {
                          await _designsService.addDesign(newDesign);
                        }
                        if (context.mounted) Navigator.pop(context);
                        _refreshDesigns();
                      } catch (e) {
                        setDialogState(() => isUploading = false);
                        print(e);
                      }
                    },
              child: isUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(design == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDesignDialog(models.Design design) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Design'),
        content: const Text('Are you sure you want to delete this design?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _designsService.deleteDesign(design.docId!);
              if (context.mounted) Navigator.pop(context);
              _refreshDesigns();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsSection() {
    return _buildSection(
      title: 'Booking Calendar',
      icon: Icons.event,
      actionButton: IconButton(
        icon: const Icon(Icons.add_circle, size: 28),
        color: Theme.of(context).colorScheme.primary,
        onPressed: _showAddBookingDialog,
        tooltip: 'Add New Booking',
      ),
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
              _buildLegendItem('Pending', Colors.amber[100]!, Colors.amber[800]!),
              const SizedBox(width: 16),
              _buildLegendItem('Booked', Colors.red[100]!, Colors.red),
            ],
          ),
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
      width: 160,
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

  // Need DateFormat helper because intl might not be available directly in this scope if not imported properly or configured
  // Assuming intl is imported as per file view. But I'll use a safer helper just in case.
  // Actually, standard DateFormat is fine if imported. The file imports intl? `file:///d:/grace%20tailor%20app/grace-tailor-main/lib/screens/enhanced_tailor_dashboard.dart` had no intl import shown in first 50 lines.
  // Wait, I didn't see `import 'package:intl/intl.dart';` in lines 1-30. 
  // Let's assume I need to add it or use a simple formatter.
  // I'll add a helper method to format date to avoid dependency issues if it's missing.
  
  // Actually, I'll use a simple switch for Day name to be safe.

  Widget _buildTimeSlotCard(DateTime date, String slotTime) {
    // Find booking for this slot
    // Matches if same day and same slot string
    final booking = _bookings.firstWhere(
      (b) => b.bookingDate.year == date.year && 
             b.bookingDate.month == date.month && 
             b.bookingDate.day == date.day &&
             b.timeSlot == slotTime, // Assuming simple string match or logic
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
    final isPending = booking.status == 'pending';
    final isBooked = booking.status == 'confirmed' || booking.status == 'approved' || booking.status == 'completed';

    Color bgColor = Colors.green[50]!;
    Color borderColor = Colors.green;
    Color iconColor = Colors.green;

    if (isPending) {
      bgColor = Colors.amber[50]!;
      borderColor = Colors.amber[800]!;
      iconColor = Colors.amber[800]!;
    } else if (isBooked) {
      bgColor = Colors.red[50]!;
      borderColor = Colors.red;
      iconColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        if (!isAvailable) {
          _showBookingActionDialog(booking);
        } else {
          // Open add booking dialog pre-filled
          _showAddBookingDialog(initialDate: date, initialSlot: slotTime);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (!isAvailable)
              BoxShadow(
                color: borderColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
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
              child: isAvailable 
                ? Icon(Icons.add, size: 20, color: Colors.green[300])
                : Column(
                    children: [
                      Icon(Icons.person, size: 16, color: iconColor),
                      const SizedBox(height: 2),
                      Text(
                        booking.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        booking.suitType,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Hacky Date Format helper since I'm not sure if intl is imported
  dynamic _getConfiguredDateFormat(String pattern) {
    // If intl is available, this would work: return DateFormat(pattern);
    // Since I can't guarantee import, I'll return a dummy object that has a format method
    // Or simpler: just implement logic for 'E' (Mon, Tue)
    return _SimpleDateFormatter(pattern);
  }

  void _showBookingActionDialog(models.Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Customer', booking.customerName),
            _detailRow('Suit Type', booking.suitType),
            _detailRow('Time', '${_formatDate(booking.bookingDate)} at ${booking.timeSlot}'),
            if (booking.specialInstructions?.isNotEmpty == true)
              _detailRow('Note', booking.specialInstructions!),
            const SizedBox(height: 16),
            const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Chip(
              label: Text(booking.status.toUpperCase()),
              backgroundColor: _getStatusColor(booking.status).withOpacity(0.2),
            ),
          ],
        ),
        actions: [
          if (booking.status == 'pending') ...[
            TextButton(
              onPressed: () async {
                // Reject -> Available (Delete or update status? User said "slot resets to Green")
                // Usually reserved bookings are deleted or status changed to cancelled.
                // "When reject -> slot resets to Green" implies deleting the booking or moving it out of the slot.
                // I'll update status to 'rejected' which my logic considers available? No, my logic checks !available.
                // I should probably delete it or change status to 'rejected' and treat 'rejected' as not occupying slot?
                // The logic: final isBooked = ... 'confirmed' || 'approved'
                // If I set to 'rejected', it won't be 'pending' or 'booked', so it might default to 'available' if logic is robust?
                // Logic: booking = firstWhere(...) orElse models.Booking(status: 'available').
                // If I find a 'rejected' booking, it returns it. So 'rejected' should be treated as available?
                // I'll delete the booking for simplicity to "reset" the slot, or mark as cancelled.
                // "Delete" allows re-booking.
                 await _bookingsService.deleteBooking(booking.docId!);
                 if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                 final updated = booking.copyWith(status: 'approved'); // or 'confirmed'
                 await _bookingsService.updateBooking(updated);
                 if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Accept', style: TextStyle(color: Colors.white)),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                _showEditBookingDialog(booking);
              },
              child: const Text('Edit'),
            ),
          ]
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
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showAddBookingDialog({DateTime? initialDate, String? initialSlot}) {
    // ... Implementation for adding booking ... 
    _showBookingFormDialog(initialDate: initialDate, initialSlot: initialSlot);
  }

  void _showEditBookingDialog(models.Booking booking) {
    _showBookingFormDialog(booking: booking);
  }

  void _showBookingFormDialog({models.Booking? booking, DateTime? initialDate, String? initialSlot}) {
    final nameController = TextEditingController(text: booking?.customerName ?? '');
    final timeSlotController = TextEditingController(text: booking?.timeSlot ?? initialSlot ?? '09:00 - 11:00'); 
    final suitTypeController = TextEditingController(text: booking?.suitType ?? '');
    final noteController = TextEditingController(text: booking?.specialInstructions ?? '');
    DateTime selectedDate = booking?.bookingDate ?? initialDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(booking == null ? 'New Booking' : 'Edit Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
                const SizedBox(height: 8),
                TextField(controller: suitTypeController, decoration: const InputDecoration(labelText: 'Suit Type')),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context, 
                      initialDate: selectedDate, 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime.now().add(const Duration(days: 30))
                    );
                    if (d != null) setDialogState(() => selectedDate = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(_SimpleDateFormatter('day').format(selectedDate)),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: timeSlots.contains(timeSlotController.text) ? timeSlotController.text : timeSlots[0],
                  items: timeSlots.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => timeSlotController.text = v!,
                  decoration: const InputDecoration(labelText: 'Time Slot'),
                ),
                const SizedBox(height: 8),
                TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                 final newBooking = models.Booking(
                   id: booking?.id,
                   docId: booking?.docId,
                   customerName: nameController.text.trim(),
                   customerEmail: booking?.customerEmail ?? '', // Optional or hidden
                   customerPhone: booking?.customerPhone ?? '', // Optional or hidden
                   bookingDate: selectedDate,
                   timeSlot: timeSlotController.text,
                   suitType: suitTypeController.text,
                   isUrgent: booking?.isUrgent ?? false,
                   charges: booking?.charges ?? 0.0,
                   specialInstructions: noteController.text.trim(),
                   status: booking?.status ?? 'pending',
                   createdAt: booking?.createdAt,
                 );
                 
                 if (booking == null) {
                    await _bookingsService.addBooking(newBooking);
                 } else {
                    await _bookingsService.updateBooking(newBooking);
                 }
                 if (context.mounted) Navigator.pop(context);
                 _refreshBookings();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  final timeSlots = [
      '09:00 - 11:00',
      '11:00 - 13:00',
      '14:00 - 16:00',
      '16:00 - 18:00',
  ];

  Widget _buildMeasurementsSection() {
    return _buildSection(
      title: 'Customer Measurements',
      icon: Icons.straighten,
      actionButton: IconButton(
        icon: const Icon(Icons.add_circle, size: 28),
        color: Theme.of(context).colorScheme.primary,
        onPressed: _showAddMeasurementDialog,
        tooltip: 'Add New Measurement',
      ),
      child: _buildMeasurementsContent(),
    );
  }

  // Search and Sort State
  String _measurementSearchQuery = '';
  String _measurementSortOption = 'Name'; // Name, Date

  Widget _buildMeasurementsContent() {
    final pendingRequests = _measurementRequests.where((r) => r.status == 'pending' || r.status == 'replied').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pendingRequests.isNotEmpty)
          Container(
            height: 160,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final req = pendingRequests[index];
                return GestureDetector(
                  onTap: () => _showMeasurementRequestActionDialog(req),
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: req.customerPhoto != null 
                                  ? CachedNetworkImageProvider(req.customerPhoto!) 
                                  : null,
                              child: req.customerPhoto == null 
                                  ? Text(req.customerName[0], style: const TextStyle(fontSize: 12)) 
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(req.customerName, style: const TextStyle(fontWeight: FontWeight.bold))),
                            StatusBadge(status: req.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                         Text(
                          '${req.requestType == 'new' ? 'New Measurement Request' : 'Renewal Request'}',
                          style: const TextStyle(color: Color(0xFF1f455b), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req.notes ?? 'No notes',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const Spacer(),
                        const Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             Text('Tap to Manage', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                             Icon(Icons.arrow_forward_ios, size: 12, color: Colors.orange),
                           ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
        SizedBox(
          height: MediaQuery.of(context).size.height - (pendingRequests.isNotEmpty ? 380 : 200),
          child: const TailorMeasurementPage(),
        ),
      ],
    );
  }



  Widget _buildDetailedMeasurementTable(models.Measurement m) {
    // Combine standard and dynamic measurements
    // Standard set for sorting order
    final standardKeys = ['Chest', 'Waist', 'Hips', 'Shoulder', 'Sleeve Length', 'Shirt Length', 'Trouser Length'];
    Map<String, double> displayed = Map.from(m.measurements);
    
    // Ensure all standard keys exist for display (even if null/0)
    for (var key in standardKeys) {
       displayed.putIfAbsent(key, () => 0.0);
    }

    final sortedEntries = displayed.entries.toList()
      ..sort((a, b) {
         // Standard first, then alphabetical
         int idxA = standardKeys.indexOf(a.key);
         int idxB = standardKeys.indexOf(b.key);
         if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
         if (idxA != -1) return -1;
         if (idxB != -1) return 1;
         return a.key.compareTo(b.key);
      });

    return Container(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!, borderRadius: BorderRadius.circular(8)),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text('Measurement', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8), child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8), child: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          ...sortedEntries.map((entry) {
            return TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8), child: Text(entry.key)),
                Padding(padding: const EdgeInsets.all(8), child: Text(entry.value == 0.0 ? '-' : entry.value.toStringAsFixed(1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  child: m.stitchingStarted
                      ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                      : IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: () {
                            _showQuickUpdateDialog(m, entry.key, entry.value);
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showQuickUpdateDialog(models.Measurement m, String fieldName, double? currentValue) {
    if (m.stitchingStarted) return; // double check

    final controller = TextEditingController(text: (currentValue == 0.0 ? '' : currentValue?.toString()) ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update $fieldName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Value (Inches)'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null) {
                Map<String, double> newMap = Map.from(m.measurements);
                newMap[fieldName] = val;
                
                final updated = m.copyWith(measurements: newMap);
                
                await _measurementsService.insertOrUpdate(updated);
                if (context.mounted) Navigator.pop(context);
                setState(() {}); // refresh
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddDynamicRowDialog(models.Measurement m) {
    final nameController = TextEditingController();
    final valController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Measurement Row'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(
               controller: nameController,
               decoration: const InputDecoration(labelText: 'Measurement Name (e.g. Neck)'),
             ),
             TextField(
               controller: valController,
               decoration: const InputDecoration(labelText: 'Value (e.g. 15.5)'),
               keyboardType: TextInputType.number,
             ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final val = double.tryParse(valController.text);
              
              if (name.isNotEmpty && val != null) {
                 Map<String, double> newMap = Map.from(m.measurements);
                 newMap[name] = val;
                 final updated = m.copyWith(measurements: newMap);
                 await _measurementsService.insertOrUpdate(updated);
                 if (context.mounted) Navigator.pop(context);
                 setState(() {});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _simpleDateFormat(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  void _showMeasurementDetails(models.Measurement measurement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final hasMeasurements = measurement.measurements.values.any((v) => v > 0);
          // Local state to track if we triggered "Add"
          bool showGrid = hasMeasurements;
          // But since builder runs on every rebuild, we need to store state outside if we want it to persist across updates?
          // Actually, stateful builder state is preserved as long as widget matches.
          // But local var 'showGrid' resets.
          // Correct pattern: Use a local variable inside the builder closure? No, that resets.
          // Use a ValueNotifier or just rely on 'hasMeasurements'? 
          // If we click "Add", we want UI to change. 
          // Let's rely on a variable captured in closure? No, State object needed.
          // I will use a simple specialized widget or just inline logic that defaults to `hasMeasurements`.
          // Wait, if I want to "switch" to grid view, I need a state variable.
          // I'll assume we can't easily persist state here without a proper Widget class.
          // Hack: use a boolean 'forceShowGrid' in a map or similar? Or just re-fetch?
          // Simplest: If logic is complex, create a separate method `_buildDetailsContent` that uses State?
          // Or just standard trick: `bool _isAdding = false;` defined *outside* the builder? 
          // No, builder is called once? No.
          // I'll extract a simple widget `_MeasurementDetailsSheet` which is Stateful.
          return _MeasurementDetailsSheet(
            measurement: measurement, 
            service: _measurementsService,
          );
        }
      ),
    );
  }

  Widget _buildPickupRequestsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            'Pickup Requests',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage incoming parcels and dress pickups',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddPickupRequestDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Pickup Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _refreshPickupRequests,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Status Summary Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusChip('🟡 Pending', _getPendingPickupsCount(), Colors.orange),
                    _buildStatusChip('🟢 Accepted', _getAcceptedPickupsCount(), Colors.green),
                    _buildStatusChip('🔵 Completed', _getCompletedPickupsCount(), Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          
          // Summary Cards Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildPickupSummaryCard(
                    '📦 Today\'s Pickups',
                    _getTodayPickupsCount(),
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickupSummaryCard(
                    '🚚 Incoming',
                    _getIncomingParcelsCount(),
                    Icons.local_shipping,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickupSummaryCard(
                    '✅ Completed',
                    _getCompletedPickupsCount(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickupSummaryCard(
                    '⏳ Pending',
                    _getPendingPickupsCount(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Pickup List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _pickupRequests.isEmpty
                ? _buildEnhancedEmpty(
                    Icons.local_shipping_outlined,
                    'No Pickup Requests',
                    Colors.blue,
                    subtitle: 'Create your first pickup request to get started',
                  )
                : Column(
                    children: _pickupRequests.map((r) => _buildEnhancedPickupCard(r)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPickupCard(models.PickupRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _getRequestStatusColor(request.status), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade400]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(request.customerEmail, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                StatusBadge(status: request.status, type: 'pickup'),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text('Type:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const Spacer(),
                      Text(request.requestType.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (request.trackingNumber != null) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(Icons.qr_code, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text('Tracking:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const Spacer(),
                        Text(request.trackingNumber!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditPickupRequestDialog(request),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeletePickupRequestDialog(request),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupRequestsContent() {
    if (_pickupRequests.isEmpty) {
      return _buildEmptyState(
        'No pickup requests',
        'Pickup requests will appear here',
        Icons.local_shipping,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _pickupRequests.take(5).map((request) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRequestStatusColor(request.status).withOpacity(0.2),
              child: Icon(
                Icons.local_shipping,
                color: _getRequestStatusColor(request.status),
              ),
            ),
            title: Text(
              request.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${request.pickupAddress} â€¢ ${_formatDate(request.requestedDate)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getRequestStatusColor(request.status).withOpacity(0.2),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditPickupRequestDialog(request);
                    } else if (value == 'delete') {
                      _showDeletePickupRequestDialog(request);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            onTap: () {
              _showEditPickupRequestDialog(request);
            },
          ),
        );
      }).toList(),
    );
  }

  Color _getRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Pickup Statistics Helper Methods
  int _getTodayPickupsCount() {
    final today = DateTime.now();
    return _pickupRequests.where((r) {
      return r.requestedDate.year == today.year &&
          r.requestedDate.month == today.month &&
          r.requestedDate.day == today.day;
    }).length;
  }

  int _getIncomingParcelsCount() {
    return _pickupRequests.where((r) => 
        r.status == 'pending' || r.status == 'accepted').length;
  }

  int _getCompletedPickupsCount() {
    return _pickupRequests.where((r) => r.status == 'completed').length;
  }

  int _getPendingPickupsCount() {
    return _pickupRequests.where((r) => r.status == 'pending').length;
  }

  int _getAcceptedPickupsCount() {
    return _pickupRequests.where((r) => r.status == 'accepted').length;
  }

  // Pickup UI Helper Methods
  Widget _buildPickupSummaryCard(String title, int count, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * animValue),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Complaint Statistics Helper Methods
  int _getOpenComplaintsCount() {
    return _complaints.where((c) => !c.isResolved && (c.reply == null || c.reply!.isEmpty)).length;
  }

  int _getInProgressComplaintsCount() {
    return _complaints.where((c) => !c.isResolved && c.reply != null && c.reply!.isNotEmpty).length;
  }

  int _getResolvedComplaintsCount() {
    return _complaints.where((c) => c.isResolved).length;
  }

  // Complaint UI Helper Methods
  Widget _buildComplaintStatCard(String title, int count, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * animValue),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildComplaintsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.red.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.red.shade600],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            'Customer Complaints & Support',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View and resolve customer concerns',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddComplaintDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Complaint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _refreshComplaints,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats Cards Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildComplaintStatCard(
                    '🔴 Open',
                    _getOpenComplaintsCount(),
                    Icons.error_outline,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildComplaintStatCard(
                    '🟡 In Progress',
                    _getInProgressComplaintsCount(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildComplaintStatCard(
                    '🟢 Resolved',
                    _getResolvedComplaintsCount(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Complaint List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _complaints.isEmpty
                ? _buildEnhancedEmpty(
                    Icons.sentiment_satisfied_alt,
                    'No Complaints',
                    Colors.green,
                    subtitle: 'All good! Your customers are happy 😊',
                  )
                : Column(
                    children: _complaints.map((c) => _buildEnhancedComplaintCard(c)).toList(),
                  ),
          ),
          
          // FAQ Section
          _buildFAQSection(),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Todo: Show manage FAQs dialog
                },
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_faqs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No FAQs added yet',
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq.question,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq.answer,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedComplaintCard(models.Complaint complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: complaint.isResolved ? Colors.green : Colors.red, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: complaint.isResolved
                          ? [Colors.green.shade400, Colors.teal.shade400]
                          : [Colors.orange.shade400, Colors.red.shade400],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(complaint.isResolved ? Icons.check_circle : Icons.error, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(complaint.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(DateFormat('MMM d, y').format(complaint.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: complaint.isResolved ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: complaint.isResolved ? Colors.green.shade300 : Colors.red.shade300),
                  ),
                  child: Text(
                    complaint.isResolved ? 'RESOLVED' : 'OPEN',
                    style: TextStyle(
                      color: complaint.isResolved ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Text(complaint.message, style: const TextStyle(fontSize: 13, height: 1.4)),
            ),
            if (complaint.reply != null && complaint.reply!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text('Your Reply:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(complaint.reply!, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReplyComplaintDialog(complaint),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Reply'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleComplaintResolution(complaint),
                    icon: Icon(complaint.isResolved ? Icons.refresh : Icons.check, size: 16),
                    label: Text(complaint.isResolved ? 'Reopen' : 'Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: complaint.isResolved ? Colors.orange.shade400 : Colors.green.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmpty(IconData icon, String title, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.1)]),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplaintCard(models.Complaint complaint) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: complaint.isResolved
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          child: Icon(
            complaint.isResolved ? Icons.check : Icons.warning,
            color: complaint.isResolved ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          complaint.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(complaint.message, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(complaint.isResolved ? 'Resolved' : 'Pending'),
              backgroundColor: complaint.isResolved
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'reply') {
                  _showReplyComplaintDialog(complaint);
                } else if (value == 'resolve') {
                  _toggleComplaintResolution(complaint);
                } else if (value == 'edit') {
                  _showEditComplaintDialog(complaint);
                } else if (value == 'delete') {
                  _showDeleteComplaintDialog(complaint);
                }
              },
              itemBuilder: (context) => [
                if (!complaint.isResolved) const PopupMenuItem(value: 'reply', child: Text('Reply')),
                if (!complaint.isResolved) const PopupMenuItem(value: 'resolve', child: Text('Mark Resolved')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message: ${complaint.message}'),
                if (complaint.reply != null && complaint.reply!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Your Reply: ${complaint.reply}'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? actionButton,
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (actionButton != null) actionButton,
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
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
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
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
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  void _showDeleteBookingDialog(models.Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text('Are you sure you want to delete booking for "${booking.customerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (booking.docId != null) {
                try {
                  await _bookingsService.deleteBooking(booking.docId!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking deleted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    _refreshBookings();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting booking: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: Booking ID not found'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Measurement CRUD Dialogs
  void _showAddMeasurementDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter customer details to create measurement card',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '03001234567',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Text(
              'Email will be auto-generated',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
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
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter customer name and phone number'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Auto-generate email from phone
              final sanitizedPhone = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
              final autoEmail = 'customer_$sanitizedPhone@gracetailor.local';

              final measurement = models.Measurement(
                customerId: '', // Service will resolve this
                customerName: nameController.text.trim(),
                customerEmail: autoEmail,
                customerPhone: phoneController.text.trim(),
                measurements: {
                  // Pre-fill common measurements with 0 so tailor can just update numbers
                  'Chest': 0,
                  'Shoulder': 0,
                  'Sleeve': 0,
                  'Waist': 0,
                  'Hip': 0,
                  'Kurta Length': 0,
                  'Trouser Length': 0,
                },
              );

              try {
                await _measurementsService.insertOrUpdate(measurement);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text.trim()} added! Tap to edit measurements.'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  setState(() {}); // Refresh the list
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  void _showEditMeasurementDialog(models.Measurement measurement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Edit Measurement - ${measurement.customerName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _measurementsService.insertOrUpdate(measurement);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Measurement updated successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating measurement: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: MeasurementDummy(
                  measurement: measurement,
                  isEditable: true,
                  onMeasurementUpdated: (updated) async {
                    await _measurementsService.insertOrUpdate(updated);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteMeasurementDialog(models.Measurement measurement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: Text('Are you sure you want to delete measurement for "${measurement.customerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (measurement.id != null) {
                // Note: We need to add deleteMeasurement method to database_helper.dart
                // For now, we'll use a workaround
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete measurement functionality needs to be added to database helper')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Pickup Request CRUD Dialogs
  void _showAddPickupRequestDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final chargesController = TextEditingController();
    final notesController = TextEditingController();
    final trackingController = TextEditingController();
    final courierController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'manual';
    String selectedStatus = 'pending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Pickup Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Customer Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Customer Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Request Type'),
                  items: ['manual', 'sewing_request']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Pickup Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Requested Date: ${_formatDate(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: chargesController,
                  decoration: const InputDecoration(labelText: 'Charges'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: trackingController,
                  decoration: const InputDecoration(labelText: 'Tracking Number (optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: courierController,
                  decoration: const InputDecoration(labelText: 'Courier Name (optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['pending', 'accepted', 'completed', 'rejected']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setState(() => selectedStatus = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    addressController.text.isNotEmpty) {
                  final charges = double.tryParse(chargesController.text) ?? 0.0;
                  final request = models.PickupRequest(
                    customerName: nameController.text,
                    customerEmail: emailController.text,
                    customerPhone: phoneController.text,
                    requestType: selectedType,
                    pickupAddress: addressController.text,
                    charges: charges,
                    requestedDate: selectedDate,
                    status: selectedStatus,
                    trackingNumber: trackingController.text.isEmpty ? null : trackingController.text,
                    courierName: courierController.text.isEmpty ? null : courierController.text,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  try {
                    await _pickupService.addRequest(request);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pickup request added successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      await _refreshPickupRequests();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding pickup request: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPickupRequestDialog(models.PickupRequest request) {
    final nameController = TextEditingController(text: request.customerName);
    final emailController = TextEditingController(text: request.customerEmail);
    final phoneController = TextEditingController(text: request.customerPhone);
    final addressController = TextEditingController(text: request.pickupAddress);
    final chargesController = TextEditingController(text: request.charges.toString());
    final notesController = TextEditingController(text: request.notes ?? '');
    final trackingController = TextEditingController(text: request.trackingNumber ?? '');
    final courierController = TextEditingController(text: request.courierName ?? '');
    DateTime selectedDate = request.requestedDate;
    String selectedType = request.requestType;
    String selectedStatus = request.status;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Pickup Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Customer Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Customer Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Request Type'),
                  items: ['manual', 'sewing_request']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setDialogState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Pickup Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Requested Date: ${_formatDate(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: chargesController,
                  decoration: const InputDecoration(labelText: 'Charges'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: trackingController,
                  decoration: const InputDecoration(labelText: 'Tracking Number (optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: courierController,
                  decoration: const InputDecoration(labelText: 'Courier Name (optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['pending', 'accepted', 'completed', 'rejected']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setDialogState(() => selectedStatus = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    addressController.text.isNotEmpty) {
                  
                  setDialogState(() => isSaving = true);

                  final charges = double.tryParse(chargesController.text) ?? 0.0;
                  final updatedRequest = request.copyWith(
                    customerName: nameController.text,
                    customerEmail: emailController.text,
                    customerPhone: phoneController.text,
                    requestType: selectedType,
                    pickupAddress: addressController.text,
                    charges: charges,
                    requestedDate: selectedDate,
                    status: selectedStatus,
                    trackingNumber: trackingController.text.isEmpty ? null : trackingController.text,
                    courierName: courierController.text.isEmpty ? null : courierController.text,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  try {
                    await _pickupService.updateRequest(updatedRequest);
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      
                      // Optimistic Update of Parent State
                      setState(() {
                        final index = _pickupRequests.indexWhere((r) => r.docId == updatedRequest.docId);
                        if (index != -1) {
                          _pickupRequests[index] = updatedRequest;
                        }
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pickup request updated successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // REMOVED: await _refreshPickupRequests(); -> No longer needed
                    }
                  } catch (e) {
                    if (context.mounted) {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating pickup request: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePickupRequestDialog(models.PickupRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pickup Request'),
        content: Text('Are you sure you want to delete pickup request for "${request.customerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (request.docId != null) {
                try {
                  await _pickupService.deleteRequest(request.docId!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pickup request deleted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    _refreshPickupRequests();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting pickup request: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: Pickup request ID not found'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Complaint CRUD Dialogs
  void _showAddComplaintDialog() {
    final nameController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Complaint'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Complaint Message'),
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
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && messageController.text.isNotEmpty) {
                final complaint = models.Complaint(
                  customerName: nameController.text,
                  customerEmail: '', // Default empty email for manual complaints
                  message: messageController.text,
                );
                try {
                  await _complaintsService.addComplaint(complaint);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Complaint added successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await _refreshComplaints();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding complaint: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditComplaintDialog(models.Complaint complaint) {
    final nameController = TextEditingController(text: complaint.customerName);
    final messageController = TextEditingController(text: complaint.message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Complaint'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Complaint Message'),
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
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && messageController.text.isNotEmpty) {
                final updatedComplaint = complaint.copyWith(
                  customerName: nameController.text,
                  message: messageController.text,
                );
                try {
                  await _complaintsService.updateComplaint(updatedComplaint);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Complaint updated successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await _refreshComplaints();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating complaint: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReplyComplaintDialog(models.Complaint complaint) {
    final replyController = TextEditingController(text: complaint.reply ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Complaint'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${complaint.customerName}'),
              const SizedBox(height: 16),
              Text('Message: ${complaint.message}'),
              const SizedBox(height: 16),
              TextField(
                controller: replyController,
                decoration: const InputDecoration(labelText: 'Your Reply'),
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
          ElevatedButton(
            onPressed: () async {
              final updatedComplaint = complaint.copyWith(
                reply: replyController.text.isEmpty ? null : replyController.text,
              );
              try {
                await _complaintsService.updateComplaint(updatedComplaint);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply sent successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  await _refreshComplaints();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending reply: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  void _toggleComplaintResolution(models.Complaint complaint) {
    final updatedComplaint = complaint.copyWith(isResolved: !complaint.isResolved);
    _complaintsService.updateComplaint(updatedComplaint).then((_) {
      if (mounted) {
        _refreshComplaints();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedComplaint.isResolved 
                ? 'Complaint marked as resolved!' 
                : 'Complaint marked as unresolved!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showDeleteComplaintDialog(models.Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: Text('Are you sure you want to delete complaint from "${complaint.customerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (complaint.docId != null) {
                try {
                  await _complaintsService.deleteComplaint(complaint.docId!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Complaint deleted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await _refreshComplaints();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting complaint: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: Complaint ID not found'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    // Encode the location for URL
    final encodedLocation = Uri.encodeComponent(_shopLocation);
    final mapSearchUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
    
    // Create a clickable map preview that opens Google Maps
    return InkWell(
      onTap: () {
        // On web, URLs can be opened via browser
        print('Map URL: $mapSearchUrl');
        // TODO: Implement URL opening with url_launcher package
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Stack(
          children: [
            // Map-like background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPatternPainter(),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.location_on, size: 48, color: Colors.blue[700]),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _shopLocation,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Open in Google Maps',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
  void _showMeasurementRequestActionDialog(MeasurementRequest request) {
    final messageController = TextEditingController();
    final scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Stream updates for this specific request to show real-time chat
          return StreamBuilder<List<MeasurementRequest>>(
            stream: _measurementRequestsService.streamRequests(), // Not optimal but works for now
            builder: (context, snapshot) {
              final updatedReq = snapshot.data?.firstWhere(
                (r) => r.id == request.id, 
                orElse: () => request
              ) ?? request;

              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: 500,
                  height: 600,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: updatedReq.customerPhoto != null 
                              ? CachedNetworkImageProvider(updatedReq.customerPhoto!) 
                              : null,
                            child: updatedReq.customerPhoto == null ? Text(updatedReq.customerName[0]) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Request from ${updatedReq.customerName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Status: ${updatedReq.status.toUpperCase()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      // Chat Area
                      Expanded(
                        child: updatedReq.messages.isEmpty 
                            ? Center(child: Text('No messages yet. Start a conversation!', style: TextStyle(color: Colors.grey[400])))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: updatedReq.messages.length,
                                itemBuilder: (context, index) {
                                  final msg = updatedReq.messages[index];
                                  final isMe = msg['senderId'] == _authService.currentUser?.uid; // Assuming tailor is current user
                                  return Align(
                                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isMe ? const Color(0xFF1f455b) : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg['text'] ?? '',
                                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                                          ),
                                          Text(
                                            DateFormat('HH:mm').format(DateTime.parse(msg['timestamp'])),
                                            style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Input Area
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: const Color(0xFF1f455b),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 20),
                              onPressed: () async {
                                if (messageController.text.trim().isEmpty) return;
                                final text = messageController.text.trim();
                                messageController.clear();
                                
                                final msg = {
                                  'senderId': _authService.currentUser?.uid,
                                  'senderName': 'Tailor', // Should get real name
                                  'text': text,
                                  'timestamp': DateTime.now().toIso8601String(),
                                };
                                await _measurementRequestsService.addMessage(updatedReq.id, msg);
                                // Also update status to 'replied' if pending
                                if (updatedReq.status == 'pending') {
                                   await _measurementRequestsService.updateRequest(updatedReq.copyWith(status: 'replied'));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      // Action Buttons
                      if (updatedReq.status == 'pending' || updatedReq.status == 'replied')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await _measurementRequestsService.updateRequest(updatedReq.copyWith(status: 'rejected'));
                                  if (context.mounted) Navigator.pop(context);
                                }, 
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing...')));
                                    
                                    try {
                                      // 1. Sync with Measurements System (Create/Update Measurement Record)
                                      // Check if measurement profile exists to preserve data
                                      final existing = await _measurementsService.getByCustomerEmail(updatedReq.customerEmail);
                                      
                                      final measurementRecord = models.Measurement(
                                        customerId: updatedReq.customerId,
                                        customerName: updatedReq.customerName,
                                        customerEmail: updatedReq.customerEmail,
                                        customerPhone: updatedReq.customerPhone,
                                        status: 'Scheduled',
                                        measurements: existing?.measurements ?? {}, // Preserve existing
                                        appointmentDate: updatedReq.scheduledDate ?? DateTime.now().add(const Duration(days: 3)), // Default or from request
                                        updatedAt: DateTime.now(),
                                      );
                                      
                                      await _measurementsService.insertOrUpdate(measurementRecord);

                                      // 2. Update Request Status
                                      await _measurementRequestsService.updateRequest(updatedReq.copyWith(status: 'scheduled'));
                                      
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Appointment Scheduled & Added to Measurement List'), backgroundColor: Colors.green),
                                        );
                                      }
                                    } catch (e) {
                                      print('Error scheduling: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), 
                                  child: const Text('Accept / Schedule'),
                                ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }
}

// Custom painter for map-like pattern
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[100]!.withOpacity(0.3)
      ..strokeWidth = 1.5;

    // Draw grid lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimpleDateFormatter {
  final String pattern;
  _SimpleDateFormatter(this.pattern);

  String format(DateTime date) {
    if (pattern == 'E') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1]; // weekday is 1-7
    }
    if (pattern == 'day') {
      return '${date.day}/${date.month}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MeasurementDetailsSheet extends StatefulWidget {
  final models.Measurement measurement;
  final FirestoreMeasurementsService service;
  const _MeasurementDetailsSheet({required this.measurement, required this.service});
  
  @override
  _MeasurementDetailsSheetState createState() => _MeasurementDetailsSheetState();
}

class _MeasurementDetailsSheetState extends State<_MeasurementDetailsSheet> {
  late bool _showGrid;
  
  @override
  void initState() {
    super.initState();
    _showGrid = widget.measurement.measurements.values.any((v) => v > 0) || widget.measurement.status == 'Completed';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _showGrid 
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MeasurementDummy( // Assuming this is the editable table widget
                    measurement: widget.measurement,
                    isEditable: true,
                    onMeasurementUpdated: (updated) async {
                      await widget.service.insertOrUpdate(updated);
                    },
                  ),
                )
              : _buildPendingView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          Expanded(child: Text(widget.measurement.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          StatusBadge(status: widget.measurement.status),
        ],
      ),
    );
  }

  Widget _buildPendingView() {
    final date = widget.measurement.appointmentDate;
    final dateStr = date != null ? '${date.day}/${date.month} at ${date.hour}:${date.minute.toString().padLeft(2,'0')}' : 'Not scheduled';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.orange.shade200),
          const SizedBox(height: 24),
          const Text('Measurements Pending', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Customer is scheduled to visit:', style: TextStyle(color: Colors.grey[600])),
          Text(dateStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showGrid = true),
            icon: const Icon(Icons.add),
            label: const Text('Add Measurements'),
            style: ElevatedButton.styleFrom(
               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
               textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

