import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

/// Firestore-backed bookings service for shared, real-time data across devices.
class FirestoreBookingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('bookings');

  Booking _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    // Firestore stores timestamps as Timestamp; convert safely.
    DateTime _toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Booking(
      docId: doc.id,
      id: data['id'],
      userId: data['userId'], // Added
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      bookingDate: _toDate(data['bookingDate']),
      timeSlot: data['timeSlot'] ?? '',
      suitType: data['suitType'] ?? '',
      isUrgent: data['isUrgent'] == true || data['isUrgent'] == 1,
      charges: (data['charges'] is num) ? (data['charges'] as num).toDouble() : 0.0,
      specialInstructions: data['specialInstructions'],
      status: data['status'] ?? 'pending',
      tailorNotes: data['tailorNotes'],
      createdAt: _toDate(data['createdAt']),
    );
  }

  Map<String, dynamic> _toMap(Booking booking) {
    return {
      'userId': booking.userId, // Added
      'customerName': booking.customerName,
      'customerEmail': booking.customerEmail,
      'customerPhone': booking.customerPhone,
      'bookingDate': booking.bookingDate,
      'timeSlot': booking.timeSlot,
      'suitType': booking.suitType,
      'isUrgent': booking.isUrgent,
      'charges': booking.charges,
      'specialInstructions': booking.specialInstructions,
      'status': booking.status,
      'tailorNotes': booking.tailorNotes,
      'createdAt': booking.createdAt,
    };
  }

  Future<Booking> addBooking(Booking booking) async {
    final doc = await _collection.add(_toMap(booking));
    return booking.copyWith(docId: doc.id);
  }

  Future<void> updateBooking(Booking booking) async {
    if (booking.docId == null) {
      throw Exception('Cannot update booking without a Firestore docId');
    }
    await _collection.doc(booking.docId).update(_toMap(booking));
  }

  Future<void> deleteBooking(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<List<Booking>> getAllBookings() async {
    // Limit to 200 most recent bookings for better performance
    try {
      final snapshot =
          await _collection.orderBy('bookingDate', descending: true).limit(200).get();
      return snapshot.docs.map(_fromDoc).toList();
    } catch (e) {
      // Fallback if composite index is missing
      print('Index error, fetching without orderBy: $e');
      final snapshot = await _collection.limit(200).get();
      final bookings = snapshot.docs.map(_fromDoc).toList();
      bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      return bookings;
    }
  }

  Stream<List<Booking>> streamAllBookings() {
    return _collection
        .orderBy('bookingDate')
        .orderBy('timeSlot')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Future<int> getBookingsCountForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    // Simplified query to avoid index requirement - filter in memory instead
    final snapshot = await _collection
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
        .where('bookingDate', isLessThanOrEqualTo: endOfDay)
        .get();
    // Filter by status in memory to avoid composite index requirement
    return snapshot.docs.where((doc) {
      final status = doc.data()['status'] ?? 'pending';
      return status == 'pending' || status == 'approved';
    }).length;
  }

  Future<List<Booking>> getBookingsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final snapshot = await _collection
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
        .where('bookingDate', isLessThanOrEqualTo: endOfDay)
        .get();
    return snapshot.docs.map(_fromDoc).toList();
  }
  Stream<List<Booking>> streamBookingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _collection
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
        .where('bookingDate', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }
}

