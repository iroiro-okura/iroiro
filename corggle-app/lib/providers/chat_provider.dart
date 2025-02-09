import 'package:flutter/material.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/chat.dart';

class ChatProvider with ChangeNotifier {
  String _scene = '';
  Chat? _chat;

  String get argument => _scene;
  Chat? get chat => _chat;

  void setScene(String scene) {
    _scene = scene;
    notifyListeners();
  }

  void resetScene() {
    _scene = '';
    notifyListeners();
  }

  Future<void> createNewChat(String uid, String scene) async {
    _chat = await FirestoreService.createChat(uid, scene, "");
    notifyListeners();
  }

  Future<void> getChat(String chatId) async {
    final pastChat = await FirestoreService.getChat(chatId);
    if (pastChat != null) {
      _chat = pastChat;
    }
    notifyListeners();
  }

  Future<void> deleteChat(String chatId) async {
    await FirestoreService.deleteChat(chatId);
    _chat = null;
    notifyListeners();
  }
}
