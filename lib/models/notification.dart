class AppNotification {
  final String? docId; // Firestore document id
  final String userId; // User who should receive this notification
  final String type; // 'pickup_status', 'complaint_reply', 'complaint_status', 'booking_update'
  final String title;
  final String message;
  final String? relatedDocId; // ID of related pickup/complaint/booking
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    this.docId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedDocId,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'relatedDocId': relatedDocId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime _toDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return AppNotification(
      docId: docId,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      relatedDocId: map['relatedDocId'] as String?,
      isRead: map['isRead'] == true || map['isRead'] == 1,
      createdAt: _toDate(map['createdAt']),
    );
  }

  AppNotification copyWith({
    String? docId,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? relatedDocId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedDocId: relatedDocId ?? this.relatedDocId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
