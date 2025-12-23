class PickupRequest {
  final int? id; // legacy local id
  final String? docId; // Firestore document id
  final int? relatedBookingId; // legacy local booking id (for Drift compatibility)
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String requestType; // 'sewing_request' or 'manual'
  final String? relatedBookingDocId; // Firestore booking doc id, if linked
  final String pickupAddress;
  final String? trackingNumber;
  final String? courierName;
  final String status; // 'pending', 'received', 'not_received', 'completed', 'rejected', 'delayed'
  final double charges;
  final String? notes;
  final DateTime requestedDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  
  // New fields for enhanced pickup/parcel management
  final String pickupType; // 'online_order' or 'manual_delivery'
  final DateTime? expectedDeliveryDate;
  final String? description; // e.g., "3-piece suit fabric"
  final String? tailorNotes; // Internal notes for tailor
  final DateTime? rescheduledDate; // For delayed pickups

  PickupRequest({
    this.id,
    this.docId,
    this.relatedBookingId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.requestType,
    this.relatedBookingDocId,
    required this.pickupAddress,
    this.trackingNumber,
    this.courierName,
    this.status = 'pending',
    required this.charges,
    this.notes,
    required this.requestedDate,
    this.completedDate,
    DateTime? createdAt,
    this.pickupType = 'manual_delivery',
    this.expectedDeliveryDate,
    this.description,
    this.tailorNotes,
    this.rescheduledDate,
  }) : createdAt = createdAt ?? DateTime.now();

  PickupRequest copyWith({
    int? id,
    String? docId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? requestType,
    int? relatedBookingId,
    String? relatedBookingDocId,
    String? pickupAddress,
    String? trackingNumber,
    String? courierName,
    String? status,
    double? charges,
    String? notes,
    DateTime? requestedDate,
    DateTime? completedDate,
    DateTime? createdAt,
    String? pickupType,
    DateTime? expectedDeliveryDate,
    String? description,
    String? tailorNotes,
    DateTime? rescheduledDate,
  }) {
    return PickupRequest(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      requestType: requestType ?? this.requestType,
      relatedBookingDocId:
          relatedBookingDocId ?? this.relatedBookingDocId,
      relatedBookingId: relatedBookingId ?? this.relatedBookingId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierName: courierName ?? this.courierName,
      status: status ?? this.status,
      charges: charges ?? this.charges,
      notes: notes ?? this.notes,
      requestedDate: requestedDate ?? this.requestedDate,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      pickupType: pickupType ?? this.pickupType,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      description: description ?? this.description,
      tailorNotes: tailorNotes ?? this.tailorNotes,
      rescheduledDate: rescheduledDate ?? this.rescheduledDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'requestType': requestType,
      'relatedBookingDocId': relatedBookingDocId,
      'pickupAddress': pickupAddress,
      'trackingNumber': trackingNumber,
      'courierName': courierName,
      'status': status,
      'charges': charges,
      'notes': notes,
      'requestedDate': requestedDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'pickupType': pickupType,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'description': description,
      'tailorNotes': tailorNotes,
      'rescheduledDate': rescheduledDate?.toIso8601String(),
    };
  }

  factory PickupRequest.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime _toDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    DateTime? _toDateNullable(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return PickupRequest(
      docId: docId,
      id: map['id'] as int?,
      customerName: map['customerName'] as String? ?? '',
      customerEmail: map['customerEmail'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      requestType: map['requestType'] as String? ?? 'manual',
      relatedBookingDocId: map['relatedBookingDocId'] as String?,
      pickupAddress: map['pickupAddress'] as String? ?? '',
      trackingNumber: map['trackingNumber'] as String?,
      courierName: map['courierName'] as String?,
      status: map['status'] as String? ?? 'pending',
      charges: (map['charges'] is num) ? (map['charges'] as num).toDouble() : 0.0,
      notes: map['notes'] as String?,
      requestedDate: _toDate(map['requestedDate']),
      completedDate: _toDateNullable(map['completedDate']),
      createdAt: _toDate(map['createdAt']),
      pickupType: map['pickupType'] as String? ?? 'manual_delivery',
      expectedDeliveryDate: _toDateNullable(map['expectedDeliveryDate']),
      description: map['description'] as String?,
      tailorNotes: map['tailorNotes'] as String?,
      rescheduledDate: _toDateNullable(map['rescheduledDate']),
    );
  }
}

