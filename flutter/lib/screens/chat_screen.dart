import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late final String chatArgument;

  @override
  void initState() {
    super.initState();
    chatArgument = Provider.of<ChatProvider>(context, listen: false).argument;
    _messages.add({
      'sender': 'corggle',
      'text':
          'Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n今回は『$chatArgument』で話題を探しているんだね。\n最適な話題を見つけるためにも、お相手のことをもう少し教えてほしいな！'
    });

    _controller.addListener(() {
      setState(() {});
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'user', 'text': _controller.text});
        _controller.clear();
      });
      // Simulate receiving a message from Gemini API
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'sender': 'corggle',
            'text': 'This is a response from Gemini API'
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: CorggleAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ListTile(
                    leading: isUser
                        ? null
                        : ClipOval(
                            child: Image.asset(
                              'assets/images/cogimi.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                    trailing: isUser
                        ? ClipOval(
                            child: SvgPicture.string(
                              RandomAvatarString(user?.name ?? 'User'),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message['text']!,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
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
                  icon: Icon(
                    Icons.send,
                    color: _controller.text.isEmpty ? Colors.grey : Colors.blue,
                  ),
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
