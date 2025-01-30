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