class MeasurementRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? customerPhoto;
  final String? tailorId;
  final String status; // 'pending', 'replied', 'scheduled', 'completed', 'cancelled'
  final String requestType; // 'new', 'renewal'
  final DateTime requestedAt;
  final DateTime? scheduledDate;
  final String? notes;
  final List<Map<String, dynamic>> messages;

  MeasurementRequest({
    String? id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.customerPhoto,
    this.tailorId,
    this.status = 'pending',
    this.requestType = 'new',
    DateTime? requestedAt,
    this.scheduledDate,
    this.notes,
    this.messages = const [],
  })  : id = id ?? '',
        requestedAt = requestedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerPhoto': customerPhoto,
      'tailorId': tailorId,
      'status': status,
      'requestType': requestType,
      'requestedAt': requestedAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'notes': notes,
      'messages': messages,
    };
  }

  factory MeasurementRequest.fromMap(Map<String, dynamic> map, String id) {
    return MeasurementRequest(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerPhoto: map['customerPhoto'],
      tailorId: map['tailorId'],
      status: map['status'] ?? 'pending',
      requestType: map['requestType'] ?? 'new',
      requestedAt: map['requestedAt'] != null
          ? DateTime.parse(map['requestedAt'])
          : DateTime.now(),
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.parse(map['scheduledDate'])
          : null,
      notes: map['notes'],
      messages: List<Map<String, dynamic>>.from(map['messages'] ?? []),
    );
  }

  MeasurementRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerPhoto,
    String? tailorId,
    String? status,
    String? requestType,
    DateTime? requestedAt,
    DateTime? scheduledDate,
    String? notes,
    List<Map<String, dynamic>>? messages,
  }) {
    return MeasurementRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      tailorId: tailorId ?? this.tailorId,
      status: status ?? this.status,
      requestType: requestType ?? this.requestType,
      requestedAt: requestedAt ?? this.requestedAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      messages: messages ?? this.messages,
    );
  }
}
