import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faq_item.dart';

class FirestoreFaqService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('faqItems');

  FaqItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FaqItem.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> _toMap(FaqItem faq) {
    return faq.toMap();
  }

  Future<FaqItem> addFaq(FaqItem faq) async {
    final doc = await _collection.add(_toMap(faq));
    return faq.copyWith(docId: doc.id);
  }

  Future<void> updateFaq(FaqItem faq) async {
    if (faq.docId == null) {
      throw Exception('Cannot update FAQ without Firestore docId');
    }
    await _collection.doc(faq.docId).update(_toMap(faq.copyWith(
      updatedAt: DateTime.now(),
    )));
  }

  Future<void> deleteFaq(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<List<FaqItem>> getAllFaqs() async {
    final snap = await _collection.orderBy('order').orderBy('createdAt').get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<FaqItem>> searchFaqs(String query) async {
    final snap = await _collection.get();
    final allFaqs = snap.docs.map(_fromDoc).toList();
    
    final lowercaseQuery = query.toLowerCase();
    return allFaqs.where((faq) {
      return faq.question.toLowerCase().contains(lowercaseQuery) ||
          faq.answer.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<FaqItem>> getFaqsByCategory(String category) async {
    final snap = await _collection
        .where('category', isEqualTo: category)
        .orderBy('order')
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<void> updateFaqOrder(String docId, int newOrder) async {
    await _collection.doc(docId).update({
      'order': newOrder,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<FaqItem>> streamFaqs() {
    return _collection
        .orderBy('order')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Stream<List<FaqItem>> streamFaqsByCategory(String category) {
    return _collection
        .where('category', isEqualTo: category)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }
}
