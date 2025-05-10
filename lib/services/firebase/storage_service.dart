import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload medicine image
  Future<String> uploadMedicineImage(File image, String medicineId) async {
    return uploadFile(image, 'medicines/$medicineId.jpg');
  }

  // Upload user avatar
  Future<String> uploadUserAvatar(File image, String userId) async {
    return uploadFile(image, 'avatars/$userId.jpg');
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get download URL for a file
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload medicine image from bytes
  Future<String> uploadMedicineImageBytes(
    List<int> imageBytes,
    String medicineId,
  ) async {
    try {
      final ref = _storage.ref().child('medicines/$medicineId.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = await ref.putData(
        Uint8List.fromList(imageBytes),
        metadata,
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
