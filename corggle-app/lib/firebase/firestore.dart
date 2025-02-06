import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iroiro/model/chat.dart';
import 'package:logger/logger.dart';
import 'package:iroiro/firebase/auth.dart';
import 'package:iroiro/model/user.dart' as model;

var logger = Logger();

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  static final db = FirebaseFirestore.instance;

  static User _getAuthUser() {
    User? user = AuthService.auth.currentUser;
    if (user == null) {
      throw Exception('User not signed in');
    }
    return user;
  }

  static Future<model.User?> getUser() async {
    User authUser = _getAuthUser();
    logger.i('Getting user ${authUser.uid}');
    var doc = await db.collection('users').doc(authUser.uid).get();
    var data = doc.data();
    if (doc.exists && data != null) {
      return model.User.fromJson(authUser.uid, data);
    }
    return null;
  }

  static Future<void> updateUser(model.User user) async {
    User authUser = _getAuthUser();
    model.User? existingUser = await getUser();
    if (existingUser == null) {
      throw Exception('User not found');
    }
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
      updatedFields['gender'] = user.gender?.name;
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
    User authUser = _getAuthUser();
    model.User? user = await getUser();
    if (user == null) {
      logger.i('Registering user ${authUser.uid}');
      await db.collection('users').doc(authUser.uid).set({
        'email': authUser.email,
        'name': authUser.displayName,
      });
    }
  }

  static Future<Chat> createChat(
      String uid, String scene, String initialMessage) async {
    logger.i('Creating chat for user $uid with scene $scene');

    DateTime now = DateTime.now();
    // Save the chat to Firestore
    var docRef = await db.collection('chats').add({
      'uid': uid,
      'scene': scene,
      'createdAt': now,
    });

    // Create a Message object
    Message message = Message(
      sender: Sender.model,
      text: initialMessage,
      status: Status.completed,
      sentAt: now,
      isReplyAllowed: false,
    );

    // Use the sendMessage function to save the initial message
    await sendMessage(docRef.id, message);

    Chat? chat = await getChat(docRef.id);
    if (chat == null) {
      throw Exception('Chat not found');
    }
    return chat;
  }

  static Future<void> sendMessage(String chatId, Message message) async {
    logger.i('Sending message $message to chat $chatId');
    await db.collection('chats').doc(chatId).collection('messages').add({
      'sender': message.sender == Sender.model ? 'model' : 'user',
      'text': message.text,
      'sentAt': message.sentAt,
      'status': message.status.toString().split('.').last,
      'isReplyAllowed': message.isReplyAllowed,
      'answerOptions': message.answerOptions,
    });
  }

  static Future<Chat?> getChat(String chatId) async {
    logger.i('Getting chat $chatId');
    return await db
        .collection('chats')
        .doc(chatId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        var chat = Chat.fromJson(chatId, data);
        return chat;
      } else {
        logger.w('Chat $chatId does not exist');
        return null;
      }
    });
  }

  static Future<List<Message>?> getMessages(String chatId) async {
    logger.i('Getting messages for chat $chatId');
    var querySnapshot =
        await db.collection('chats').doc(chatId).collection('messages').get();
    return querySnapshot.docs.map((doc) {
      return Message.fromJson(doc.data());
    }).toList();
  }

  static Stream<List<Message>> messageStream(String chatId) {
    logger.i('Listening to messages for chat $chatId');
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    });
  }
}
