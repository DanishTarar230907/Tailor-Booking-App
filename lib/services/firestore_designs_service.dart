import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/design.dart';

class FirestoreDesignsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('designs');

  Design _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime _toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Design(
      docId: doc.id,
      id: data['id'], // legacy, usually null
      title: data['title'] ?? '',
      photo: data['photo'],
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      createdAt: _toDate(data['createdAt']),
    );
  }

  Map<String, dynamic> _toMap(Design design) {
    return {
      'title': design.title,
      'photo': design.photo,
      'price': design.price,
      'createdAt': design.createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  Stream<List<Design>> streamDesigns() {
    final controller = StreamController<List<Design>>();
    StreamSubscription? sub;

    void startFallback() {
      sub = _collection.limit(50).snapshots().listen(
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
        .limit(50)
        .snapshots()
        .listen(
          (snap) => controller.add(snap.docs.map(_fromDoc).toList()),
          onError: (e) {
            print('Designs Stream Index Error, falling back: $e');
            sub?.cancel();
            startFallback();
          },
          onDone: () => controller.close(),
        );

    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }

  Future<List<Design>> getAllDesigns() async {
    try {
      // Limit to 50 most recent designs for better performance
      final snap = await _collection
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs.map(_fromDoc).toList();
    } catch (e) {
      // If index error, get without ordering and sort in memory
      print('Index error, fetching without orderBy: $e');
      final snap = await _collection.limit(50).get();
      final designs = snap.docs.map(_fromDoc).toList();
      designs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return designs;
    }
  }

  Future<Design> addDesign(Design design) async {
    // Ensure createdAt is set
    final data = _toMap(design);
    if (data['createdAt'] == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    final doc = await _collection.add(data);
    // Get the created document to return with proper createdAt
    final createdDoc = await doc.get();
    return _fromDoc(createdDoc);
  }

  Future<void> updateDesign(Design design) async {
    if (design.docId == null) {
      throw Exception('Cannot update design without Firestore docId');
    }
    await _collection.doc(design.docId).update(_toMap(design));
  }

  Future<void> deleteDesign(String docId) async {
    await _collection.doc(docId).delete();
  }
}

