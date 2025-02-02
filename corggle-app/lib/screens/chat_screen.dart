import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iroiro/components/animation_dot.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/chat.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late String chatArgument;
  Chat? targetChat;
  Stream<QuerySnapshot>? _chatsStream;
  Message? _lastMessage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    chatArgument = chatProvider.argument;
    final uid = userProvider.user!.uid;

    final initialMessage = chatArgument.isEmpty
        ? 'Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n今回は話題を探しているんだね。\n最適な話題を見つけるためにも、シチュエーションとお相手について教えてほしいな！'
        : 'Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n今回は『$chatArgument』で話題を探しているんだね。\n最適な話題を見つけるためにも、お相手のことをもう少し教えてほしいな！';

    targetChat =
        await FirestoreService.createChat(uid, chatArgument, initialMessage);

    // Remove this from here
    await Future.delayed(const Duration(seconds: 2));
    FirestoreService.sendMessage(
      targetChat!.chatId,
      Message(
        sender: Sender.corggle,
        text: "お相手の性別は？",
        status: Status.sent,
        sentAt: DateTime.now(),
        isReplyAllowed: true,
        answerOptions: ["男性", "女性", "その他"],
      ),
    );
    _lastMessage = Message(
      sender: Sender.corggle,
      text: "お相手の性別は？",
      status: Status.sent,
      sentAt: DateTime.now(),
      isReplyAllowed: true,
      answerOptions: ["男性", "女性", "その他"],
    );
    // to here

    if (targetChat != null) {
      setState(() {
        _chatsStream = FirebaseFirestore.instance
            .collection('chats')
            .doc(targetChat!.chatId)
            .collection('messages')
            .orderBy('sentAt', descending: false)
            .snapshots();
      });
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty && targetChat?.chatId != null) {
      FirestoreService.sendMessage(
        targetChat!.chatId,
        Message(
            sender: Sender.user,
            text: _controller.text,
            status: Status.sent,
            sentAt: DateTime.now(),
            isReplyAllowed: false),
      );
      // Remove this
      await Future.delayed(const Duration(seconds: 1));
      FirestoreService.sendMessage(
        targetChat!.chatId,
        Message(
          sender: Sender.corggle,
          text: "this is demo response from Corggle",
          status: Status.sent,
          sentAt: DateTime.now(),
          isReplyAllowed: true,
          answerOptions: ["Option 1", "Option 2", "Option 3"],
        ),
      );
      _controller.clear();
    }
  }

  void _sendMessageFromOption(String option) async {
    FirestoreService.sendMessage(
      targetChat!.chatId,
      Message(
        sender: Sender.user,
        text: option,
        status: Status.sent,
        sentAt: DateTime.now(),
        isReplyAllowed: false,
      ),
    );
  }

  Widget _buildAvatar(String name, bool isUser) {
    return isUser
        ? ClipOval(
            child: SvgPicture.string(
              RandomAvatarString(name),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          )
        : ClipOval(
            child: Image.asset(
              'assets/images/cogimi.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final name = Provider.of<UserProvider>(context, listen: false).user!.name;

    return Scaffold(
      appBar: CorggleAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: AnimatedDots());
                }

                final messages = snapshot.data!.docs;
                _lastMessage = Message.fromJson(
                    messages.last.data() as Map<String, dynamic>);

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final isUser = data['sender'] == 'user';

                    return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ListTile(
                          leading: isUser ? null : _buildAvatar(name, false),
                          trailing: isUser ? _buildAvatar(name, true) : null,
                          title: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isUser ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: data["status"] == "inProgress"
                                ? const AnimatedDots()
                                : data["status"] == "sent"
                                    ? Text(data['text'])
                                    : Text(
                                        "エラーが発生しました",
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                          ),
                        ));
                  },
                );
              },
            ),
          ),
          if (_lastMessage != null && _lastMessage!.answerOptions != null)
            Column(
              children: _lastMessage!.answerOptions!.map((option) {
                return ElevatedButton(
                  onPressed: () {
                    _sendMessageFromOption(option);
                  },
                  child: Text(option),
                );
              }).toList(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    enabled: _lastMessage?.isReplyAllowed ?? false,
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'メッセージを入力',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
