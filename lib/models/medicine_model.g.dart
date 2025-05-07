// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineModel _$MedicineModelFromJson(
  Map<String, dynamic> json,
) => MedicineModel(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String,
  barcode: json['barcode'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>).map((e) => e as String).toList(),
  naturalness: (json['naturalness'] as num).toInt(),
  summary: json['summary'] as String,
  sideEffects:
      (json['sideEffects'] as List<dynamic>).map((e) => e as String).toList(),
  dosageInfo: json['dosageInfo'] as String,
  interactions:
      (json['interactions'] as List<dynamic>).map((e) => e as String).toList(),
  imageUrl: json['imageUrl'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MedicineModelToJson(MedicineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'barcode': instance.barcode,
      'ingredients': instance.ingredients,
      'naturalness': instance.naturalness,
      'summary': instance.summary,
      'sideEffects': instance.sideEffects,
      'dosageInfo': instance.dosageInfo,
      'interactions': instance.interactions,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };
