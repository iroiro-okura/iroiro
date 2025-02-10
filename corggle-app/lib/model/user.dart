class User {
  User({
    required this.uid,
    required this.email,
    required this.name,
    this.age,
    this.gender,
    this.occupation,
    this.hometown,
    this.hobbies,
  });

  final String uid;
  final String email;
  final String name;
  final int? age;
  final Gender? gender;
  final String? occupation;
  final String? hometown;
  final List<String>? hobbies;

  factory User.fromJson(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      email: data['email'] as String,
      name: data['name'] as String,
      age: data['age'] as int?,
      gender: data['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.toString() == 'Gender.${data['gender']}',
              orElse: () => Gender.other,
            )
          : null,
      occupation: data['occupation'] as String?,
      hometown: data['hometown'] as String?,
      hobbies: data['hobbies'] != null
          ? List<String>.from(data['hobbies'] as List)
          : null,
    );
  }
}

enum Gender {
  male,
  female,
  other,
}
