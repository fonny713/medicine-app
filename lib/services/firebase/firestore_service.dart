import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Medicine operations
  Future<void> saveMedicine(Map<String, dynamic> medicineData) async {
    await _firestore.collection('medicines').add(medicineData);
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
  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);
  }

  Future<void> updateUserMedicineList(String uid, List<String> medList) async {
    await _firestore.collection('users').doc(uid).update({'medList': medList});
  }
}
