import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class FirestoreNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  AppNotification _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppNotification.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> _toMap(AppNotification notification) {
    return notification.toMap();
  }

  Future<AppNotification> createNotification(AppNotification notification) async {
    final doc = await _collection.add(_toMap(notification));
    return notification.copyWith(docId: doc.id);
  }

  Future<List<AppNotification>> getUserNotifications(String userId, {int limit = 50}) async {
    final snap = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final snap = await _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    return snap.docs.length;
  }

  Future<void> markAsRead(String docId) async {
    await _collection.doc(docId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String docId) async {
    await _collection.doc(docId).delete();
  }

  Stream<List<AppNotification>> streamUserNotifications(String userId) {
    final controller = StreamController<List<AppNotification>>();
    StreamSubscription? sub;

    void startFallback() {
      sub = _collection
          .where('userId', isEqualTo: userId)
          .limit(50)
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
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
          (snap) => controller.add(snap.docs.map(_fromDoc).toList()),
          onError: (e) {
            print('Notifications Stream Index Error, falling back: $e');
            sub?.cancel();
            startFallback();
          },
          onDone: () => controller.close(),
        );

    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }

  Stream<int> streamUnreadCount(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // Helper methods for specific notification types
  Future<void> notifyPickupStatusChange({
    required String userId,
    required String pickupDocId,
    required String customerName,
    required String newStatus,
  }) async {
    String title = 'Pickup Status Updated';
    String message = '';

    switch (newStatus) {
      case 'received':
        message = 'Your parcel has been received by the tailor';
        break;
      case 'not_received':
        message = 'Your parcel was not received';
        break;
      case 'delayed':
        message = 'Your pickup has been rescheduled';
        break;
      case 'completed':
        message = 'Your pickup request has been completed';
        break;
      default:
        message = 'Your pickup status has been updated to $newStatus';
    }

    await createNotification(AppNotification(
      userId: userId,
      type: 'pickup_status',
      title: title,
      message: message,
      relatedDocId: pickupDocId,
    ));
  }

  Future<void> notifyComplaintReply({
    required String userId,
    required String complaintDocId,
    required String tailorName,
  }) async {
    await createNotification(AppNotification(
      userId: userId,
      type: 'complaint_reply',
      title: 'New Reply to Your Complaint',
      message: '$tailorName has replied to your complaint',
      relatedDocId: complaintDocId,
    ));
  }

  Future<void> notifyComplaintStatusChange({
    required String userId,
    required String complaintDocId,
    required String newStatus,
  }) async {
    String message = '';
    switch (newStatus) {
      case 'in_progress':
        message = 'Your complaint is being reviewed';
        break;
      case 'resolved':
        message = 'Your complaint has been resolved';
        break;
      default:
        message = 'Your complaint status has been updated';
    }

    await createNotification(AppNotification(
      userId: userId,
      type: 'complaint_status',
      title: 'Complaint Status Updated',
      message: message,
      relatedDocId: complaintDocId,
    ));
  }
}
