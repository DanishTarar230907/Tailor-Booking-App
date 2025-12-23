class Booking {
  final int? id; // legacy local id (Drift); not used in Firestore
  final String? docId; // Firestore document id
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime bookingDate;
  final String timeSlot; // e.g., "09:00-11:00", "11:00-13:00", "13:00-15:00", "15:00-17:00"
  final String suitType; // e.g., "Formal Suit", "Casual Blazer", "Wedding Suit", etc.
  final bool isUrgent;
  final double charges;
  final String? specialInstructions;
  final String status; // "pending", "approved", "rejected", "completed"
  final String? tailorNotes;
  final DateTime createdAt;

  final String? userId; // Added userId

  Booking({
    this.id,
    this.docId,
    this.userId, // Added
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingDate,
    required this.timeSlot,
    required this.suitType,
    required this.isUrgent,
    required this.charges,
    this.specialInstructions,
    this.status = 'pending',
    this.tailorNotes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Booking copyWith({
    int? id,
    String? docId,
    String? userId, // copyWith
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    DateTime? bookingDate,
    String? timeSlot,
    String? suitType,
    bool? isUrgent,
    double? charges,
    String? specialInstructions,
    String? status,
    String? tailorNotes,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      userId: userId ?? this.userId, // copyWith
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      suitType: suitType ?? this.suitType,
      isUrgent: isUrgent ?? this.isUrgent,
      charges: charges ?? this.charges,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      status: status ?? this.status,
      tailorNotes: tailorNotes ?? this.tailorNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docId': docId,
      'userId': userId, // toJson
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'suitType': suitType,
      'isUrgent': isUrgent ? 1 : 0,
      'charges': charges,
      'specialInstructions': specialInstructions,
      'status': status,
      'tailorNotes': tailorNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      docId: json['docId'],
      userId: json['userId'], // fromJson
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      bookingDate: DateTime.parse(json['bookingDate']),
      timeSlot: json['timeSlot'],
      suitType: json['suitType'],
      isUrgent: json['isUrgent'] == 1 || json['isUrgent'] == true,
      charges: json['charges']?.toDouble() ?? 0.0,
      specialInstructions: json['specialInstructions'],
      status: json['status'] ?? 'pending',
      tailorNotes: json['tailorNotes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

