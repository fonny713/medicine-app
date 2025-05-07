// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InteractionModel _$InteractionModelFromJson(Map<String, dynamic> json) =>
    InteractionModel(
      id: json['id'] as String,
      med1Id: json['med1Id'] as String,
      med2Id: json['med2Id'] as String,
      conflictType: json['conflictType'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$ConflictSeverityEnumMap, json['severity']),
      source: json['source'] as String,
    );

Map<String, dynamic> _$InteractionModelToJson(InteractionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'med1Id': instance.med1Id,
      'med2Id': instance.med2Id,
      'conflictType': instance.conflictType,
      'description': instance.description,
      'severity': _$ConflictSeverityEnumMap[instance.severity]!,
      'source': instance.source,
    };

const _$ConflictSeverityEnumMap = {
  ConflictSeverity.low: 'low',
  ConflictSeverity.medium: 'medium',
  ConflictSeverity.high: 'high',
};
