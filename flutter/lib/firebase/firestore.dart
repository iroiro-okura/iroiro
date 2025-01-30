import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  static final db = FirebaseFirestore.instance;

  static Future<void> registerUser() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      logger.i('Registering user $user');
      await db.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName,
      });
    }
  }
}