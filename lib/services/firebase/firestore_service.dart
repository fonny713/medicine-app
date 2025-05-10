import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'storage_service.dart';
import '../../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();
  // Medicine operations
  Future<void> saveMedicine(
    Map<String, dynamic> medicineData, {
    File? image,
  }) async {
    final docRef = await _firestore.collection('medicines').add(medicineData);

    if (image != null) {
      final imageUrl = await _storage.uploadMedicineImage(image, docRef.id);
      await docRef.update({'imageUrl': imageUrl});
    }
  }

  Future<DocumentSnapshot?> getMedicineByBarcode(String barcode) async {
    final querySnapshot =
        await _firestore
            .collection('medicines')
            .where('barcode', isEqualTo: barcode)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }

  // User operations
  Future<void> saveUser(
    String uid,
    Map<String, dynamic> userData, {
    File? avatar,
  }) async {
    if (avatar != null) {
      final avatarUrl = await _storage.uploadUserAvatar(avatar, uid);
      userData['avatarUrl'] = avatarUrl;
    }
    await _firestore.collection('users').doc(uid).set(userData);
  }

  Future<void> updateUserMedicineList(String uid, List<String> medList) async {
    await _firestore.collection('users').doc(uid).update({'medList': medList});
  }

  // Update user avatar URL
  Future<void> updateUserAvatar(String uid, String avatarUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': avatarUrl,
    });
  }

  // Get user stream for real-time updates
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Save medicine with image bytes
  Future<void> saveMedicineWithImage(
    Map<String, dynamic> medicineData,
    List<int> imageBytes,
    String barcode,
  ) async {
    final docRef = await _firestore.collection('medicines').add(medicineData);
    final imageUrl = await _storage.uploadMedicineImageBytes(
      imageBytes,
      docRef.id,
    );
    await docRef.update({'imageUrl': imageUrl});
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
