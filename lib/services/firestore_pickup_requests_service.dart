import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';

class FirestorePickupRequestsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('pickupRequests');

  PickupRequest _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PickupRequest.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> _toMap(PickupRequest r) {
    return r.toMap();
  }

  Future<PickupRequest> addRequest(PickupRequest request) async {
    final doc = await _collection.add(_toMap(request));
    return request.copyWith(docId: doc.id);
  }

  Future<void> updateRequest(PickupRequest request) async {
    if (request.docId == null) {
      throw Exception('Cannot update pickup request without Firestore docId');
    }
    await _collection.doc(request.docId).update(_toMap(request));
  }

  Future<void> updateStatus(String docId, String status) async {
    await _collection.doc(docId).update({'status': status});
  }

  Future<void> addTailorNotes(String docId, String notes) async {
    await _collection.doc(docId).update({'tailorNotes': notes});
  }

  Future<void> reschedulePickup(String docId, DateTime newDate) async {
    await _collection.doc(docId).update({
      'rescheduledDate': newDate.toIso8601String(),
      'status': 'delayed',
    });
  }

  Future<void> deleteRequest(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<List<PickupRequest>> getAllRequests() async {
    // Limit to 100 most recent requests for better performance
    final snap = await _collection.orderBy('createdAt', descending: true).limit(100).get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<PickupRequest>> getRequestsByStatus(String status) async {
    final snap = await _collection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<PickupRequest>> getTodaysPickups() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snap = await _collection
        .where('expectedDeliveryDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('expectedDeliveryDate', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('expectedDeliveryDate')
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<PickupRequest>> getPickupsByDateRange(DateTime start, DateTime end) async {
    final snap = await _collection
        .where('expectedDeliveryDate', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('expectedDeliveryDate', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('expectedDeliveryDate')
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Stream<List<PickupRequest>> streamRequests() {
    final controller = StreamController<List<PickupRequest>>();
    StreamSubscription? sub;

    void startFallback() {
      sub = _collection.snapshots().listen(
        (snap) {
          final list = snap.docs.map(_fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          controller.add(list);
        },
        onError: (e) => controller.addError(e),
        onDone: () => controller.close(),
      );
    }

    sub = _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snap) => controller.add(snap.docs.map(_fromDoc).toList()),
          onError: (e) {
            print('Pickup Stream Index Error, falling back: $e');
            sub?.cancel();
            startFallback();
          },
          onDone: () => controller.close(),
        );

    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }

  Stream<List<PickupRequest>> streamRequestsByStatus(String status) {
    final controller = StreamController<List<PickupRequest>>();
    StreamSubscription? sub;

    void startFallback() {
      sub = _collection
          .where('status', isEqualTo: status)
          .snapshots()
          .listen(
            (snap) {
              final list = snap.docs.map(_fromDoc).toList();
              list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              controller.add(list);
            },
            onError: (e) => controller.addError(e),
            onDone: () => controller.close(),
          );
    }

    sub = _collection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snap) => controller.add(snap.docs.map(_fromDoc).toList()),
          onError: (e) {
            print('Pickup Status Stream Index Error, falling back: $e');
            sub?.cancel();
            startFallback();
          },
          onDone: () => controller.close(),
        );

    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }
}

