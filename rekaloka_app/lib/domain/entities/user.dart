import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username; 
  final String email;
  final bool isVerified; 
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username, 
    required this.email,
    required this.isVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? username, 
    bool? isVerified, 
    DateTime? updatedAt
  }) {
    return User(
      id: id,
      username: username ?? this.username, 
      email: email,
      isVerified: isVerified ?? this.isVerified, 
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    username, // KOREKSI
    email,
    isVerified, // BARU
    emailVerifiedAt,
    createdAt,
    updatedAt,
  ];

  @override
  bool get stringify => true;
}