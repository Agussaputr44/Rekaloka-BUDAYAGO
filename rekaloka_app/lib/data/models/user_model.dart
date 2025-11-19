import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final bool isVerified;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.isVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final String username = json['username'] as String? ?? '';
    final String email = json['email'] as String? ?? '';

    final createdAtString =
        json['createdAt']?.toString() ?? json['created_at']?.toString();
    final updatedAtString =
        json['updatedAt']?.toString() ?? json['updated_at']?.toString();

    final DateTime createdAt =
        DateTime.tryParse(createdAtString ?? '') ?? DateTime.now();
    final DateTime updatedAt =
        DateTime.tryParse(updatedAtString ?? '') ?? DateTime.now();

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: username,
      email: email,
      isVerified: json['is_verify'] as bool? ?? false,

      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,

      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_verify': isVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    isVerified: isVerified,
    emailVerifiedAt: emailVerifiedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    isVerified,
    emailVerifiedAt,
    createdAt,
    updatedAt,
  ];
}
