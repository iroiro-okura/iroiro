import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iroiro/firebase/firestore.dart';

class Chat {
  final String chatId;
  final String uid;
  final String scene;
  final DateTime createdAt;

  Chat({
    required this.chatId,
    required this.uid,
    required this.scene,
    required this.createdAt,
  });

  factory Chat.fromJson(String chatId, Map<String, dynamic> chatData) {
    return Chat(
      chatId: chatId,
      uid: chatData['uid'] as String,
      scene: chatData['scene'] as String,
      createdAt: (chatData['createdAt'] as Timestamp).toDate(),
    );
  }

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      chatId: doc.id,
      uid: data['uid'] as String,
      scene: data['chatArgument'] as String? ?? 'No scene',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class Message {
  final Sender sender;
  final String text;
  final Status status;
  final bool isReplyAllowed;
  final List<String>? answerOptions;

  Message({
    required this.sender,
    required this.text,
    required this.status,
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
      isReplyAllowed: data['isReplyAllowed'] as bool,
      answerOptions: List<String>.from(data['answerOptions'] as List? ?? []),
    );
  }

  @override
  String toString() {
    return 'Message{sender: $sender, text: $text, status: $status, isReplyAllowed: $isReplyAllowed, answerOptions: $answerOptions}';
  }
}

enum Status {
  inProgress,
  failed,
  completed,
}

enum Sender {
  model,
  user,
}

const dating = "初めてのデート";
const reunion = "同窓会";
const companyGathering = "会社の懇親会";
