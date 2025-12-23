// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_helper.dart';

// ignore_for_file: type=lint
class $TailorsTable extends Tailors with TableInfo<$TailorsTable, Tailor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TailorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
      'photo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, photo, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tailors';
  @override
  VerificationContext validateIntegrity(Insertable<Tailor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('photo')) {
      context.handle(
          _photoMeta, photo.isAcceptableOrUnknown(data['photo']!, _photoMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tailor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tailor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      photo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $TailorsTable createAlias(String alias) {
    return $TailorsTable(attachedDatabase, alias);
  }
}

class Tailor extends DataClass implements Insertable<Tailor> {
  final int id;
  final String name;
  final String? photo;
  final String description;
  const Tailor(
      {required this.id,
      required this.name,
      this.photo,
      required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
    map['description'] = Variable<String>(description);
    return map;
  }

  TailorsCompanion toCompanion(bool nullToAbsent) {
    return TailorsCompanion(
      id: Value(id),
      name: Value(name),
      photo:
          photo == null && nullToAbsent ? const Value.absent() : Value(photo),
      description: Value(description),
    );
  }

  factory Tailor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tailor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      photo: serializer.fromJson<String?>(json['photo']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'photo': serializer.toJson<String?>(photo),
      'description': serializer.toJson<String>(description),
    };
  }

  Tailor copyWith(
          {int? id,
          String? name,
          Value<String?> photo = const Value.absent(),
          String? description}) =>
      Tailor(
        id: id ?? this.id,
        name: name ?? this.name,
        photo: photo.present ? photo.value : this.photo,
        description: description ?? this.description,
      );
  Tailor copyWithCompanion(TailorsCompanion data) {
    return Tailor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      photo: data.photo.present ? data.photo.value : this.photo,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tailor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photo: $photo, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, photo, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tailor &&
          other.id == this.id &&
          other.name == this.name &&
          other.photo == this.photo &&
          other.description == this.description);
}

class TailorsCompanion extends UpdateCompanion<Tailor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> photo;
  final Value<String> description;
  const TailorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.photo = const Value.absent(),
    this.description = const Value.absent(),
  });
  TailorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.photo = const Value.absent(),
    required String description,
  })  : name = Value(name),
        description = Value(description);
  static Insertable<Tailor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? photo,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (photo != null) 'photo': photo,
      if (description != null) 'description': description,
    });
  }

  TailorsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? photo,
      Value<String>? description}) {
    return TailorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TailorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photo: $photo, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $DesignsTable extends Designs with TableInfo<$DesignsTable, Design> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DesignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
      'photo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, title, photo, price, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'designs';
  @override
  VerificationContext validateIntegrity(Insertable<Design> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo')) {
      context.handle(
          _photoMeta, photo.isAcceptableOrUnknown(data['photo']!, _photoMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Design map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Design(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      photo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DesignsTable createAlias(String alias) {
    return $DesignsTable(attachedDatabase, alias);
  }
}

class Design extends DataClass implements Insertable<Design> {
  final int id;
  final String title;
  final String? photo;
  final double price;
  final DateTime createdAt;
  const Design(
      {required this.id,
      required this.title,
      this.photo,
      required this.price,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
    map['price'] = Variable<double>(price);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DesignsCompanion toCompanion(bool nullToAbsent) {
    return DesignsCompanion(
      id: Value(id),
      title: Value(title),
      photo:
          photo == null && nullToAbsent ? const Value.absent() : Value(photo),
      price: Value(price),
      createdAt: Value(createdAt),
    );
  }

  factory Design.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Design(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      photo: serializer.fromJson<String?>(json['photo']),
      price: serializer.fromJson<double>(json['price']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'photo': serializer.toJson<String?>(photo),
      'price': serializer.toJson<double>(price),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Design copyWith(
          {int? id,
          String? title,
          Value<String?> photo = const Value.absent(),
          double? price,
          DateTime? createdAt}) =>
      Design(
        id: id ?? this.id,
        title: title ?? this.title,
        photo: photo.present ? photo.value : this.photo,
        price: price ?? this.price,
        createdAt: createdAt ?? this.createdAt,
      );
  Design copyWithCompanion(DesignsCompanion data) {
    return Design(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      photo: data.photo.present ? data.photo.value : this.photo,
      price: data.price.present ? data.price.value : this.price,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Design(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photo: $photo, ')
          ..write('price: $price, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, photo, price, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Design &&
          other.id == this.id &&
          other.title == this.title &&
          other.photo == this.photo &&
          other.price == this.price &&
          other.createdAt == this.createdAt);
}

class DesignsCompanion extends UpdateCompanion<Design> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> photo;
  final Value<double> price;
  final Value<DateTime> createdAt;
  const DesignsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.photo = const Value.absent(),
    this.price = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DesignsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.photo = const Value.absent(),
    required double price,
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        price = Value(price);
  static Insertable<Design> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? photo,
    Expression<double>? price,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (photo != null) 'photo': photo,
      if (price != null) 'price': price,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DesignsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? photo,
      Value<double>? price,
      Value<DateTime>? createdAt}) {
    return DesignsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      photo: photo ?? this.photo,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DesignsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photo: $photo, ')
          ..write('price: $price, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ComplaintsTable extends Complaints
    with TableInfo<$ComplaintsTable, Complaint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _replyMeta = const VerificationMeta('reply');
  @override
  late final GeneratedColumn<String> reply = GeneratedColumn<String>(
      'reply', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isResolvedMeta =
      const VerificationMeta('isResolved');
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
      'is_resolved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_resolved" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, customerName, message, reply, createdAt, isResolved];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaints';
  @override
  VerificationContext validateIntegrity(Insertable<Complaint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('reply')) {
      context.handle(
          _replyMeta, reply.isAcceptableOrUnknown(data['reply']!, _replyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
          _isResolvedMeta,
          isResolved.isAcceptableOrUnknown(
              data['is_resolved']!, _isResolvedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Complaint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Complaint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      reply: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isResolved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_resolved'])!,
    );
  }

  @override
  $ComplaintsTable createAlias(String alias) {
    return $ComplaintsTable(attachedDatabase, alias);
  }
}

class Complaint extends DataClass implements Insertable<Complaint> {
  final int id;
  final String customerName;
  final String message;
  final String? reply;
  final DateTime createdAt;
  final bool isResolved;
  const Complaint(
      {required this.id,
      required this.customerName,
      required this.message,
      this.reply,
      required this.createdAt,
      required this.isResolved});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || reply != null) {
      map['reply'] = Variable<String>(reply);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_resolved'] = Variable<bool>(isResolved);
    return map;
  }

  ComplaintsCompanion toCompanion(bool nullToAbsent) {
    return ComplaintsCompanion(
      id: Value(id),
      customerName: Value(customerName),
      message: Value(message),
      reply:
          reply == null && nullToAbsent ? const Value.absent() : Value(reply),
      createdAt: Value(createdAt),
      isResolved: Value(isResolved),
    );
  }

  factory Complaint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Complaint(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      message: serializer.fromJson<String>(json['message']),
      reply: serializer.fromJson<String?>(json['reply']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'message': serializer.toJson<String>(message),
      'reply': serializer.toJson<String?>(reply),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isResolved': serializer.toJson<bool>(isResolved),
    };
  }

  Complaint copyWith(
          {int? id,
          String? customerName,
          String? message,
          Value<String?> reply = const Value.absent(),
          DateTime? createdAt,
          bool? isResolved}) =>
      Complaint(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        message: message ?? this.message,
        reply: reply.present ? reply.value : this.reply,
        createdAt: createdAt ?? this.createdAt,
        isResolved: isResolved ?? this.isResolved,
      );
  Complaint copyWithCompanion(ComplaintsCompanion data) {
    return Complaint(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      message: data.message.present ? data.message.value : this.message,
      reply: data.reply.present ? data.reply.value : this.reply,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isResolved:
          data.isResolved.present ? data.isResolved.value : this.isResolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Complaint(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('message: $message, ')
          ..write('reply: $reply, ')
          ..write('createdAt: $createdAt, ')
          ..write('isResolved: $isResolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, customerName, message, reply, createdAt, isResolved);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Complaint &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.message == this.message &&
          other.reply == this.reply &&
          other.createdAt == this.createdAt &&
          other.isResolved == this.isResolved);
}

class ComplaintsCompanion extends UpdateCompanion<Complaint> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String> message;
  final Value<String?> reply;
  final Value<DateTime> createdAt;
  final Value<bool> isResolved;
  const ComplaintsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.message = const Value.absent(),
    this.reply = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isResolved = const Value.absent(),
  });
  ComplaintsCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    required String message,
    this.reply = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isResolved = const Value.absent(),
  })  : customerName = Value(customerName),
        message = Value(message);
  static Insertable<Complaint> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? message,
    Expression<String>? reply,
    Expression<DateTime>? createdAt,
    Expression<bool>? isResolved,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (message != null) 'message': message,
      if (reply != null) 'reply': reply,
      if (createdAt != null) 'created_at': createdAt,
      if (isResolved != null) 'is_resolved': isResolved,
    });
  }

  ComplaintsCompanion copyWith(
      {Value<int>? id,
      Value<String>? customerName,
      Value<String>? message,
      Value<String?>? reply,
      Value<DateTime>? createdAt,
      Value<bool>? isResolved}) {
    return ComplaintsCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      message: message ?? this.message,
      reply: reply ?? this.reply,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (reply.present) {
      map['reply'] = Variable<String>(reply.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('message: $message, ')
          ..write('reply: $reply, ')
          ..write('createdAt: $createdAt, ')
          ..write('isResolved: $isResolved')
          ..write(')'))
        .toString();
  }
}

class $BookingsTable extends Bookings
    with TableInfo<$BookingsTable, BookingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerEmailMeta =
      const VerificationMeta('customerEmail');
  @override
  late final GeneratedColumn<String> customerEmail = GeneratedColumn<String>(
      'customer_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookingDateMeta =
      const VerificationMeta('bookingDate');
  @override
  late final GeneratedColumn<DateTime> bookingDate = GeneratedColumn<DateTime>(
      'booking_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timeSlotMeta =
      const VerificationMeta('timeSlot');
  @override
  late final GeneratedColumn<String> timeSlot = GeneratedColumn<String>(
      'time_slot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suitTypeMeta =
      const VerificationMeta('suitType');
  @override
  late final GeneratedColumn<String> suitType = GeneratedColumn<String>(
      'suit_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUrgentMeta =
      const VerificationMeta('isUrgent');
  @override
  late final GeneratedColumn<bool> isUrgent = GeneratedColumn<bool>(
      'is_urgent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_urgent" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _chargesMeta =
      const VerificationMeta('charges');
  @override
  late final GeneratedColumn<double> charges = GeneratedColumn<double>(
      'charges', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _specialInstructionsMeta =
      const VerificationMeta('specialInstructions');
  @override
  late final GeneratedColumn<String> specialInstructions =
      GeneratedColumn<String>('special_instructions', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _tailorNotesMeta =
      const VerificationMeta('tailorNotes');
  @override
  late final GeneratedColumn<String> tailorNotes = GeneratedColumn<String>(
      'tailor_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        customerName,
        customerEmail,
        customerPhone,
        bookingDate,
        timeSlot,
        suitType,
        isUrgent,
        charges,
        specialInstructions,
        status,
        tailorNotes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings';
  @override
  VerificationContext validateIntegrity(Insertable<BookingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_email')) {
      context.handle(
          _customerEmailMeta,
          customerEmail.isAcceptableOrUnknown(
              data['customer_email']!, _customerEmailMeta));
    } else if (isInserting) {
      context.missing(_customerEmailMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    } else if (isInserting) {
      context.missing(_customerPhoneMeta);
    }
    if (data.containsKey('booking_date')) {
      context.handle(
          _bookingDateMeta,
          bookingDate.isAcceptableOrUnknown(
              data['booking_date']!, _bookingDateMeta));
    } else if (isInserting) {
      context.missing(_bookingDateMeta);
    }
    if (data.containsKey('time_slot')) {
      context.handle(_timeSlotMeta,
          timeSlot.isAcceptableOrUnknown(data['time_slot']!, _timeSlotMeta));
    } else if (isInserting) {
      context.missing(_timeSlotMeta);
    }
    if (data.containsKey('suit_type')) {
      context.handle(_suitTypeMeta,
          suitType.isAcceptableOrUnknown(data['suit_type']!, _suitTypeMeta));
    } else if (isInserting) {
      context.missing(_suitTypeMeta);
    }
    if (data.containsKey('is_urgent')) {
      context.handle(_isUrgentMeta,
          isUrgent.isAcceptableOrUnknown(data['is_urgent']!, _isUrgentMeta));
    }
    if (data.containsKey('charges')) {
      context.handle(_chargesMeta,
          charges.isAcceptableOrUnknown(data['charges']!, _chargesMeta));
    } else if (isInserting) {
      context.missing(_chargesMeta);
    }
    if (data.containsKey('special_instructions')) {
      context.handle(
          _specialInstructionsMeta,
          specialInstructions.isAcceptableOrUnknown(
              data['special_instructions']!, _specialInstructionsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('tailor_notes')) {
      context.handle(
          _tailorNotesMeta,
          tailorNotes.isAcceptableOrUnknown(
              data['tailor_notes']!, _tailorNotesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_email'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone'])!,
      bookingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}booking_date'])!,
      timeSlot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_slot'])!,
      suitType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suit_type'])!,
      isUrgent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_urgent'])!,
      charges: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}charges'])!,
      specialInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}special_instructions']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      tailorNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tailor_notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookingsTable createAlias(String alias) {
    return $BookingsTable(attachedDatabase, alias);
  }
}

class BookingRow extends DataClass implements Insertable<BookingRow> {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime bookingDate;
  final String timeSlot;
  final String suitType;
  final bool isUrgent;
  final double charges;
  final String? specialInstructions;
  final String status;
  final String? tailorNotes;
  final DateTime createdAt;
  const BookingRow(
      {required this.id,
      required this.customerName,
      required this.customerEmail,
      required this.customerPhone,
      required this.bookingDate,
      required this.timeSlot,
      required this.suitType,
      required this.isUrgent,
      required this.charges,
      this.specialInstructions,
      required this.status,
      this.tailorNotes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_email'] = Variable<String>(customerEmail);
    map['customer_phone'] = Variable<String>(customerPhone);
    map['booking_date'] = Variable<DateTime>(bookingDate);
    map['time_slot'] = Variable<String>(timeSlot);
    map['suit_type'] = Variable<String>(suitType);
    map['is_urgent'] = Variable<bool>(isUrgent);
    map['charges'] = Variable<double>(charges);
    if (!nullToAbsent || specialInstructions != null) {
      map['special_instructions'] = Variable<String>(specialInstructions);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || tailorNotes != null) {
      map['tailor_notes'] = Variable<String>(tailorNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookingsCompanion toCompanion(bool nullToAbsent) {
    return BookingsCompanion(
      id: Value(id),
      customerName: Value(customerName),
      customerEmail: Value(customerEmail),
      customerPhone: Value(customerPhone),
      bookingDate: Value(bookingDate),
      timeSlot: Value(timeSlot),
      suitType: Value(suitType),
      isUrgent: Value(isUrgent),
      charges: Value(charges),
      specialInstructions: specialInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(specialInstructions),
      status: Value(status),
      tailorNotes: tailorNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(tailorNotes),
      createdAt: Value(createdAt),
    );
  }

  factory BookingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingRow(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerEmail: serializer.fromJson<String>(json['customerEmail']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      bookingDate: serializer.fromJson<DateTime>(json['bookingDate']),
      timeSlot: serializer.fromJson<String>(json['timeSlot']),
      suitType: serializer.fromJson<String>(json['suitType']),
      isUrgent: serializer.fromJson<bool>(json['isUrgent']),
      charges: serializer.fromJson<double>(json['charges']),
      specialInstructions:
          serializer.fromJson<String?>(json['specialInstructions']),
      status: serializer.fromJson<String>(json['status']),
      tailorNotes: serializer.fromJson<String?>(json['tailorNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'customerEmail': serializer.toJson<String>(customerEmail),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'bookingDate': serializer.toJson<DateTime>(bookingDate),
      'timeSlot': serializer.toJson<String>(timeSlot),
      'suitType': serializer.toJson<String>(suitType),
      'isUrgent': serializer.toJson<bool>(isUrgent),
      'charges': serializer.toJson<double>(charges),
      'specialInstructions': serializer.toJson<String?>(specialInstructions),
      'status': serializer.toJson<String>(status),
      'tailorNotes': serializer.toJson<String?>(tailorNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookingRow copyWith(
          {int? id,
          String? customerName,
          String? customerEmail,
          String? customerPhone,
          DateTime? bookingDate,
          String? timeSlot,
          String? suitType,
          bool? isUrgent,
          double? charges,
          Value<String?> specialInstructions = const Value.absent(),
          String? status,
          Value<String?> tailorNotes = const Value.absent(),
          DateTime? createdAt}) =>
      BookingRow(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        customerEmail: customerEmail ?? this.customerEmail,
        customerPhone: customerPhone ?? this.customerPhone,
        bookingDate: bookingDate ?? this.bookingDate,
        timeSlot: timeSlot ?? this.timeSlot,
        suitType: suitType ?? this.suitType,
        isUrgent: isUrgent ?? this.isUrgent,
        charges: charges ?? this.charges,
        specialInstructions: specialInstructions.present
            ? specialInstructions.value
            : this.specialInstructions,
        status: status ?? this.status,
        tailorNotes: tailorNotes.present ? tailorNotes.value : this.tailorNotes,
        createdAt: createdAt ?? this.createdAt,
      );
  BookingRow copyWithCompanion(BookingsCompanion data) {
    return BookingRow(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerEmail: data.customerEmail.present
          ? data.customerEmail.value
          : this.customerEmail,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      bookingDate:
          data.bookingDate.present ? data.bookingDate.value : this.bookingDate,
      timeSlot: data.timeSlot.present ? data.timeSlot.value : this.timeSlot,
      suitType: data.suitType.present ? data.suitType.value : this.suitType,
      isUrgent: data.isUrgent.present ? data.isUrgent.value : this.isUrgent,
      charges: data.charges.present ? data.charges.value : this.charges,
      specialInstructions: data.specialInstructions.present
          ? data.specialInstructions.value
          : this.specialInstructions,
      status: data.status.present ? data.status.value : this.status,
      tailorNotes:
          data.tailorNotes.present ? data.tailorNotes.value : this.tailorNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingRow(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('suitType: $suitType, ')
          ..write('isUrgent: $isUrgent, ')
          ..write('charges: $charges, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('status: $status, ')
          ..write('tailorNotes: $tailorNotes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      customerName,
      customerEmail,
      customerPhone,
      bookingDate,
      timeSlot,
      suitType,
      isUrgent,
      charges,
      specialInstructions,
      status,
      tailorNotes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingRow &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.customerEmail == this.customerEmail &&
          other.customerPhone == this.customerPhone &&
          other.bookingDate == this.bookingDate &&
          other.timeSlot == this.timeSlot &&
          other.suitType == this.suitType &&
          other.isUrgent == this.isUrgent &&
          other.charges == this.charges &&
          other.specialInstructions == this.specialInstructions &&
          other.status == this.status &&
          other.tailorNotes == this.tailorNotes &&
          other.createdAt == this.createdAt);
}

class BookingsCompanion extends UpdateCompanion<BookingRow> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String> customerEmail;
  final Value<String> customerPhone;
  final Value<DateTime> bookingDate;
  final Value<String> timeSlot;
  final Value<String> suitType;
  final Value<bool> isUrgent;
  final Value<double> charges;
  final Value<String?> specialInstructions;
  final Value<String> status;
  final Value<String?> tailorNotes;
  final Value<DateTime> createdAt;
  const BookingsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerEmail = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.bookingDate = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.suitType = const Value.absent(),
    this.isUrgent = const Value.absent(),
    this.charges = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    this.status = const Value.absent(),
    this.tailorNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookingsCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required DateTime bookingDate,
    required String timeSlot,
    required String suitType,
    this.isUrgent = const Value.absent(),
    required double charges,
    this.specialInstructions = const Value.absent(),
    this.status = const Value.absent(),
    this.tailorNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : customerName = Value(customerName),
        customerEmail = Value(customerEmail),
        customerPhone = Value(customerPhone),
        bookingDate = Value(bookingDate),
        timeSlot = Value(timeSlot),
        suitType = Value(suitType),
        charges = Value(charges);
  static Insertable<BookingRow> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? customerEmail,
    Expression<String>? customerPhone,
    Expression<DateTime>? bookingDate,
    Expression<String>? timeSlot,
    Expression<String>? suitType,
    Expression<bool>? isUrgent,
    Expression<double>? charges,
    Expression<String>? specialInstructions,
    Expression<String>? status,
    Expression<String>? tailorNotes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (bookingDate != null) 'booking_date': bookingDate,
      if (timeSlot != null) 'time_slot': timeSlot,
      if (suitType != null) 'suit_type': suitType,
      if (isUrgent != null) 'is_urgent': isUrgent,
      if (charges != null) 'charges': charges,
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
      if (status != null) 'status': status,
      if (tailorNotes != null) 'tailor_notes': tailorNotes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? customerName,
      Value<String>? customerEmail,
      Value<String>? customerPhone,
      Value<DateTime>? bookingDate,
      Value<String>? timeSlot,
      Value<String>? suitType,
      Value<bool>? isUrgent,
      Value<double>? charges,
      Value<String?>? specialInstructions,
      Value<String>? status,
      Value<String?>? tailorNotes,
      Value<DateTime>? createdAt}) {
    return BookingsCompanion(
      id: id ?? this.id,
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerEmail.present) {
      map['customer_email'] = Variable<String>(customerEmail.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (bookingDate.present) {
      map['booking_date'] = Variable<DateTime>(bookingDate.value);
    }
    if (timeSlot.present) {
      map['time_slot'] = Variable<String>(timeSlot.value);
    }
    if (suitType.present) {
      map['suit_type'] = Variable<String>(suitType.value);
    }
    if (isUrgent.present) {
      map['is_urgent'] = Variable<bool>(isUrgent.value);
    }
    if (charges.present) {
      map['charges'] = Variable<double>(charges.value);
    }
    if (specialInstructions.present) {
      map['special_instructions'] = Variable<String>(specialInstructions.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tailorNotes.present) {
      map['tailor_notes'] = Variable<String>(tailorNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('suitType: $suitType, ')
          ..write('isUrgent: $isUrgent, ')
          ..write('charges: $charges, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('status: $status, ')
          ..write('tailorNotes: $tailorNotes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, MeasurementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerEmailMeta =
      const VerificationMeta('customerEmail');
  @override
  late final GeneratedColumn<String> customerEmail = GeneratedColumn<String>(
      'customer_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chestMeta = const VerificationMeta('chest');
  @override
  late final GeneratedColumn<double> chest = GeneratedColumn<double>(
      'chest', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _waistMeta = const VerificationMeta('waist');
  @override
  late final GeneratedColumn<double> waist = GeneratedColumn<double>(
      'waist', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hipsMeta = const VerificationMeta('hips');
  @override
  late final GeneratedColumn<double> hips = GeneratedColumn<double>(
      'hips', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _shoulderMeta =
      const VerificationMeta('shoulder');
  @override
  late final GeneratedColumn<double> shoulder = GeneratedColumn<double>(
      'shoulder', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sleeveLengthMeta =
      const VerificationMeta('sleeveLength');
  @override
  late final GeneratedColumn<double> sleeveLength = GeneratedColumn<double>(
      'sleeve_length', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _shirtLengthMeta =
      const VerificationMeta('shirtLength');
  @override
  late final GeneratedColumn<double> shirtLength = GeneratedColumn<double>(
      'shirt_length', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _pantLengthMeta =
      const VerificationMeta('pantLength');
  @override
  late final GeneratedColumn<double> pantLength = GeneratedColumn<double>(
      'pant_length', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _inseamMeta = const VerificationMeta('inseam');
  @override
  late final GeneratedColumn<double> inseam = GeneratedColumn<double>(
      'inseam', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _neckMeta = const VerificationMeta('neck');
  @override
  late final GeneratedColumn<double> neck = GeneratedColumn<double>(
      'neck', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _bicepMeta = const VerificationMeta('bicep');
  @override
  late final GeneratedColumn<double> bicep = GeneratedColumn<double>(
      'bicep', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _wristMeta = const VerificationMeta('wrist');
  @override
  late final GeneratedColumn<double> wrist = GeneratedColumn<double>(
      'wrist', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _thighMeta = const VerificationMeta('thigh');
  @override
  late final GeneratedColumn<double> thigh = GeneratedColumn<double>(
      'thigh', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calfMeta = const VerificationMeta('calf');
  @override
  late final GeneratedColumn<double> calf = GeneratedColumn<double>(
      'calf', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        customerName,
        customerEmail,
        customerPhone,
        chest,
        waist,
        hips,
        shoulder,
        sleeveLength,
        shirtLength,
        pantLength,
        inseam,
        neck,
        bicep,
        wrist,
        thigh,
        calf,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(Insertable<MeasurementRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_email')) {
      context.handle(
          _customerEmailMeta,
          customerEmail.isAcceptableOrUnknown(
              data['customer_email']!, _customerEmailMeta));
    } else if (isInserting) {
      context.missing(_customerEmailMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    } else if (isInserting) {
      context.missing(_customerPhoneMeta);
    }
    if (data.containsKey('chest')) {
      context.handle(
          _chestMeta, chest.isAcceptableOrUnknown(data['chest']!, _chestMeta));
    }
    if (data.containsKey('waist')) {
      context.handle(
          _waistMeta, waist.isAcceptableOrUnknown(data['waist']!, _waistMeta));
    }
    if (data.containsKey('hips')) {
      context.handle(
          _hipsMeta, hips.isAcceptableOrUnknown(data['hips']!, _hipsMeta));
    }
    if (data.containsKey('shoulder')) {
      context.handle(_shoulderMeta,
          shoulder.isAcceptableOrUnknown(data['shoulder']!, _shoulderMeta));
    }
    if (data.containsKey('sleeve_length')) {
      context.handle(
          _sleeveLengthMeta,
          sleeveLength.isAcceptableOrUnknown(
              data['sleeve_length']!, _sleeveLengthMeta));
    }
    if (data.containsKey('shirt_length')) {
      context.handle(
          _shirtLengthMeta,
          shirtLength.isAcceptableOrUnknown(
              data['shirt_length']!, _shirtLengthMeta));
    }
    if (data.containsKey('pant_length')) {
      context.handle(
          _pantLengthMeta,
          pantLength.isAcceptableOrUnknown(
              data['pant_length']!, _pantLengthMeta));
    }
    if (data.containsKey('inseam')) {
      context.handle(_inseamMeta,
          inseam.isAcceptableOrUnknown(data['inseam']!, _inseamMeta));
    }
    if (data.containsKey('neck')) {
      context.handle(
          _neckMeta, neck.isAcceptableOrUnknown(data['neck']!, _neckMeta));
    }
    if (data.containsKey('bicep')) {
      context.handle(
          _bicepMeta, bicep.isAcceptableOrUnknown(data['bicep']!, _bicepMeta));
    }
    if (data.containsKey('wrist')) {
      context.handle(
          _wristMeta, wrist.isAcceptableOrUnknown(data['wrist']!, _wristMeta));
    }
    if (data.containsKey('thigh')) {
      context.handle(
          _thighMeta, thigh.isAcceptableOrUnknown(data['thigh']!, _thighMeta));
    }
    if (data.containsKey('calf')) {
      context.handle(
          _calfMeta, calf.isAcceptableOrUnknown(data['calf']!, _calfMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_email'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone'])!,
      chest: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}chest']),
      waist: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}waist']),
      hips: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hips']),
      shoulder: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shoulder']),
      sleeveLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sleeve_length']),
      shirtLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shirt_length']),
      pantLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pant_length']),
      inseam: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}inseam']),
      neck: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}neck']),
      bicep: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bicep']),
      wrist: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}wrist']),
      thigh: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}thigh']),
      calf: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calf']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class MeasurementRow extends DataClass implements Insertable<MeasurementRow> {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? shoulder;
  final double? sleeveLength;
  final double? shirtLength;
  final double? pantLength;
  final double? inseam;
  final double? neck;
  final double? bicep;
  final double? wrist;
  final double? thigh;
  final double? calf;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const MeasurementRow(
      {required this.id,
      required this.customerName,
      required this.customerEmail,
      required this.customerPhone,
      this.chest,
      this.waist,
      this.hips,
      this.shoulder,
      this.sleeveLength,
      this.shirtLength,
      this.pantLength,
      this.inseam,
      this.neck,
      this.bicep,
      this.wrist,
      this.thigh,
      this.calf,
      this.notes,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_email'] = Variable<String>(customerEmail);
    map['customer_phone'] = Variable<String>(customerPhone);
    if (!nullToAbsent || chest != null) {
      map['chest'] = Variable<double>(chest);
    }
    if (!nullToAbsent || waist != null) {
      map['waist'] = Variable<double>(waist);
    }
    if (!nullToAbsent || hips != null) {
      map['hips'] = Variable<double>(hips);
    }
    if (!nullToAbsent || shoulder != null) {
      map['shoulder'] = Variable<double>(shoulder);
    }
    if (!nullToAbsent || sleeveLength != null) {
      map['sleeve_length'] = Variable<double>(sleeveLength);
    }
    if (!nullToAbsent || shirtLength != null) {
      map['shirt_length'] = Variable<double>(shirtLength);
    }
    if (!nullToAbsent || pantLength != null) {
      map['pant_length'] = Variable<double>(pantLength);
    }
    if (!nullToAbsent || inseam != null) {
      map['inseam'] = Variable<double>(inseam);
    }
    if (!nullToAbsent || neck != null) {
      map['neck'] = Variable<double>(neck);
    }
    if (!nullToAbsent || bicep != null) {
      map['bicep'] = Variable<double>(bicep);
    }
    if (!nullToAbsent || wrist != null) {
      map['wrist'] = Variable<double>(wrist);
    }
    if (!nullToAbsent || thigh != null) {
      map['thigh'] = Variable<double>(thigh);
    }
    if (!nullToAbsent || calf != null) {
      map['calf'] = Variable<double>(calf);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      customerName: Value(customerName),
      customerEmail: Value(customerEmail),
      customerPhone: Value(customerPhone),
      chest:
          chest == null && nullToAbsent ? const Value.absent() : Value(chest),
      waist:
          waist == null && nullToAbsent ? const Value.absent() : Value(waist),
      hips: hips == null && nullToAbsent ? const Value.absent() : Value(hips),
      shoulder: shoulder == null && nullToAbsent
          ? const Value.absent()
          : Value(shoulder),
      sleeveLength: sleeveLength == null && nullToAbsent
          ? const Value.absent()
          : Value(sleeveLength),
      shirtLength: shirtLength == null && nullToAbsent
          ? const Value.absent()
          : Value(shirtLength),
      pantLength: pantLength == null && nullToAbsent
          ? const Value.absent()
          : Value(pantLength),
      inseam:
          inseam == null && nullToAbsent ? const Value.absent() : Value(inseam),
      neck: neck == null && nullToAbsent ? const Value.absent() : Value(neck),
      bicep:
          bicep == null && nullToAbsent ? const Value.absent() : Value(bicep),
      wrist:
          wrist == null && nullToAbsent ? const Value.absent() : Value(wrist),
      thigh:
          thigh == null && nullToAbsent ? const Value.absent() : Value(thigh),
      calf: calf == null && nullToAbsent ? const Value.absent() : Value(calf),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory MeasurementRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementRow(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerEmail: serializer.fromJson<String>(json['customerEmail']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      chest: serializer.fromJson<double?>(json['chest']),
      waist: serializer.fromJson<double?>(json['waist']),
      hips: serializer.fromJson<double?>(json['hips']),
      shoulder: serializer.fromJson<double?>(json['shoulder']),
      sleeveLength: serializer.fromJson<double?>(json['sleeveLength']),
      shirtLength: serializer.fromJson<double?>(json['shirtLength']),
      pantLength: serializer.fromJson<double?>(json['pantLength']),
      inseam: serializer.fromJson<double?>(json['inseam']),
      neck: serializer.fromJson<double?>(json['neck']),
      bicep: serializer.fromJson<double?>(json['bicep']),
      wrist: serializer.fromJson<double?>(json['wrist']),
      thigh: serializer.fromJson<double?>(json['thigh']),
      calf: serializer.fromJson<double?>(json['calf']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'customerEmail': serializer.toJson<String>(customerEmail),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'chest': serializer.toJson<double?>(chest),
      'waist': serializer.toJson<double?>(waist),
      'hips': serializer.toJson<double?>(hips),
      'shoulder': serializer.toJson<double?>(shoulder),
      'sleeveLength': serializer.toJson<double?>(sleeveLength),
      'shirtLength': serializer.toJson<double?>(shirtLength),
      'pantLength': serializer.toJson<double?>(pantLength),
      'inseam': serializer.toJson<double?>(inseam),
      'neck': serializer.toJson<double?>(neck),
      'bicep': serializer.toJson<double?>(bicep),
      'wrist': serializer.toJson<double?>(wrist),
      'thigh': serializer.toJson<double?>(thigh),
      'calf': serializer.toJson<double?>(calf),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  MeasurementRow copyWith(
          {int? id,
          String? customerName,
          String? customerEmail,
          String? customerPhone,
          Value<double?> chest = const Value.absent(),
          Value<double?> waist = const Value.absent(),
          Value<double?> hips = const Value.absent(),
          Value<double?> shoulder = const Value.absent(),
          Value<double?> sleeveLength = const Value.absent(),
          Value<double?> shirtLength = const Value.absent(),
          Value<double?> pantLength = const Value.absent(),
          Value<double?> inseam = const Value.absent(),
          Value<double?> neck = const Value.absent(),
          Value<double?> bicep = const Value.absent(),
          Value<double?> wrist = const Value.absent(),
          Value<double?> thigh = const Value.absent(),
          Value<double?> calf = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      MeasurementRow(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        customerEmail: customerEmail ?? this.customerEmail,
        customerPhone: customerPhone ?? this.customerPhone,
        chest: chest.present ? chest.value : this.chest,
        waist: waist.present ? waist.value : this.waist,
        hips: hips.present ? hips.value : this.hips,
        shoulder: shoulder.present ? shoulder.value : this.shoulder,
        sleeveLength:
            sleeveLength.present ? sleeveLength.value : this.sleeveLength,
        shirtLength: shirtLength.present ? shirtLength.value : this.shirtLength,
        pantLength: pantLength.present ? pantLength.value : this.pantLength,
        inseam: inseam.present ? inseam.value : this.inseam,
        neck: neck.present ? neck.value : this.neck,
        bicep: bicep.present ? bicep.value : this.bicep,
        wrist: wrist.present ? wrist.value : this.wrist,
        thigh: thigh.present ? thigh.value : this.thigh,
        calf: calf.present ? calf.value : this.calf,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  MeasurementRow copyWithCompanion(MeasurementsCompanion data) {
    return MeasurementRow(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerEmail: data.customerEmail.present
          ? data.customerEmail.value
          : this.customerEmail,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      chest: data.chest.present ? data.chest.value : this.chest,
      waist: data.waist.present ? data.waist.value : this.waist,
      hips: data.hips.present ? data.hips.value : this.hips,
      shoulder: data.shoulder.present ? data.shoulder.value : this.shoulder,
      sleeveLength: data.sleeveLength.present
          ? data.sleeveLength.value
          : this.sleeveLength,
      shirtLength:
          data.shirtLength.present ? data.shirtLength.value : this.shirtLength,
      pantLength:
          data.pantLength.present ? data.pantLength.value : this.pantLength,
      inseam: data.inseam.present ? data.inseam.value : this.inseam,
      neck: data.neck.present ? data.neck.value : this.neck,
      bicep: data.bicep.present ? data.bicep.value : this.bicep,
      wrist: data.wrist.present ? data.wrist.value : this.wrist,
      thigh: data.thigh.present ? data.thigh.value : this.thigh,
      calf: data.calf.present ? data.calf.value : this.calf,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementRow(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('chest: $chest, ')
          ..write('waist: $waist, ')
          ..write('hips: $hips, ')
          ..write('shoulder: $shoulder, ')
          ..write('sleeveLength: $sleeveLength, ')
          ..write('shirtLength: $shirtLength, ')
          ..write('pantLength: $pantLength, ')
          ..write('inseam: $inseam, ')
          ..write('neck: $neck, ')
          ..write('bicep: $bicep, ')
          ..write('wrist: $wrist, ')
          ..write('thigh: $thigh, ')
          ..write('calf: $calf, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      customerName,
      customerEmail,
      customerPhone,
      chest,
      waist,
      hips,
      shoulder,
      sleeveLength,
      shirtLength,
      pantLength,
      inseam,
      neck,
      bicep,
      wrist,
      thigh,
      calf,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementRow &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.customerEmail == this.customerEmail &&
          other.customerPhone == this.customerPhone &&
          other.chest == this.chest &&
          other.waist == this.waist &&
          other.hips == this.hips &&
          other.shoulder == this.shoulder &&
          other.sleeveLength == this.sleeveLength &&
          other.shirtLength == this.shirtLength &&
          other.pantLength == this.pantLength &&
          other.inseam == this.inseam &&
          other.neck == this.neck &&
          other.bicep == this.bicep &&
          other.wrist == this.wrist &&
          other.thigh == this.thigh &&
          other.calf == this.calf &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MeasurementsCompanion extends UpdateCompanion<MeasurementRow> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String> customerEmail;
  final Value<String> customerPhone;
  final Value<double?> chest;
  final Value<double?> waist;
  final Value<double?> hips;
  final Value<double?> shoulder;
  final Value<double?> sleeveLength;
  final Value<double?> shirtLength;
  final Value<double?> pantLength;
  final Value<double?> inseam;
  final Value<double?> neck;
  final Value<double?> bicep;
  final Value<double?> wrist;
  final Value<double?> thigh;
  final Value<double?> calf;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerEmail = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.chest = const Value.absent(),
    this.waist = const Value.absent(),
    this.hips = const Value.absent(),
    this.shoulder = const Value.absent(),
    this.sleeveLength = const Value.absent(),
    this.shirtLength = const Value.absent(),
    this.pantLength = const Value.absent(),
    this.inseam = const Value.absent(),
    this.neck = const Value.absent(),
    this.bicep = const Value.absent(),
    this.wrist = const Value.absent(),
    this.thigh = const Value.absent(),
    this.calf = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    this.chest = const Value.absent(),
    this.waist = const Value.absent(),
    this.hips = const Value.absent(),
    this.shoulder = const Value.absent(),
    this.sleeveLength = const Value.absent(),
    this.shirtLength = const Value.absent(),
    this.pantLength = const Value.absent(),
    this.inseam = const Value.absent(),
    this.neck = const Value.absent(),
    this.bicep = const Value.absent(),
    this.wrist = const Value.absent(),
    this.thigh = const Value.absent(),
    this.calf = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : customerName = Value(customerName),
        customerEmail = Value(customerEmail),
        customerPhone = Value(customerPhone);
  static Insertable<MeasurementRow> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? customerEmail,
    Expression<String>? customerPhone,
    Expression<double>? chest,
    Expression<double>? waist,
    Expression<double>? hips,
    Expression<double>? shoulder,
    Expression<double>? sleeveLength,
    Expression<double>? shirtLength,
    Expression<double>? pantLength,
    Expression<double>? inseam,
    Expression<double>? neck,
    Expression<double>? bicep,
    Expression<double>? wrist,
    Expression<double>? thigh,
    Expression<double>? calf,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (chest != null) 'chest': chest,
      if (waist != null) 'waist': waist,
      if (hips != null) 'hips': hips,
      if (shoulder != null) 'shoulder': shoulder,
      if (sleeveLength != null) 'sleeve_length': sleeveLength,
      if (shirtLength != null) 'shirt_length': shirtLength,
      if (pantLength != null) 'pant_length': pantLength,
      if (inseam != null) 'inseam': inseam,
      if (neck != null) 'neck': neck,
      if (bicep != null) 'bicep': bicep,
      if (wrist != null) 'wrist': wrist,
      if (thigh != null) 'thigh': thigh,
      if (calf != null) 'calf': calf,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<String>? customerName,
      Value<String>? customerEmail,
      Value<String>? customerPhone,
      Value<double?>? chest,
      Value<double?>? waist,
      Value<double?>? hips,
      Value<double?>? shoulder,
      Value<double?>? sleeveLength,
      Value<double?>? shirtLength,
      Value<double?>? pantLength,
      Value<double?>? inseam,
      Value<double?>? neck,
      Value<double?>? bicep,
      Value<double?>? wrist,
      Value<double?>? thigh,
      Value<double?>? calf,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      shoulder: shoulder ?? this.shoulder,
      sleeveLength: sleeveLength ?? this.sleeveLength,
      shirtLength: shirtLength ?? this.shirtLength,
      pantLength: pantLength ?? this.pantLength,
      inseam: inseam ?? this.inseam,
      neck: neck ?? this.neck,
      bicep: bicep ?? this.bicep,
      wrist: wrist ?? this.wrist,
      thigh: thigh ?? this.thigh,
      calf: calf ?? this.calf,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerEmail.present) {
      map['customer_email'] = Variable<String>(customerEmail.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (chest.present) {
      map['chest'] = Variable<double>(chest.value);
    }
    if (waist.present) {
      map['waist'] = Variable<double>(waist.value);
    }
    if (hips.present) {
      map['hips'] = Variable<double>(hips.value);
    }
    if (shoulder.present) {
      map['shoulder'] = Variable<double>(shoulder.value);
    }
    if (sleeveLength.present) {
      map['sleeve_length'] = Variable<double>(sleeveLength.value);
    }
    if (shirtLength.present) {
      map['shirt_length'] = Variable<double>(shirtLength.value);
    }
    if (pantLength.present) {
      map['pant_length'] = Variable<double>(pantLength.value);
    }
    if (inseam.present) {
      map['inseam'] = Variable<double>(inseam.value);
    }
    if (neck.present) {
      map['neck'] = Variable<double>(neck.value);
    }
    if (bicep.present) {
      map['bicep'] = Variable<double>(bicep.value);
    }
    if (wrist.present) {
      map['wrist'] = Variable<double>(wrist.value);
    }
    if (thigh.present) {
      map['thigh'] = Variable<double>(thigh.value);
    }
    if (calf.present) {
      map['calf'] = Variable<double>(calf.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('chest: $chest, ')
          ..write('waist: $waist, ')
          ..write('hips: $hips, ')
          ..write('shoulder: $shoulder, ')
          ..write('sleeveLength: $sleeveLength, ')
          ..write('shirtLength: $shirtLength, ')
          ..write('pantLength: $pantLength, ')
          ..write('inseam: $inseam, ')
          ..write('neck: $neck, ')
          ..write('bicep: $bicep, ')
          ..write('wrist: $wrist, ')
          ..write('thigh: $thigh, ')
          ..write('calf: $calf, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PickupRequestsTable extends PickupRequests
    with TableInfo<$PickupRequestsTable, PickupRequestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PickupRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerEmailMeta =
      const VerificationMeta('customerEmail');
  @override
  late final GeneratedColumn<String> customerEmail = GeneratedColumn<String>(
      'customer_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requestTypeMeta =
      const VerificationMeta('requestType');
  @override
  late final GeneratedColumn<String> requestType = GeneratedColumn<String>(
      'request_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relatedBookingIdMeta =
      const VerificationMeta('relatedBookingId');
  @override
  late final GeneratedColumn<int> relatedBookingId = GeneratedColumn<int>(
      'related_booking_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pickupAddressMeta =
      const VerificationMeta('pickupAddress');
  @override
  late final GeneratedColumn<String> pickupAddress = GeneratedColumn<String>(
      'pickup_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackingNumberMeta =
      const VerificationMeta('trackingNumber');
  @override
  late final GeneratedColumn<String> trackingNumber = GeneratedColumn<String>(
      'tracking_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _courierNameMeta =
      const VerificationMeta('courierName');
  @override
  late final GeneratedColumn<String> courierName = GeneratedColumn<String>(
      'courier_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _chargesMeta =
      const VerificationMeta('charges');
  @override
  late final GeneratedColumn<double> charges = GeneratedColumn<double>(
      'charges', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requestedDateMeta =
      const VerificationMeta('requestedDate');
  @override
  late final GeneratedColumn<DateTime> requestedDate =
      GeneratedColumn<DateTime>('requested_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedDateMeta =
      const VerificationMeta('completedDate');
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>('completed_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        customerName,
        customerEmail,
        customerPhone,
        requestType,
        relatedBookingId,
        pickupAddress,
        trackingNumber,
        courierName,
        status,
        charges,
        notes,
        requestedDate,
        completedDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pickup_requests';
  @override
  VerificationContext validateIntegrity(Insertable<PickupRequestRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_email')) {
      context.handle(
          _customerEmailMeta,
          customerEmail.isAcceptableOrUnknown(
              data['customer_email']!, _customerEmailMeta));
    } else if (isInserting) {
      context.missing(_customerEmailMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    } else if (isInserting) {
      context.missing(_customerPhoneMeta);
    }
    if (data.containsKey('request_type')) {
      context.handle(
          _requestTypeMeta,
          requestType.isAcceptableOrUnknown(
              data['request_type']!, _requestTypeMeta));
    } else if (isInserting) {
      context.missing(_requestTypeMeta);
    }
    if (data.containsKey('related_booking_id')) {
      context.handle(
          _relatedBookingIdMeta,
          relatedBookingId.isAcceptableOrUnknown(
              data['related_booking_id']!, _relatedBookingIdMeta));
    }
    if (data.containsKey('pickup_address')) {
      context.handle(
          _pickupAddressMeta,
          pickupAddress.isAcceptableOrUnknown(
              data['pickup_address']!, _pickupAddressMeta));
    } else if (isInserting) {
      context.missing(_pickupAddressMeta);
    }
    if (data.containsKey('tracking_number')) {
      context.handle(
          _trackingNumberMeta,
          trackingNumber.isAcceptableOrUnknown(
              data['tracking_number']!, _trackingNumberMeta));
    }
    if (data.containsKey('courier_name')) {
      context.handle(
          _courierNameMeta,
          courierName.isAcceptableOrUnknown(
              data['courier_name']!, _courierNameMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('charges')) {
      context.handle(_chargesMeta,
          charges.isAcceptableOrUnknown(data['charges']!, _chargesMeta));
    } else if (isInserting) {
      context.missing(_chargesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('requested_date')) {
      context.handle(
          _requestedDateMeta,
          requestedDate.isAcceptableOrUnknown(
              data['requested_date']!, _requestedDateMeta));
    } else if (isInserting) {
      context.missing(_requestedDateMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
          _completedDateMeta,
          completedDate.isAcceptableOrUnknown(
              data['completed_date']!, _completedDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PickupRequestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PickupRequestRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_email'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone'])!,
      requestType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}request_type'])!,
      relatedBookingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}related_booking_id']),
      pickupAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pickup_address'])!,
      trackingNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tracking_number']),
      courierName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}courier_name']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      charges: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}charges'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      requestedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}requested_date'])!,
      completedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}completed_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PickupRequestsTable createAlias(String alias) {
    return $PickupRequestsTable(attachedDatabase, alias);
  }
}

class PickupRequestRow extends DataClass
    implements Insertable<PickupRequestRow> {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String requestType;
  final int? relatedBookingId;
  final String pickupAddress;
  final String? trackingNumber;
  final String? courierName;
  final String status;
  final double charges;
  final String? notes;
  final DateTime requestedDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  const PickupRequestRow(
      {required this.id,
      required this.customerName,
      required this.customerEmail,
      required this.customerPhone,
      required this.requestType,
      this.relatedBookingId,
      required this.pickupAddress,
      this.trackingNumber,
      this.courierName,
      required this.status,
      required this.charges,
      this.notes,
      required this.requestedDate,
      this.completedDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_email'] = Variable<String>(customerEmail);
    map['customer_phone'] = Variable<String>(customerPhone);
    map['request_type'] = Variable<String>(requestType);
    if (!nullToAbsent || relatedBookingId != null) {
      map['related_booking_id'] = Variable<int>(relatedBookingId);
    }
    map['pickup_address'] = Variable<String>(pickupAddress);
    if (!nullToAbsent || trackingNumber != null) {
      map['tracking_number'] = Variable<String>(trackingNumber);
    }
    if (!nullToAbsent || courierName != null) {
      map['courier_name'] = Variable<String>(courierName);
    }
    map['status'] = Variable<String>(status);
    map['charges'] = Variable<double>(charges);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['requested_date'] = Variable<DateTime>(requestedDate);
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<DateTime>(completedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PickupRequestsCompanion toCompanion(bool nullToAbsent) {
    return PickupRequestsCompanion(
      id: Value(id),
      customerName: Value(customerName),
      customerEmail: Value(customerEmail),
      customerPhone: Value(customerPhone),
      requestType: Value(requestType),
      relatedBookingId: relatedBookingId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedBookingId),
      pickupAddress: Value(pickupAddress),
      trackingNumber: trackingNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingNumber),
      courierName: courierName == null && nullToAbsent
          ? const Value.absent()
          : Value(courierName),
      status: Value(status),
      charges: Value(charges),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      requestedDate: Value(requestedDate),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      createdAt: Value(createdAt),
    );
  }

  factory PickupRequestRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PickupRequestRow(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerEmail: serializer.fromJson<String>(json['customerEmail']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      requestType: serializer.fromJson<String>(json['requestType']),
      relatedBookingId: serializer.fromJson<int?>(json['relatedBookingId']),
      pickupAddress: serializer.fromJson<String>(json['pickupAddress']),
      trackingNumber: serializer.fromJson<String?>(json['trackingNumber']),
      courierName: serializer.fromJson<String?>(json['courierName']),
      status: serializer.fromJson<String>(json['status']),
      charges: serializer.fromJson<double>(json['charges']),
      notes: serializer.fromJson<String?>(json['notes']),
      requestedDate: serializer.fromJson<DateTime>(json['requestedDate']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'customerEmail': serializer.toJson<String>(customerEmail),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'requestType': serializer.toJson<String>(requestType),
      'relatedBookingId': serializer.toJson<int?>(relatedBookingId),
      'pickupAddress': serializer.toJson<String>(pickupAddress),
      'trackingNumber': serializer.toJson<String?>(trackingNumber),
      'courierName': serializer.toJson<String?>(courierName),
      'status': serializer.toJson<String>(status),
      'charges': serializer.toJson<double>(charges),
      'notes': serializer.toJson<String?>(notes),
      'requestedDate': serializer.toJson<DateTime>(requestedDate),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PickupRequestRow copyWith(
          {int? id,
          String? customerName,
          String? customerEmail,
          String? customerPhone,
          String? requestType,
          Value<int?> relatedBookingId = const Value.absent(),
          String? pickupAddress,
          Value<String?> trackingNumber = const Value.absent(),
          Value<String?> courierName = const Value.absent(),
          String? status,
          double? charges,
          Value<String?> notes = const Value.absent(),
          DateTime? requestedDate,
          Value<DateTime?> completedDate = const Value.absent(),
          DateTime? createdAt}) =>
      PickupRequestRow(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        customerEmail: customerEmail ?? this.customerEmail,
        customerPhone: customerPhone ?? this.customerPhone,
        requestType: requestType ?? this.requestType,
        relatedBookingId: relatedBookingId.present
            ? relatedBookingId.value
            : this.relatedBookingId,
        pickupAddress: pickupAddress ?? this.pickupAddress,
        trackingNumber:
            trackingNumber.present ? trackingNumber.value : this.trackingNumber,
        courierName: courierName.present ? courierName.value : this.courierName,
        status: status ?? this.status,
        charges: charges ?? this.charges,
        notes: notes.present ? notes.value : this.notes,
        requestedDate: requestedDate ?? this.requestedDate,
        completedDate:
            completedDate.present ? completedDate.value : this.completedDate,
        createdAt: createdAt ?? this.createdAt,
      );
  PickupRequestRow copyWithCompanion(PickupRequestsCompanion data) {
    return PickupRequestRow(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerEmail: data.customerEmail.present
          ? data.customerEmail.value
          : this.customerEmail,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      requestType:
          data.requestType.present ? data.requestType.value : this.requestType,
      relatedBookingId: data.relatedBookingId.present
          ? data.relatedBookingId.value
          : this.relatedBookingId,
      pickupAddress: data.pickupAddress.present
          ? data.pickupAddress.value
          : this.pickupAddress,
      trackingNumber: data.trackingNumber.present
          ? data.trackingNumber.value
          : this.trackingNumber,
      courierName:
          data.courierName.present ? data.courierName.value : this.courierName,
      status: data.status.present ? data.status.value : this.status,
      charges: data.charges.present ? data.charges.value : this.charges,
      notes: data.notes.present ? data.notes.value : this.notes,
      requestedDate: data.requestedDate.present
          ? data.requestedDate.value
          : this.requestedDate,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PickupRequestRow(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('requestType: $requestType, ')
          ..write('relatedBookingId: $relatedBookingId, ')
          ..write('pickupAddress: $pickupAddress, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('courierName: $courierName, ')
          ..write('status: $status, ')
          ..write('charges: $charges, ')
          ..write('notes: $notes, ')
          ..write('requestedDate: $requestedDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      customerName,
      customerEmail,
      customerPhone,
      requestType,
      relatedBookingId,
      pickupAddress,
      trackingNumber,
      courierName,
      status,
      charges,
      notes,
      requestedDate,
      completedDate,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PickupRequestRow &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.customerEmail == this.customerEmail &&
          other.customerPhone == this.customerPhone &&
          other.requestType == this.requestType &&
          other.relatedBookingId == this.relatedBookingId &&
          other.pickupAddress == this.pickupAddress &&
          other.trackingNumber == this.trackingNumber &&
          other.courierName == this.courierName &&
          other.status == this.status &&
          other.charges == this.charges &&
          other.notes == this.notes &&
          other.requestedDate == this.requestedDate &&
          other.completedDate == this.completedDate &&
          other.createdAt == this.createdAt);
}

class PickupRequestsCompanion extends UpdateCompanion<PickupRequestRow> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String> customerEmail;
  final Value<String> customerPhone;
  final Value<String> requestType;
  final Value<int?> relatedBookingId;
  final Value<String> pickupAddress;
  final Value<String?> trackingNumber;
  final Value<String?> courierName;
  final Value<String> status;
  final Value<double> charges;
  final Value<String?> notes;
  final Value<DateTime> requestedDate;
  final Value<DateTime?> completedDate;
  final Value<DateTime> createdAt;
  const PickupRequestsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerEmail = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.requestType = const Value.absent(),
    this.relatedBookingId = const Value.absent(),
    this.pickupAddress = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.courierName = const Value.absent(),
    this.status = const Value.absent(),
    this.charges = const Value.absent(),
    this.notes = const Value.absent(),
    this.requestedDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PickupRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String requestType,
    this.relatedBookingId = const Value.absent(),
    required String pickupAddress,
    this.trackingNumber = const Value.absent(),
    this.courierName = const Value.absent(),
    this.status = const Value.absent(),
    required double charges,
    this.notes = const Value.absent(),
    required DateTime requestedDate,
    this.completedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : customerName = Value(customerName),
        customerEmail = Value(customerEmail),
        customerPhone = Value(customerPhone),
        requestType = Value(requestType),
        pickupAddress = Value(pickupAddress),
        charges = Value(charges),
        requestedDate = Value(requestedDate);
  static Insertable<PickupRequestRow> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? customerEmail,
    Expression<String>? customerPhone,
    Expression<String>? requestType,
    Expression<int>? relatedBookingId,
    Expression<String>? pickupAddress,
    Expression<String>? trackingNumber,
    Expression<String>? courierName,
    Expression<String>? status,
    Expression<double>? charges,
    Expression<String>? notes,
    Expression<DateTime>? requestedDate,
    Expression<DateTime>? completedDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (requestType != null) 'request_type': requestType,
      if (relatedBookingId != null) 'related_booking_id': relatedBookingId,
      if (pickupAddress != null) 'pickup_address': pickupAddress,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (courierName != null) 'courier_name': courierName,
      if (status != null) 'status': status,
      if (charges != null) 'charges': charges,
      if (notes != null) 'notes': notes,
      if (requestedDate != null) 'requested_date': requestedDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PickupRequestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? customerName,
      Value<String>? customerEmail,
      Value<String>? customerPhone,
      Value<String>? requestType,
      Value<int?>? relatedBookingId,
      Value<String>? pickupAddress,
      Value<String?>? trackingNumber,
      Value<String?>? courierName,
      Value<String>? status,
      Value<double>? charges,
      Value<String?>? notes,
      Value<DateTime>? requestedDate,
      Value<DateTime?>? completedDate,
      Value<DateTime>? createdAt}) {
    return PickupRequestsCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      requestType: requestType ?? this.requestType,
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
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerEmail.present) {
      map['customer_email'] = Variable<String>(customerEmail.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (requestType.present) {
      map['request_type'] = Variable<String>(requestType.value);
    }
    if (relatedBookingId.present) {
      map['related_booking_id'] = Variable<int>(relatedBookingId.value);
    }
    if (pickupAddress.present) {
      map['pickup_address'] = Variable<String>(pickupAddress.value);
    }
    if (trackingNumber.present) {
      map['tracking_number'] = Variable<String>(trackingNumber.value);
    }
    if (courierName.present) {
      map['courier_name'] = Variable<String>(courierName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (charges.present) {
      map['charges'] = Variable<double>(charges.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (requestedDate.present) {
      map['requested_date'] = Variable<DateTime>(requestedDate.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PickupRequestsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('requestType: $requestType, ')
          ..write('relatedBookingId: $relatedBookingId, ')
          ..write('pickupAddress: $pickupAddress, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('courierName: $courierName, ')
          ..write('status: $status, ')
          ..write('charges: $charges, ')
          ..write('notes: $notes, ')
          ..write('requestedDate: $requestedDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TailorsTable tailors = $TailorsTable(this);
  late final $DesignsTable designs = $DesignsTable(this);
  late final $ComplaintsTable complaints = $ComplaintsTable(this);
  late final $BookingsTable bookings = $BookingsTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $PickupRequestsTable pickupRequests = $PickupRequestsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tailors, designs, complaints, bookings, measurements, pickupRequests];
}

typedef $$TailorsTableCreateCompanionBuilder = TailorsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> photo,
  required String description,
});
typedef $$TailorsTableUpdateCompanionBuilder = TailorsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> photo,
  Value<String> description,
});

class $$TailorsTableFilterComposer
    extends Composer<_$AppDatabase, $TailorsTable> {
  $$TailorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photo => $composableBuilder(
      column: $table.photo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$TailorsTableOrderingComposer
    extends Composer<_$AppDatabase, $TailorsTable> {
  $$TailorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photo => $composableBuilder(
      column: $table.photo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$TailorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TailorsTable> {
  $$TailorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$TailorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TailorsTable,
    Tailor,
    $$TailorsTableFilterComposer,
    $$TailorsTableOrderingComposer,
    $$TailorsTableAnnotationComposer,
    $$TailorsTableCreateCompanionBuilder,
    $$TailorsTableUpdateCompanionBuilder,
    (Tailor, BaseReferences<_$AppDatabase, $TailorsTable, Tailor>),
    Tailor,
    PrefetchHooks Function()> {
  $$TailorsTableTableManager(_$AppDatabase db, $TailorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TailorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TailorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TailorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> photo = const Value.absent(),
            Value<String> description = const Value.absent(),
          }) =>
              TailorsCompanion(
            id: id,
            name: name,
            photo: photo,
            description: description,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> photo = const Value.absent(),
            required String description,
          }) =>
              TailorsCompanion.insert(
            id: id,
            name: name,
            photo: photo,
            description: description,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TailorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TailorsTable,
    Tailor,
    $$TailorsTableFilterComposer,
    $$TailorsTableOrderingComposer,
    $$TailorsTableAnnotationComposer,
    $$TailorsTableCreateCompanionBuilder,
    $$TailorsTableUpdateCompanionBuilder,
    (Tailor, BaseReferences<_$AppDatabase, $TailorsTable, Tailor>),
    Tailor,
    PrefetchHooks Function()>;
typedef $$DesignsTableCreateCompanionBuilder = DesignsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> photo,
  required double price,
  Value<DateTime> createdAt,
});
typedef $$DesignsTableUpdateCompanionBuilder = DesignsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> photo,
  Value<double> price,
  Value<DateTime> createdAt,
});

class $$DesignsTableFilterComposer
    extends Composer<_$AppDatabase, $DesignsTable> {
  $$DesignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photo => $composableBuilder(
      column: $table.photo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DesignsTableOrderingComposer
    extends Composer<_$AppDatabase, $DesignsTable> {
  $$DesignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photo => $composableBuilder(
      column: $table.photo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DesignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DesignsTable> {
  $$DesignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DesignsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DesignsTable,
    Design,
    $$DesignsTableFilterComposer,
    $$DesignsTableOrderingComposer,
    $$DesignsTableAnnotationComposer,
    $$DesignsTableCreateCompanionBuilder,
    $$DesignsTableUpdateCompanionBuilder,
    (Design, BaseReferences<_$AppDatabase, $DesignsTable, Design>),
    Design,
    PrefetchHooks Function()> {
  $$DesignsTableTableManager(_$AppDatabase db, $DesignsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DesignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DesignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DesignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> photo = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DesignsCompanion(
            id: id,
            title: title,
            photo: photo,
            price: price,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> photo = const Value.absent(),
            required double price,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DesignsCompanion.insert(
            id: id,
            title: title,
            photo: photo,
            price: price,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DesignsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DesignsTable,
    Design,
    $$DesignsTableFilterComposer,
    $$DesignsTableOrderingComposer,
    $$DesignsTableAnnotationComposer,
    $$DesignsTableCreateCompanionBuilder,
    $$DesignsTableUpdateCompanionBuilder,
    (Design, BaseReferences<_$AppDatabase, $DesignsTable, Design>),
    Design,
    PrefetchHooks Function()>;
typedef $$ComplaintsTableCreateCompanionBuilder = ComplaintsCompanion Function({
  Value<int> id,
  required String customerName,
  required String message,
  Value<String?> reply,
  Value<DateTime> createdAt,
  Value<bool> isResolved,
});
typedef $$ComplaintsTableUpdateCompanionBuilder = ComplaintsCompanion Function({
  Value<int> id,
  Value<String> customerName,
  Value<String> message,
  Value<String?> reply,
  Value<DateTime> createdAt,
  Value<bool> isResolved,
});

class $$ComplaintsTableFilterComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reply => $composableBuilder(
      column: $table.reply, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnFilters(column));
}

class $$ComplaintsTableOrderingComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reply => $composableBuilder(
      column: $table.reply, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnOrderings(column));
}

class $$ComplaintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get reply =>
      $composableBuilder(column: $table.reply, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => column);
}

class $$ComplaintsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ComplaintsTable,
    Complaint,
    $$ComplaintsTableFilterComposer,
    $$ComplaintsTableOrderingComposer,
    $$ComplaintsTableAnnotationComposer,
    $$ComplaintsTableCreateCompanionBuilder,
    $$ComplaintsTableUpdateCompanionBuilder,
    (Complaint, BaseReferences<_$AppDatabase, $ComplaintsTable, Complaint>),
    Complaint,
    PrefetchHooks Function()> {
  $$ComplaintsTableTableManager(_$AppDatabase db, $ComplaintsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComplaintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComplaintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComplaintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String?> reply = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
          }) =>
              ComplaintsCompanion(
            id: id,
            customerName: customerName,
            message: message,
            reply: reply,
            createdAt: createdAt,
            isResolved: isResolved,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String customerName,
            required String message,
            Value<String?> reply = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
          }) =>
              ComplaintsCompanion.insert(
            id: id,
            customerName: customerName,
            message: message,
            reply: reply,
            createdAt: createdAt,
            isResolved: isResolved,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ComplaintsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ComplaintsTable,
    Complaint,
    $$ComplaintsTableFilterComposer,
    $$ComplaintsTableOrderingComposer,
    $$ComplaintsTableAnnotationComposer,
    $$ComplaintsTableCreateCompanionBuilder,
    $$ComplaintsTableUpdateCompanionBuilder,
    (Complaint, BaseReferences<_$AppDatabase, $ComplaintsTable, Complaint>),
    Complaint,
    PrefetchHooks Function()>;
typedef $$BookingsTableCreateCompanionBuilder = BookingsCompanion Function({
  Value<int> id,
  required String customerName,
  required String customerEmail,
  required String customerPhone,
  required DateTime bookingDate,
  required String timeSlot,
  required String suitType,
  Value<bool> isUrgent,
  required double charges,
  Value<String?> specialInstructions,
  Value<String> status,
  Value<String?> tailorNotes,
  Value<DateTime> createdAt,
});
typedef $$BookingsTableUpdateCompanionBuilder = BookingsCompanion Function({
  Value<int> id,
  Value<String> customerName,
  Value<String> customerEmail,
  Value<String> customerPhone,
  Value<DateTime> bookingDate,
  Value<String> timeSlot,
  Value<String> suitType,
  Value<bool> isUrgent,
  Value<double> charges,
  Value<String?> specialInstructions,
  Value<String> status,
  Value<String?> tailorNotes,
  Value<DateTime> createdAt,
});

class $$BookingsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get bookingDate => $composableBuilder(
      column: $table.bookingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeSlot => $composableBuilder(
      column: $table.timeSlot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suitType => $composableBuilder(
      column: $table.suitType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUrgent => $composableBuilder(
      column: $table.isUrgent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get charges => $composableBuilder(
      column: $table.charges, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tailorNotes => $composableBuilder(
      column: $table.tailorNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BookingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get bookingDate => $composableBuilder(
      column: $table.bookingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeSlot => $composableBuilder(
      column: $table.timeSlot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suitType => $composableBuilder(
      column: $table.suitType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUrgent => $composableBuilder(
      column: $table.isUrgent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get charges => $composableBuilder(
      column: $table.charges, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tailorNotes => $composableBuilder(
      column: $table.tailorNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BookingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<DateTime> get bookingDate => $composableBuilder(
      column: $table.bookingDate, builder: (column) => column);

  GeneratedColumn<String> get timeSlot =>
      $composableBuilder(column: $table.timeSlot, builder: (column) => column);

  GeneratedColumn<String> get suitType =>
      $composableBuilder(column: $table.suitType, builder: (column) => column);

  GeneratedColumn<bool> get isUrgent =>
      $composableBuilder(column: $table.isUrgent, builder: (column) => column);

  GeneratedColumn<double> get charges =>
      $composableBuilder(column: $table.charges, builder: (column) => column);

  GeneratedColumn<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tailorNotes => $composableBuilder(
      column: $table.tailorNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookingsTable,
    BookingRow,
    $$BookingsTableFilterComposer,
    $$BookingsTableOrderingComposer,
    $$BookingsTableAnnotationComposer,
    $$BookingsTableCreateCompanionBuilder,
    $$BookingsTableUpdateCompanionBuilder,
    (BookingRow, BaseReferences<_$AppDatabase, $BookingsTable, BookingRow>),
    BookingRow,
    PrefetchHooks Function()> {
  $$BookingsTableTableManager(_$AppDatabase db, $BookingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String> customerEmail = const Value.absent(),
            Value<String> customerPhone = const Value.absent(),
            Value<DateTime> bookingDate = const Value.absent(),
            Value<String> timeSlot = const Value.absent(),
            Value<String> suitType = const Value.absent(),
            Value<bool> isUrgent = const Value.absent(),
            Value<double> charges = const Value.absent(),
            Value<String?> specialInstructions = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> tailorNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BookingsCompanion(
            id: id,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            bookingDate: bookingDate,
            timeSlot: timeSlot,
            suitType: suitType,
            isUrgent: isUrgent,
            charges: charges,
            specialInstructions: specialInstructions,
            status: status,
            tailorNotes: tailorNotes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String customerName,
            required String customerEmail,
            required String customerPhone,
            required DateTime bookingDate,
            required String timeSlot,
            required String suitType,
            Value<bool> isUrgent = const Value.absent(),
            required double charges,
            Value<String?> specialInstructions = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> tailorNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BookingsCompanion.insert(
            id: id,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            bookingDate: bookingDate,
            timeSlot: timeSlot,
            suitType: suitType,
            isUrgent: isUrgent,
            charges: charges,
            specialInstructions: specialInstructions,
            status: status,
            tailorNotes: tailorNotes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookingsTable,
    BookingRow,
    $$BookingsTableFilterComposer,
    $$BookingsTableOrderingComposer,
    $$BookingsTableAnnotationComposer,
    $$BookingsTableCreateCompanionBuilder,
    $$BookingsTableUpdateCompanionBuilder,
    (BookingRow, BaseReferences<_$AppDatabase, $BookingsTable, BookingRow>),
    BookingRow,
    PrefetchHooks Function()>;
typedef $$MeasurementsTableCreateCompanionBuilder = MeasurementsCompanion
    Function({
  Value<int> id,
  required String customerName,
  required String customerEmail,
  required String customerPhone,
  Value<double?> chest,
  Value<double?> waist,
  Value<double?> hips,
  Value<double?> shoulder,
  Value<double?> sleeveLength,
  Value<double?> shirtLength,
  Value<double?> pantLength,
  Value<double?> inseam,
  Value<double?> neck,
  Value<double?> bicep,
  Value<double?> wrist,
  Value<double?> thigh,
  Value<double?> calf,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$MeasurementsTableUpdateCompanionBuilder = MeasurementsCompanion
    Function({
  Value<int> id,
  Value<String> customerName,
  Value<String> customerEmail,
  Value<String> customerPhone,
  Value<double?> chest,
  Value<double?> waist,
  Value<double?> hips,
  Value<double?> shoulder,
  Value<double?> sleeveLength,
  Value<double?> shirtLength,
  Value<double?> pantLength,
  Value<double?> inseam,
  Value<double?> neck,
  Value<double?> bicep,
  Value<double?> wrist,
  Value<double?> thigh,
  Value<double?> calf,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});

class $$MeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get chest => $composableBuilder(
      column: $table.chest, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get waist => $composableBuilder(
      column: $table.waist, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hips => $composableBuilder(
      column: $table.hips, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shoulder => $composableBuilder(
      column: $table.shoulder, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sleeveLength => $composableBuilder(
      column: $table.sleeveLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shirtLength => $composableBuilder(
      column: $table.shirtLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pantLength => $composableBuilder(
      column: $table.pantLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get inseam => $composableBuilder(
      column: $table.inseam, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get neck => $composableBuilder(
      column: $table.neck, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bicep => $composableBuilder(
      column: $table.bicep, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wrist => $composableBuilder(
      column: $table.wrist, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get thigh => $composableBuilder(
      column: $table.thigh, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calf => $composableBuilder(
      column: $table.calf, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get chest => $composableBuilder(
      column: $table.chest, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get waist => $composableBuilder(
      column: $table.waist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hips => $composableBuilder(
      column: $table.hips, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shoulder => $composableBuilder(
      column: $table.shoulder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sleeveLength => $composableBuilder(
      column: $table.sleeveLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shirtLength => $composableBuilder(
      column: $table.shirtLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pantLength => $composableBuilder(
      column: $table.pantLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get inseam => $composableBuilder(
      column: $table.inseam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get neck => $composableBuilder(
      column: $table.neck, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bicep => $composableBuilder(
      column: $table.bicep, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wrist => $composableBuilder(
      column: $table.wrist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get thigh => $composableBuilder(
      column: $table.thigh, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calf => $composableBuilder(
      column: $table.calf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<double> get chest =>
      $composableBuilder(column: $table.chest, builder: (column) => column);

  GeneratedColumn<double> get waist =>
      $composableBuilder(column: $table.waist, builder: (column) => column);

  GeneratedColumn<double> get hips =>
      $composableBuilder(column: $table.hips, builder: (column) => column);

  GeneratedColumn<double> get shoulder =>
      $composableBuilder(column: $table.shoulder, builder: (column) => column);

  GeneratedColumn<double> get sleeveLength => $composableBuilder(
      column: $table.sleeveLength, builder: (column) => column);

  GeneratedColumn<double> get shirtLength => $composableBuilder(
      column: $table.shirtLength, builder: (column) => column);

  GeneratedColumn<double> get pantLength => $composableBuilder(
      column: $table.pantLength, builder: (column) => column);

  GeneratedColumn<double> get inseam =>
      $composableBuilder(column: $table.inseam, builder: (column) => column);

  GeneratedColumn<double> get neck =>
      $composableBuilder(column: $table.neck, builder: (column) => column);

  GeneratedColumn<double> get bicep =>
      $composableBuilder(column: $table.bicep, builder: (column) => column);

  GeneratedColumn<double> get wrist =>
      $composableBuilder(column: $table.wrist, builder: (column) => column);

  GeneratedColumn<double> get thigh =>
      $composableBuilder(column: $table.thigh, builder: (column) => column);

  GeneratedColumn<double> get calf =>
      $composableBuilder(column: $table.calf, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    MeasurementRow,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableAnnotationComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder,
    (
      MeasurementRow,
      BaseReferences<_$AppDatabase, $MeasurementsTable, MeasurementRow>
    ),
    MeasurementRow,
    PrefetchHooks Function()> {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String> customerEmail = const Value.absent(),
            Value<String> customerPhone = const Value.absent(),
            Value<double?> chest = const Value.absent(),
            Value<double?> waist = const Value.absent(),
            Value<double?> hips = const Value.absent(),
            Value<double?> shoulder = const Value.absent(),
            Value<double?> sleeveLength = const Value.absent(),
            Value<double?> shirtLength = const Value.absent(),
            Value<double?> pantLength = const Value.absent(),
            Value<double?> inseam = const Value.absent(),
            Value<double?> neck = const Value.absent(),
            Value<double?> bicep = const Value.absent(),
            Value<double?> wrist = const Value.absent(),
            Value<double?> thigh = const Value.absent(),
            Value<double?> calf = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              MeasurementsCompanion(
            id: id,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            chest: chest,
            waist: waist,
            hips: hips,
            shoulder: shoulder,
            sleeveLength: sleeveLength,
            shirtLength: shirtLength,
            pantLength: pantLength,
            inseam: inseam,
            neck: neck,
            bicep: bicep,
            wrist: wrist,
            thigh: thigh,
            calf: calf,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String customerName,
            required String customerEmail,
            required String customerPhone,
            Value<double?> chest = const Value.absent(),
            Value<double?> waist = const Value.absent(),
            Value<double?> hips = const Value.absent(),
            Value<double?> shoulder = const Value.absent(),
            Value<double?> sleeveLength = const Value.absent(),
            Value<double?> shirtLength = const Value.absent(),
            Value<double?> pantLength = const Value.absent(),
            Value<double?> inseam = const Value.absent(),
            Value<double?> neck = const Value.absent(),
            Value<double?> bicep = const Value.absent(),
            Value<double?> wrist = const Value.absent(),
            Value<double?> thigh = const Value.absent(),
            Value<double?> calf = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              MeasurementsCompanion.insert(
            id: id,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            chest: chest,
            waist: waist,
            hips: hips,
            shoulder: shoulder,
            sleeveLength: sleeveLength,
            shirtLength: shirtLength,
            pantLength: pantLength,
            inseam: inseam,
            neck: neck,
            bicep: bicep,
            wrist: wrist,
            thigh: thigh,
            calf: calf,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MeasurementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    MeasurementRow,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableAnnotationComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder,
    (
      MeasurementRow,
      BaseReferences<_$AppDatabase, $MeasurementsTable, MeasurementRow>
    ),
    MeasurementRow,
    PrefetchHooks Function()>;
typedef $$PickupRequestsTableCreateCompanionBuilder = PickupRequestsCompanion
    Function({
  Value<int> id,
  required String customerName,
  required String customerEmail,
  required String customerPhone,
  required String requestType,
  Value<int?> relatedBookingId,
  required String pickupAddress,
  Value<String?> trackingNumber,
  Value<String?> courierName,
  Value<String> status,
  required double charges,
  Value<String?> notes,
  required DateTime requestedDate,
  Value<DateTime?> completedDate,
  Value<DateTime> createdAt,
});
typedef $$PickupRequestsTableUpdateCompanionBuilder = PickupRequestsCompanion
    Function({
  Value<int> id,
  Value<String> customerName,
  Value<String> customerEmail,
  Value<String> customerPhone,
  Value<String> requestType,
  Value<int?> relatedBookingId,
  Value<String> pickupAddress,
  Value<String?> trackingNumber,
  Value<String?> courierName,
  Value<String> status,
  Value<double> charges,
  Value<String?> notes,
  Value<DateTime> requestedDate,
  Value<DateTime?> completedDate,
  Value<DateTime> createdAt,
});

class $$PickupRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $PickupRequestsTable> {
  $$PickupRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requestType => $composableBuilder(
      column: $table.requestType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get relatedBookingId => $composableBuilder(
      column: $table.relatedBookingId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pickupAddress => $composableBuilder(
      column: $table.pickupAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackingNumber => $composableBuilder(
      column: $table.trackingNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courierName => $composableBuilder(
      column: $table.courierName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get charges => $composableBuilder(
      column: $table.charges, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get requestedDate => $composableBuilder(
      column: $table.requestedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PickupRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PickupRequestsTable> {
  $$PickupRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requestType => $composableBuilder(
      column: $table.requestType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get relatedBookingId => $composableBuilder(
      column: $table.relatedBookingId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pickupAddress => $composableBuilder(
      column: $table.pickupAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackingNumber => $composableBuilder(
      column: $table.trackingNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courierName => $composableBuilder(
      column: $table.courierName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get charges => $composableBuilder(
      column: $table.charges, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get requestedDate => $composableBuilder(
      column: $table.requestedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PickupRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PickupRequestsTable> {
  $$PickupRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<String> get requestType => $composableBuilder(
      column: $table.requestType, builder: (column) => column);

  GeneratedColumn<int> get relatedBookingId => $composableBuilder(
      column: $table.relatedBookingId, builder: (column) => column);

  GeneratedColumn<String> get pickupAddress => $composableBuilder(
      column: $table.pickupAddress, builder: (column) => column);

  GeneratedColumn<String> get trackingNumber => $composableBuilder(
      column: $table.trackingNumber, builder: (column) => column);

  GeneratedColumn<String> get courierName => $composableBuilder(
      column: $table.courierName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get charges =>
      $composableBuilder(column: $table.charges, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get requestedDate => $composableBuilder(
      column: $table.requestedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PickupRequestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PickupRequestsTable,
    PickupRequestRow,
    $$PickupRequestsTableFilterComposer,
    $$PickupRequestsTableOrderingComposer,
    $$PickupRequestsTableAnnotationComposer,
    $$PickupRequestsTableCreateCompanionBuilder,
    $$PickupRequestsTableUpdateCompanionBuilder,
    (
      PickupRequestRow,
      BaseReferences<_$AppDatabase, $PickupRequestsTable, PickupRequestRow>
    ),
    PickupRequestRow,
    PrefetchHooks Function()> {
  $$PickupRequestsTableTableManager(
      _$AppDatabase db, $PickupRequestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PickupRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PickupRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PickupRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String> customerEmail = const Value.absent(),
            Value<String> customerPhone = const Value.absent(),
            Value<String> requestType = const Value.absent(),
            Value<int?> relatedBookingId = const Value.absent(),
            Value<String> pickupAddress = const Value.absent(),
            Value<String?> trackingNumber = const Value.absent(),
            Value<String?> courierName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> charges = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> requestedDate = const Value.absent(),
            Value<DateTime?> completedDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PickupRequestsCompanion(
            id: id,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            requestType: requestType,
            relatedBookingId: relatedBookingId,
            pickupAddress: pickupAddress,
            trackingNumber: trackingNumber,
            courierName: courierName,
            status: status,
            charges: charges,
            notes: notes,
            requestedDate: requestedDate,
            completedDate: completedDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String customerName,
            required String customerEmail,
            required String customerPhone,
            required String requestType,
            Value<int?> relatedBookingId = const Value.absent(),
            required String pickupAddress,
            Value<String?> trackingNumber = const Value.absent(),
            Value<String?> courierName = const Value.absent(),
            Value<String> status = const Value.absent(),
            required double charges,
            Value<String?> notes = const Value.absent(),
            required DateTime requestedDate,
            Value<DateTime?> completedDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PickupRequestsCompanion.insert(
            id: id,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            requestType: requestType,
            relatedBookingId: relatedBookingId,
            pickupAddress: pickupAddress,
            trackingNumber: trackingNumber,
            courierName: courierName,
            status: status,
            charges: charges,
            notes: notes,
            requestedDate: requestedDate,
            completedDate: completedDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PickupRequestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PickupRequestsTable,
    PickupRequestRow,
    $$PickupRequestsTableFilterComposer,
    $$PickupRequestsTableOrderingComposer,
    $$PickupRequestsTableAnnotationComposer,
    $$PickupRequestsTableCreateCompanionBuilder,
    $$PickupRequestsTableUpdateCompanionBuilder,
    (
      PickupRequestRow,
      BaseReferences<_$AppDatabase, $PickupRequestsTable, PickupRequestRow>
    ),
    PickupRequestRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TailorsTableTableManager get tailors =>
      $$TailorsTableTableManager(_db, _db.tailors);
  $$DesignsTableTableManager get designs =>
      $$DesignsTableTableManager(_db, _db.designs);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db, _db.complaints);
  $$BookingsTableTableManager get bookings =>
      $$BookingsTableTableManager(_db, _db.bookings);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$PickupRequestsTableTableManager get pickupRequests =>
      $$PickupRequestsTableTableManager(_db, _db.pickupRequests);
}
