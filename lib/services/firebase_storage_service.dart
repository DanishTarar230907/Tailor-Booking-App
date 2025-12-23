import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

/// Service for uploading images to Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image from file path (mobile) or bytes (web)
  Future<String> uploadImage({
    required String path,
    required String folder,
    XFile? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      String? downloadUrl;
      
      if (kIsWeb) {
        // Web: use bytes
        if (imageBytes == null && imageFile != null) {
          imageBytes = await imageFile.readAsBytes();
        }
        if (imageBytes == null) {
          throw Exception('No image data provided');
        }
        
        final ref = _storage.ref().child('$folder/${fileName ?? DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = ref.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        await uploadTask;
        downloadUrl = await ref.getDownloadURL();
      } else {
        // Mobile: use file
        if (imageFile == null) {
          throw Exception('No image file provided');
        }
        
        final ref = _storage.ref().child('$folder/${fileName ?? DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = ref.putFile(
          File(imageFile.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        await uploadTask;
        downloadUrl = await ref.getDownloadURL();
      }
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload design image
  Future<String> uploadDesignImage(XFile imageFile) async {
    return uploadImage(
      path: imageFile.path,
      folder: 'designs',
      imageFile: imageFile,
      fileName: 'design_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Upload tailor profile image
  Future<String> uploadTailorImage(XFile imageFile) async {
    return uploadImage(
      path: imageFile.path,
      folder: 'tailors',
      imageFile: imageFile,
      fileName: 'tailor_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw - image might already be deleted
    }
  }
}

