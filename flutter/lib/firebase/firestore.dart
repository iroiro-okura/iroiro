import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:iroiro/firebase/auth.dart';
import 'package:iroiro/model/user.dart' as model;

var logger = Logger();

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  static final db = FirebaseFirestore.instance;

  static Future<model.User?> getUser() async {
    User? authUser = AuthService.auth.currentUser;
    if (authUser == null) {
      return null;
    }
    logger.i('Getting user ${authUser.uid}');
    var doc = await db.collection('users').doc(authUser.uid).get();
    if (doc.exists) {
      return model.User.fromSnapshot(authUser.uid, doc);
    }
    return null;
  }

  static Future<void> updateUser(model.User user) async {
    User? authUser = AuthService.auth.currentUser;
    if (authUser == null) {
      return;
    }
    var existingUserDoc = await db.collection('users').doc(authUser.uid).get();
    if (!existingUserDoc.exists) {
      return;
    }
    model.User existingUser = model.User.fromSnapshot(authUser.uid, existingUserDoc);
    // Create a map to hold the updated fields
    Map<String, dynamic> updatedFields = {};

    // Compare each field and add to the map if different
    if (user.email != existingUser.email) {
      updatedFields['email'] = user.email;
    }
    if (user.name != existingUser.name) {
      updatedFields['name'] = user.name;
    }
    if (user.age != existingUser.age) {
      updatedFields['age'] = user.age;
    }
    if (user.gender != existingUser.gender) {
      updatedFields['gender'] = user.gender?.index;
    }
    if (user.occupation != existingUser.occupation) {
      updatedFields['occupation'] = user.occupation;
    }

    // Update the Firestore document with the changed fields
    logger.i('Setting user $user');
    if (updatedFields.isNotEmpty) {
      await db.collection('users').doc(authUser.uid).update(updatedFields);
    }
  }

  static Future<void> registerUser() async {
    User? authUser = AuthService.auth.currentUser;
    model.User? user = authUser != null ? await getUser() : null;
    if (authUser != null && user == null) {
      logger.i('Registering user ${authUser.uid}');
      await db.collection('users').doc(authUser.uid).set({
        'email': authUser.email,
        'name': authUser.displayName,
      });
    }
  }
}