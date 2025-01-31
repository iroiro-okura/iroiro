import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'gemini',
      'text':
          'Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n今回は『はじめてのデート』で話題を探しているんだね。\n最適な話題を見つけるためにも、お相手のことをもう少し教えてほしいな！'
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
            'sender': 'gemini',
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
      appBar: AppBar(
        title: const Text('Corggle'),
        titleTextStyle: TextStyle(
          fontFamily: 'Alexandria',
          fontSize: 20,
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
        titleSpacing: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(11),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/icon/icon_transparent.png'),
        ),
      ),
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
