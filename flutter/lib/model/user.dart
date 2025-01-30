import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.email,
    required this.name,
    this.age,
    this.gender,
    this.occupation,
  });

  final String email;
  final String name;
  final int? age;
  final Sex? gender;
  final String? occupation;

  factory User.fromSnapshot(String uid, DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      email: data['email'] as String,
      name: data['name'] as String,
      age: data['age'] as int?,
      gender: data['sex'] != null ? Sex.values[data['sex'] as int] : null,
      occupation: data['occupation'] as String?,
    );
  }

}

enum Sex {
  male,
  female,
  other,
}
