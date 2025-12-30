import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/measurement.dart';

class FirestoreMeasurementsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('measurements');

  /// Auto-generate email from phone number for customers without email
  String _generateEmail(String phone) {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return 'customer_$sanitized@gracetailor.local';
  }

  // Use collectionGroup for reading all, but writing to specific subcollections
  // Structure: customers/{customerId}/measurements/{measurementId}
  
  Measurement _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data() ?? {};
      
      // Safely parse map
      Map<String, double> parsedMeasurements = {};
      if (data['measurements'] != null && data['measurements'] is Map) {
        (data['measurements'] as Map).forEach((k, v) {
          if (v != null) {
            parsedMeasurements[k.toString()] = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
          }
        });
      }

      DateTime _toDate(dynamic value) {
        if (value == null) return DateTime.now(); // Defensive null check
        if (value is Timestamp) return value.toDate();
        if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
        return DateTime.now();
      }
      
      // Derive customerId from parent path if possible, or data
      String cid = data['customerId'] ?? '';
      // Safe parent check for Web
      try {
        if (cid.isEmpty && doc.reference.parent.parent != null) {
           cid = doc.reference.parent.parent!.id; 
        }
      } catch (e) {
        // Prepare for possible platform errors accessing parents
        print('Error accessing doc parent for ${doc.id}: $e');
      }

      // Safe parsing of messages
      List<Map<String, dynamic>> parsedMessages = [];
      if (data['messages'] != null && data['messages'] is List) {
        parsedMessages = (data['messages'] as List).map((m) {
          if (m is Map) {
            return Map<String, dynamic>.from(m);
          }
          return <String, dynamic>{};
        }).toList(); // simplified
      }

      return Measurement(
        docId: doc.id,
        id: data['id'],
        customerId: cid,
        customerName: data['customerName'] ?? '',
        customerEmail: data['customerEmail'] ?? '',
        customerPhone: data['customerPhone'] ?? '',
        measurements: parsedMeasurements,
        status: data['status'] ?? 'Pending',
        stitchingStarted: data['stitchingStarted'] ?? false,
        stitchingStartDate: data['stitchingStartDate'] != null ? _toDate(data['stitchingStartDate']) : null,
        specialInstructions: data['specialInstructions'],
        notes: data['notes'],
        updateRequested: data['updateRequested'] ?? false,
        messages: parsedMessages,
        createdAt: _toDate(data['createdAt']),
        updatedAt: data['updatedAt'] != null ? _toDate(data['updatedAt']) : null,
        requestType: data['requestType'],
        appointmentDate: data['appointmentDate'] != null ? _toDate(data['appointmentDate']) : null,
        rejectionReason: data['rejectionReason'],
      );
    } catch (e) {
      print('CRITICAL: Error parsing measurement doc ${doc.id}: $e');
      rethrow; 
    }
  }

  Map<String, dynamic> _toMap(Measurement m) {
    return {
      'customerId': m.customerId,
      'customerName': m.customerName,
      'customerEmail': m.customerEmail,
      'customerPhone': m.customerPhone,
      'measurements': m.measurements,
      'status': m.status,
      'stitchingStarted': m.stitchingStarted,
      'stitchingStartDate': m.stitchingStartDate,
      'specialInstructions': m.specialInstructions,
      'notes': m.notes,
      'updateRequested': m.updateRequested,
      'messages': m.messages,
      'createdAt': m.createdAt,
      'updatedAt': m.updatedAt,
      'requestType': m.requestType,
      'appointmentDate': m.appointmentDate,
      'rejectionReason': m.rejectionReason,
    };
  }

  Future<Measurement?> getByCustomerEmail(String email) async {
    if (kDebugMode) print('DEBUG: Service getByCustomerEmail called for: "$email"');

    // Query 'measurements' collection instead of 'users' subcollection
    // Try to get by email from root 'measurements' if we move to root collection
    try {
      if (kDebugMode) print('DEBUG: Fetching all measurements to filter in-memory (bypassing index)...');
      // Temporary workaround: Fetch all and filter in memory to avoid index issues during dev
      final snap = await _firestore.collection('measurements').get();
      if (kDebugMode) print('DEBUG: Total docs found: ${snap.size}');

      // DEBUG: Print all documents to see what's actually stored
      for (var doc in snap.docs) {
        final data = doc.data();
        if (kDebugMode) print('DEBUG: Doc ${doc.id} has customerEmail: "${data['customerEmail']}" (looking for: "$email")');
      }
      
      final matches = snap.docs.where((doc) {
        final data = doc.data();
        // Check both direct field and inside data
        return data['customerEmail'] == email;
      }).toList();

      if (kDebugMode) print('DEBUG: Found ${matches.length} matches for $email');

      if (matches.isEmpty) return null;
      
      // Return the most recent one if multiple?
      // Let's sort by createdAt
      matches.sort((a, b) {
        final da = a.data();
        final db = b.data(); // Simple map access for sort
        final ta = da['createdAt'] is Timestamp ? (da['createdAt'] as Timestamp).toDate() : DateTime(1900);
        final tb = db['createdAt'] is Timestamp ? (db['createdAt'] as Timestamp).toDate() : DateTime(1900);
        return tb.compareTo(ta);
      });

      return _fromDoc(matches.first);
    } catch (e) {
      print('DEBUG: Error getting by email (in-memory workaround): $e');
      return null;
    }
  }
  
  Future<List<Measurement>> getAllMeasurements() async {
    try {
      // Return all measurements from ALL customers
      // Use in-memory sort to avoid missing index errors during development
      final snap = await _firestore.collectionGroup('measurements').get();
      
      // Safe mapping: Skip documents that fail parsing
      final list = snap.docs.map((doc) {
        try {
          return _fromDoc(doc);
        } catch (e) {
          print('Skipping malformed doc ${doc.id}');
          return null;
        }
      }).whereType<Measurement>().toList();
      
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      print('Error fetching all measurements (collectionGroup): $e');
      return [];
    }
  }

  Stream<List<Measurement>> getMeasurementsStream() {
    return _firestore.collectionGroup('measurements').snapshots().map((snap) {
      final list = snap.docs.map((doc) {
        try {
          return _fromDoc(doc);
        } catch (e) {
          print('Skipping malformed doc ${doc.id} in stream');
          return null;
        }
      }).whereType<Measurement>().toList();
      
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<Measurement> insertOrUpdate(Measurement measurement) async {
    String cid = measurement.customerId;
    
    // If we don't have customerId, try to resolve it from email (checking 'users' collection)
    if (cid.isEmpty) {
      final userSnap = await _firestore.collection('users').where('email', isEqualTo: measurement.customerEmail).limit(1).get();
      if (userSnap.docs.isNotEmpty) {
        cid = userSnap.docs.first.id;
      } else {
        // Fallback: Use a hashed email or creating a placeholder? 
        // For now, let's assume we create a document in 'customers' anyway.
        // We will generate an ID if needed, but linking to Auth is best.
        // Let's throw for now if we can't find a user, prompting the UI to ensure user exists?
        // Actually, let's allow creating a new random ID for 'guest' customers in 'customers' collection.
        // But we want to preserve it.
        // Let's query 'customers' collection to see if we have a doc with this email? 
        // Or just use the email as ID (sanitized) if no auth user?
        // Let's use email as ID if not found in users.
        cid = measurement.customerEmail.replaceAll('.', '_').replaceAll('@', '_at_'); 
      }
    }

    final updatedMeasurement = measurement.copyWith(customerId: cid);
    final collection = _firestore.collection('customers').doc(cid).collection('measurements');

    print('DEBUG: insertOrUpdate called for docId: ${updatedMeasurement.docId}, updateRequested: ${updatedMeasurement.updateRequested}, msgs: ${updatedMeasurement.messages.length}');
    
    final data = _toMap(updatedMeasurement); // generate map first to inspect

    if (updatedMeasurement.docId != null) {
      print('DEBUG: Setting doc ${updatedMeasurement.docId} in $collection');
      await collection.doc(updatedMeasurement.docId).set(
            _toMap(
              updatedMeasurement.copyWith(updatedAt: DateTime.now()),
            ),
          );
      return updatedMeasurement.copyWith(updatedAt: DateTime.now());
    }

    // Check existing by email/type in this subcollection?
    // Usually one measurement set per customer? Or multiple?
    // Request says "Measurement Table... contains all customers".
    // Usually one active profile.
    // Let's check if one exists in this subcollection
    final existingSnap = await collection.limit(1).get();
    if (existingSnap.docs.isNotEmpty) {
       final doc = existingSnap.docs.first;
       final updated = updatedMeasurement.copyWith(
         docId: doc.id,
         createdAt: _fromDoc(doc).createdAt, // keep original created
         updatedAt: DateTime.now(),
       );
       print('DEBUG: Updating existing doc ${doc.id}');
       await collection.doc(doc.id).set(_toMap(updated));
       return updated;
    }

    print('DEBUG: Creating NEW doc in $collection');
    final doc = await collection.add(_toMap(updatedMeasurement));
    return updatedMeasurement.copyWith(docId: doc.id);
  }
}

