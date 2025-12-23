import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database_helper.dart';
import '../models/tailor.dart' as models;
import '../models/design.dart' as models;
import '../models/complaint.dart' as models;
import '../models/measurement.dart' as models;
import '../models/pickup_request.dart' as models;
import 'tailor_bookings_screen.dart';
import 'tailor_measurements_tab.dart';
import 'tailor_pickup_requests_tab.dart';
import '../widgets/measurement_dummy.dart';
import 'pickup_request_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_designs_service.dart';
import '../services/firestore_complaints_service.dart';
import '../services/firestore_pickup_requests_service.dart';
import '../services/firestore_tailor_service.dart';

class TailorDashboard extends StatefulWidget {
  const TailorDashboard({super.key});

  @override
  State<TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends State<TailorDashboard> {
  // All entities now via Firestore services.
  final AppDatabase _db = DatabaseHelper.instance.database;
  final AuthService _authService = AuthService();
  final FirestoreDesignsService _designsService = FirestoreDesignsService();
  final FirestoreComplaintsService _complaintsService =
      FirestoreComplaintsService();
  final FirestorePickupRequestsService _pickupService =
      FirestorePickupRequestsService();
  final FirestoreTailorService _tailorService = FirestoreTailorService();
  models.Tailor? _tailor;
  List<models.Design> _designs = [];
  List<models.Complaint> _complaints = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tailor = await _tailorService.getTailor();
      final designs = await _designsService.getAllDesigns();
      final complaints = await _complaintsService.getAllComplaints();
      setState(() {
        _tailor = tailor;
        _designs = designs;
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return null;
      
      if (kIsWeb) {
        // For web, convert to base64 data URL
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        return 'data:image/${image.path.split('.').last};base64,$base64Image';
      } else {
        // For mobile, return file path (or convert to base64 if needed)
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        return 'data:image/${image.path.split('.').last};base64,$base64Image';
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  void _showEditTailorDialog() {
    final nameController = TextEditingController(text: _tailor?.name ?? '');
    final descController = TextEditingController(text: _tailor?.description ?? '');
    final photoController = TextEditingController(text: _tailor?.photo ?? '');
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Tailor Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview
                if (selectedImagePath != null || (photoController.text.isNotEmpty && !photoController.text.startsWith('data:')))
                  Container(
                    height: 150,
                    width: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: selectedImagePath != null
                          ? Image.memory(
                              base64Decode(selectedImagePath!.split(',')[1]),
                              fit: BoxFit.cover,
                            )
                          : photoController.text.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: photoController.text,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                )
                              : const Icon(Icons.person, size: 50),
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: photoController,
                        decoration: const InputDecoration(
                          labelText: 'Photo URL',
                          border: OutlineInputBorder(),
                          hintText: 'Enter URL or pick image',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () async {
                        final imagePath = await _pickImage();
                        if (imagePath != null) {
                          selectedImagePath = imagePath;
                          photoController.text = imagePath;
                          setDialogState(() {});
                        }
                      },
                      tooltip: 'Pick Image',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                final photoUrl = selectedImagePath ?? 
                    (photoController.text.trim().isEmpty ? null : photoController.text.trim());
                final tailor = models.Tailor(
                  name: nameController.text.trim(),
                  photo: photoUrl,
                  description: descController.text.trim(),
                );
                await _db.insertOrUpdateTailor(tailor);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDesignDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final photoController = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Design'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview
                if (selectedImagePath != null || photoController.text.isNotEmpty)
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: selectedImagePath != null
                          ? Image.memory(
                              base64Decode(selectedImagePath!.split(',')[1]),
                              fit: BoxFit.cover,
                            )
                          : photoController.text.isNotEmpty && !photoController.text.startsWith('data:')
                              ? CachedNetworkImage(
                                  imageUrl: photoController.text,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                )
                              : const Center(child: Icon(Icons.image, size: 50)),
                    ),
                  ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: photoController,
                        decoration: const InputDecoration(
                          labelText: 'Photo URL',
                          border: OutlineInputBorder(),
                          hintText: 'Enter URL or pick image',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () async {
                        final imagePath = await _pickImage();
                        if (imagePath != null) {
                          selectedImagePath = imagePath;
                          photoController.text = imagePath;
                          setDialogState(() {});
                        }
                      },
                      tooltip: 'Pick Image',
                    ),
                  ],
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
                final price = double.tryParse(priceController.text);
                if (titleController.text.trim().isEmpty || price == null) {
                  return;
                }
                final photoUrl = selectedImagePath ?? 
                    (photoController.text.trim().isEmpty ? null : photoController.text.trim());
                final design = models.Design(
                  title: titleController.text.trim(),
                  price: price,
                  photo: photoUrl,
                );
                await _db.insertDesign(design);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDesignDialog(models.Design design) {
    final titleController = TextEditingController(text: design.title);
    final priceController = TextEditingController(text: design.price.toString());
    final photoController = TextEditingController(text: design.photo ?? '');
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Design'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview
                if (selectedImagePath != null || (photoController.text.isNotEmpty && !photoController.text.startsWith('data:')))
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: selectedImagePath != null
                          ? Image.memory(
                              base64Decode(selectedImagePath!.split(',')[1]),
                              fit: BoxFit.cover,
                            )
                          : photoController.text.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: photoController.text,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                )
                              : const Center(child: Icon(Icons.image, size: 50)),
                    ),
                  ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: photoController,
                        decoration: const InputDecoration(
                          labelText: 'Photo URL',
                          border: OutlineInputBorder(),
                          hintText: 'Enter URL or pick image',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () async {
                        final imagePath = await _pickImage();
                        if (imagePath != null) {
                          selectedImagePath = imagePath;
                          photoController.text = imagePath;
                          setDialogState(() {});
                        }
                      },
                      tooltip: 'Pick Image',
                    ),
                  ],
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
                final price = double.tryParse(priceController.text);
                if (titleController.text.trim().isEmpty || price == null) {
                  return;
                }
                final photoUrl = selectedImagePath ?? 
                    (photoController.text.trim().isEmpty ? null : photoController.text.trim());
                final updatedDesign = design.copyWith(
                  title: titleController.text.trim(),
                  price: price,
                  photo: photoUrl,
                );
                await _db.updateDesign(updatedDesign);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyComplaintDialog(models.Complaint complaint) {
    final replyController = TextEditingController(text: complaint.reply ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${complaint.customerName}'),
            const SizedBox(height: 8),
            Text('Message: ${complaint.message}'),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                labelText: 'Your Reply',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedComplaint = complaint.copyWith(
                reply: replyController.text.trim(),
                isResolved: replyController.text.trim().isNotEmpty,
              );
              await _db.updateComplaint(updatedComplaint);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Send Reply'),
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
            title: const Text('Tailor Dashboard'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDatabaseInfoDialog,
            tooltip: 'Database Info',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildProfileTab(),
                _buildDesignsTab(),
                _buildBookingsTab(),
                _buildMeasurementsTab(),
                _buildPickupRequestsTab(),
                _buildComplaintsTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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
    );
  }

  Widget _buildProfileTab() {
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
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundImage: _tailor?.photo != null && _tailor!.photo!.isNotEmpty
                    ? (_tailor!.photo!.startsWith('data:')
                        ? MemoryImage(base64Decode(_tailor!.photo!.split(',')[1])) as ImageProvider
                        : CachedNetworkImageProvider(_tailor!.photo!) as ImageProvider)
                    : null,
                child: _tailor?.photo == null || _tailor!.photo!.isEmpty
                    ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary)
                    : null,
                onBackgroundImageError: _tailor?.photo != null && _tailor!.photo!.isNotEmpty
                    ? (exception, stackTrace) {
                        // Handle image error
                      }
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _tailor?.name ?? 'No name set',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Enhanced Description Card
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
                          child: const Icon(Icons.description, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _tailor?.description ?? 'No description set',
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
          const SizedBox(height: 24),
          // Enhanced Edit Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showEditTailorDialog,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Designs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddDesignDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Design'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _designs.isEmpty
              ? const Center(
                  child: Text('No designs yet. Add your first design!'),
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
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: design.photo != null && design.photo!.isNotEmpty
                                ? (design.photo!.startsWith('data:')
                                    ? Image.memory(
                                        base64Decode(design.photo!.split(',')[1]),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image, size: 50),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: design.photo!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(child: CircularProgressIndicator()),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image, size: 50),
                                        ),
                                      ))
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  design.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${design.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _showEditDesignDialog(design),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () async {
                                        await _db.deleteDesign(design.id!);
                                        _loadData();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return const TailorBookingsScreen();
  }

  Widget _buildMeasurementsTab() {
    return const TailorMeasurementsTab();
  }

  Widget _buildPickupRequestsTab() {
    return const TailorPickupRequestsTab();
  }

  Widget _buildComplaintsTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Customer Complaints',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: _complaints.isEmpty
              ? const Center(
                  child: Text('No complaints yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  complaint.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (complaint.isResolved)
                                  Chip(
                                    label: const Text('Resolved'),
                                    backgroundColor: Colors.green[100],
                                  )
                                else
                                  Chip(
                                    label: const Text('Pending'),
                                    backgroundColor: Colors.orange[100],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(complaint.message),
                            if (complaint.reply != null && complaint.reply!.isNotEmpty) ...[
                              const SizedBox(height: 16),
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
                                      'Your Reply:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(complaint.reply!),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!complaint.isResolved)
                                  TextButton.icon(
                                    onPressed: () => _showReplyComplaintDialog(complaint),
                                    icon: const Icon(Icons.reply),
                                    label: const Text('Reply'),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _db.deleteComplaint(complaint.id!);
                                    _loadData();
                                  },
                                ),
                              ],
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
                    if (stats['resolvedComplaints'] != null)
                      Text('Resolved Complaints: ${stats['resolvedComplaints']}'),
                    if (stats['pendingComplaints'] != null)
                      Text('Pending Complaints: ${stats['pendingComplaints']}'),
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
    final designs = await _designsService.getAllDesigns();
      final complaints = await _complaintsService.getAllComplaints();
      final resolvedCount = complaints.where((c) => c.isResolved).length;
      final pendingCount = complaints.length - resolvedCount;
      return {
        'tailors': tailor != null ? 1 : 0,
        'designs': designs.length,
        'complaints': complaints.length,
        'resolvedComplaints': resolvedCount,
        'pendingComplaints': pendingCount,
      };
    } catch (e) {
      return {'error': 0};
    }
  }
}

