import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? avatarUrl;
  final List<String> medList;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.avatarUrl,
    List<String>? medList,
    DateTime? createdAt,
  }) : medList = medList ?? [],
       createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      username: data['username'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      medList: List<String>.from(data['medList'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
