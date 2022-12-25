// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Users {
  final String imagePath;
  final String email;
  final String bio;
  final bool isDarkMode;
  final bool isOnline;

  const Users(
      {required this.imagePath,
      required this.email,
      required this.bio,
      required this.isDarkMode,
      required this.isOnline});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'email': email,
      'bio': bio,
      'isDarkMode': isDarkMode,
      'isOnline': isOnline,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      imagePath: map['imagePath'],
      email: map['email'] as String,
      bio: map['bio'] as String,
      isDarkMode: ['isDarkMode'] as bool,
      isOnline: map['isOnline'] as bool,
    );
  }
}
