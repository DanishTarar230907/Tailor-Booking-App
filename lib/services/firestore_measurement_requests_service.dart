import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/measurement_request.dart';

class FirestoreMeasurementRequestsService {
  final CollectionReference _requestsCollection =
      FirebaseFirestore.instance.collection('measurement_requests');

  // Stream all requests (Tailor View)
  Stream<List<MeasurementRequest>> streamRequests() {
    return _requestsCollection.orderBy('requestedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MeasurementRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream customer requests (Customer View)
  Stream<List<MeasurementRequest>> streamCustomerRequests(String customerId) {
    return _requestsCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MeasurementRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add new request
  Future<void> addRequest(MeasurementRequest request) async {
    await _requestsCollection.add(request.toMap());
  }

  // Update request (Status, Messages, etc.)
  Future<void> updateRequest(MeasurementRequest request) async {
    if (request.id.isEmpty) return;
    await _requestsCollection.doc(request.id).update(request.toMap());
  }

  // Add message to request
  Future<void> addMessage(String requestId, Map<String, dynamic> message) async {
    await _requestsCollection.doc(requestId).update({
      'messages': FieldValue.arrayUnion([message])
    });
  }
}
