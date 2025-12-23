class Tailor {
  final int? id; // legacy local id
  final String? docId; // Firestore doc id
  final String name;
  final String? photo;
  final String description;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? location;
  final String? shopHours;

  Tailor({
    this.id,
    this.docId,
    required this.name,
    this.photo,
    required this.description,
    this.phone,
    this.whatsapp,
    this.email,
    this.location,
    this.shopHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'name': name,
      'photo': photo,
      'description': description,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'location': location,
      'shopHours': shopHours,
    };
  }

  factory Tailor.fromMap(Map<String, dynamic> map) {
    return Tailor(
      id: map['id'] as int?,
      docId: map['docId'] as String?,
      name: map['name'] as String,
      photo: map['photo'] as String?,
      description: map['description'] as String,
      phone: map['phone'] as String?,
      whatsapp: map['whatsapp'] as String?,
      email: map['email'] as String?,
      location: map['location'] as String?,
      shopHours: map['shopHours'] as String?,
    );
  }

  Tailor copyWith({
    int? id,
    String? docId,
    String? name,
    String? photo,
    String? description,
    String? phone,
    String? whatsapp,
    String? email,
    String? location,
    String? shopHours,
  }) {
    return Tailor(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      location: location ?? this.location,
      shopHours: shopHours ?? this.shopHours,
    );
  }
}

