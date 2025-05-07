import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'interaction_model.g.dart';

enum ConflictSeverity { low, medium, high }

@JsonSerializable()
class InteractionModel {
  final String id;
  final String med1Id;
  final String med2Id;
  final String conflictType;
  final String description;
  final ConflictSeverity severity;
  final String source;

  InteractionModel({
    required this.id,
    required this.med1Id,
    required this.med2Id,
    required this.conflictType,
    required this.description,
    required this.severity,
    required this.source,
  });

  factory InteractionModel.fromJson(Map<String, dynamic> json) =>
      _$InteractionModelFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionModelToJson(this);

  factory InteractionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InteractionModel(
      id: doc.id,
      med1Id: data['med1Id'] as String,
      med2Id: data['med2Id'] as String,
      conflictType: data['conflictType'] as String,
      description: data['description'] as String,
      severity: ConflictSeverity.values.firstWhere(
        (e) => e.toString() == 'ConflictSeverity.${data['severity']}',
      ),
      source: data['source'] as String,
    );
  }
}
