import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String userId;
  final String topic;
  final DateTime createdAt;
  List<Message> messages;

  Chat({required this.chatId, required this.userId, required this.topic, required this.createdAt, required this.messages});

  factory Chat.fromJson(String chatId, Map<String, dynamic> chatData) {
    return Chat(
      chatId: chatId,
      userId: chatData['userId'] as String,
      topic: chatData['topic'] as String,
      createdAt: (chatData['createdAt'] as Timestamp).toDate(),
      messages: [],
    );
  }
}

class Message {
  final Sender sender;
  final String text;
  final DateTime sentAt;

  Message({required this.sender, required this.text, required this.sentAt});

  factory Message.fromJson(Map<String, dynamic> data) {
    return Message(
      sender: data['sender'] == 'corggle' ? Sender.corggle : Sender.user,
      text: data['text'] as String,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
    );
  }
}

enum Sender {
  corggle,
  user,
}