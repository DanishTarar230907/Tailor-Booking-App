class FaqItem {
  final String? docId; // Firestore document id
  final String question;
  final String answer;
  final String category; // e.g., 'shop_info', 'measurement', 'delivery', 'payment', 'pickup'
  final int order; // for custom ordering
  final DateTime createdAt;
  final DateTime updatedAt;

  FaqItem({
    this.docId,
    required this.question,
    required this.answer,
    required this.category,
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FaqItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime _toDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return FaqItem(
      docId: docId,
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      order: map['order'] as int? ?? 0,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  FaqItem copyWith({
    String? docId,
    String? question,
    String? answer,
    String? category,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqItem(
      docId: docId ?? this.docId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
