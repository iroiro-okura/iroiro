import 'package:flutter/material.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/chat.dart';

class ChatProvider with ChangeNotifier {
  String _topic = '';
  late Chat _chat;

  String get argument => _topic;
  Chat get chat => _chat;

  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  void resetTopic() {
    _topic = '';
    notifyListeners();
  }

  Future<void> createNewChat(String uid, String topic) async {
    _chat = await FirestoreService.createChat(uid, topic, "");
  }
}
