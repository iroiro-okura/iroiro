import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iroiro/firebase/firestore.dart';

class Chat {
  final String chatId;
  final String uid;
  final String topic;
  final DateTime createdAt;

  Chat({
    required this.chatId,
    required this.uid,
    required this.topic,
    required this.createdAt,
  });

  factory Chat.fromJson(String chatId, Map<String, dynamic> chatData) {
    return Chat(
      chatId: chatId,
      uid: chatData['uid'] as String,
      topic: chatData['topic'] as String,
      createdAt: (chatData['createdAt'] as Timestamp).toDate(),
    );
  }

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      chatId: doc.id,
      uid: data['uid'] as String,
      topic: data['chatArgument'] as String? ?? 'No topic',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class Message {
  final Sender sender;
  final String text;
  final Status status;
  final DateTime sentAt;
  final bool isReplyAllowed;
  final List<String>? answerOptions;

  Message({
    required this.sender,
    required this.text,
    required this.status,
    required this.sentAt,
    required this.isReplyAllowed,
    this.answerOptions,
  });

  factory Message.fromJson(Map<String, dynamic> data) {
    logger.d('Message.fromJson: $data');
    return Message(
      sender: data['sender'] == 'model' ? Sender.model : Sender.user,
      text: data['text'] as String,
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isReplyAllowed: data['isReplyAllowed'] as bool,
      answerOptions: List<String>.from(data['answerOptions'] as List? ?? []),
    );
  }

  @override
  String toString() {
    return 'Message{sender: $sender, text: $text, sentAt: $sentAt, status: $status, isReplyAllowed: $isReplyAllowed, answerOptions: $answerOptions}';
  }
}

enum Status {
  inProgress,
  failed,
  sent,
}

enum Sender {
  model,
  user,
}

enum Topic { dating, reunion, companyGathering }
