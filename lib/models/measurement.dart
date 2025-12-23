class Measurement {
  final int? id; // legacy local id
  final String? docId; // Firestore document id
  final String customerId; // Linked User UID
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  
  // Dynamic measurements map (key: measurement name, value: value)
  // e.g. {'Chest': 40.0, 'Waist': 32.0, 'Cuff': 10.5}
  final Map<String, double> measurements;
  
  // Status and Workflow
  final String status; // 'Pending', 'Accepted'
  final bool stitchingStarted;
  final DateTime? stitchingStartDate;
  final String? specialInstructions;
  
  // Legacy note field (optional, can be merged into specialInstructions or kept)
  final String? notes;
  
  // Communication
  final bool updateRequested;
  final List<Map<String, dynamic>> messages;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? requestType; // 'visit', 'online', or null
  final DateTime? appointmentDate;
  final String? rejectionReason;
  // TODO: Add unread counts in future update if needed specifically for this model, 
  // or handle via separate collection/stream. For now, sticking to core request logic.

  Measurement({
    this.docId,
    this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.measurements = const {},
    this.status = 'Pending',
    this.stitchingStarted = false,
    this.stitchingStartDate,
    this.specialInstructions,
    this.notes, // Tailor notes
    this.updateRequested = false,
    this.messages = const [],
    DateTime? createdAt,
    this.updatedAt,
    this.requestType,
    this.appointmentDate,
    this.rejectionReason,
  }) : createdAt = createdAt ?? DateTime.now();

  Measurement copyWith({
    String? docId,
    int? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    Map<String, double>? measurements,
    String? status,
    bool? stitchingStarted,
    DateTime? stitchingStartDate,
    String? specialInstructions,
    String? notes,
    bool? updateRequested,
    List<Map<String, dynamic>>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? requestType,
    DateTime? appointmentDate,
    String? rejectionReason,
  }) {
    return Measurement(
      docId: docId ?? this.docId,
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      measurements: measurements ?? this.measurements,
      status: status ?? this.status,
      stitchingStarted: stitchingStarted ?? this.stitchingStarted,
      stitchingStartDate: stitchingStartDate ?? this.stitchingStartDate,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      notes: notes ?? this.notes,
      updateRequested: updateRequested ?? this.updateRequested,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requestType: requestType ?? this.requestType,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
  
  // Helper accessors for common measurements to maintain backward compatibility if needed in UI locally,
  // though it's better to access via map['key'].
  double? get chest => measurements['Chest'];
  double? get waist => measurements['Waist'];
  double? get hips => measurements['Hips'];
  double? get shoulder => measurements['Shoulder'];
  double? get sleeveLength => measurements['Sleeve Length'];
  double? get shirtLength => measurements['Shirt Length'];
  double? get pantLength => measurements['Trouser Length']; // Mapped 'Trouser Length' to old 'pantLength' concept
  double? get inseam => measurements['Inseam'];
  double? get neck => measurements['Neck'];
}

