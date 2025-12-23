class Design {
  final int? id; // legacy local id
  final String? docId; // Firestore doc id
  final String title;
  final String? photo;
  final double price;
  final String status; // 'new', 'in_progress', 'completed'
  final DateTime createdAt;

  Design({
    this.id,
    this.docId,
    required this.title,
    this.photo,
    required this.price,
    this.status = 'new',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'photo': photo,
      'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Design.fromMap(Map<String, dynamic> map) {
    return Design(
      id: map['id'] as int?,
      docId: map['docId'] as String?,
      title: map['title'] as String,
      photo: map['photo'] as String?,
      price: (map['price'] as num).toDouble(),
      status: map['status'] as String? ?? 'new',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Design copyWith({
    int? id,
    String? docId,
    String? title,
    String? photo,
    double? price,
    String? status,
    DateTime? createdAt,
  }) {
    return Design(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      title: title ?? this.title,
      photo: photo ?? this.photo,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

