import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'medicine_model.g.dart';

@JsonSerializable()
class MedicineModel {
  final String id;
  final String name;
  final String brand;
  final String barcode;
  final List<String> ingredients;
  final int naturalness;
  final String summary;
  final List<String> sideEffects;
  final String dosageInfo;
  final List<String> interactions;
  final String? imageUrl;
  final DateTime createdAt;

  MedicineModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.barcode,
    required this.ingredients,
    required this.naturalness,
    required this.summary,
    required this.sideEffects,
    required this.dosageInfo,
    required this.interactions,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MedicineModel.fromJson(Map<String, dynamic> json) =>
      _$MedicineModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineModelToJson(this);

  factory MedicineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicineModel(
      id: doc.id,
      name: data['name'] as String,
      brand: data['brand'] as String,
      barcode: data['barcode'] as String,
      ingredients: List<String>.from(data['ingredients']),
      naturalness: data['naturalness'] as int,
      summary: data['summary'] as String,
      sideEffects: List<String>.from(data['sideEffects']),
      dosageInfo: data['dosageInfo'] as String,
      interactions: List<String>.from(data['interactions']),
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
