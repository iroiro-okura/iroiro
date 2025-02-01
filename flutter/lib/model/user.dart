import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.uid,
    required this.email,
    required this.name,
    this.age,
    this.gender,
    this.occupation,
  });

  final String uid;
  final String email;
  final String name;
  final int? age;
  final Gender? gender;
  final String? occupation;

  factory User.fromJson(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      email: data['email'] as String,
      name: data['name'] as String,
      age: data['age'] as int?,
      gender: data['gender'] != null ? Gender.values[data['gender'] as int] : null,
      occupation: data['occupation'] as String?,
    );
  }
}

enum Gender {
  male,
  female,
  other,
}
