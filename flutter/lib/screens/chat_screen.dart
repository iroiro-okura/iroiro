import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        ),
      );
      // Remove this
      await Future.delayed(const Duration(seconds: 1));
      FirestoreService.sendMessage(
        targetChat!.chatId,
        Message(
          sender: Sender.corggle,
          text: "this is demo response from Corggle",
          status: Status.inProgress,
          sentAt: DateTime.now(),
        ),
      );
      _controller.clear();
    }
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
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final isUser = data['sender'] == 'user';

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: ListTile(
                        leading: isUser ? null : _buildAvatar(name, false),
                        trailing: isUser ? _buildAvatar(name, true) : null,
                        title: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: data["status"] == "inProgress"
                              ? const AnimatedDots()
                              : data["status"] == "sent"
                                  ? Text(data['text'])
                                  : Text(
                                      "エラーが発生しました",
                                      style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
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

/// 入力中アニメーション（ドットが増える）
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots> {
  int _dotCount = 1;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1; // 1 → 2 → 3 → 1
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '.' * _dotCount,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
