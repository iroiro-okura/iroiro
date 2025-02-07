import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
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
  final ScrollController _scrollController = ScrollController();
  Message? _lastMessage;
  ChatProvider? _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context);
    if (_chatProvider != chatProvider) {
      _chatProvider?.removeListener(_onChatArgumentChanged);
      _chatProvider = chatProvider;
      _chatProvider?.addListener(_onChatArgumentChanged);
    }
  }

  void _onChatArgumentChanged() {
    if (mounted) {
      setState(() {
        _lastMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _chatProvider?.removeListener(_onChatArgumentChanged);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() async {
    final targetChat = _chatProvider?.chat;
    if (_controller.text.isNotEmpty && targetChat?.chatId != null) {
      FirestoreService.sendMessage(
        targetChat!.chatId,
        Message(
            sender: Sender.user,
            text: _controller.text,
            status: Status.completed,
            sentAt: DateTime.now(),
            isReplyAllowed: false),
      );

      _controller.clear();
    }
  }

  void _sendMessageFromOption(String option) async {
    final targetChat = _chatProvider?.chat;
    if (targetChat?.chatId != null) {
      final chatId = targetChat!.chatId;
      FirestoreService.sendMessage(
        chatId,
        Message(
          sender: Sender.user,
          text: option,
          status: Status.completed,
          sentAt: DateTime.now(),
          isReplyAllowed: false,
        ),
      );
      setState(() {
        _lastMessage = null;
      });
    }
  }

  Widget _buildAvatar(String name, bool isUser, Status? status) {
    if (isUser) {
      return ClipOval(
        child: SvgPicture.string(
          RandomAvatarString(name),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        child: Image.asset(
          status == Status.inProgress
              ? 'assets/images/cogimi_thinking.png'
              : status == Status.failed
                  ? 'assets/images/cogimi_sad.png'
                  : 'assets/images/cogimi.png',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewChat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final uid = userProvider.user!.uid;

    chatProvider.createNewChat(uid, "");
    chatProvider.setScene("");
  }

  @override
  Widget build(BuildContext context) {
    final name = Provider.of<UserProvider>(context, listen: false).user!.name;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CorggleAppBar(),
      floatingActionButton: SizedBox(
          width: 30,
          height: 30,
          child: FloatingActionButton(
            onPressed: _startNewChat,
            child: const Icon(Icons.add),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Column(
        children: <Widget>[
          const Gap(20),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: FirestoreService.messageStream(chatProvider.chat.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: AnimatedDots());
                }

                final messages = snapshot.data;
                final lastMessage = messages!.last;
                logger.i('Last message: $lastMessage');

                if (_lastMessage == null ||
                    _lastMessage!.text != lastMessage.text) {
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {
                        _lastMessage = lastMessage;
                      });
                      _scrollToBottom();
                    }
                  });
                }

                return ListView.builder(
                  itemCount: messages.length,
                  cacheExtent: 1000,
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.sender == Sender.user;
                    final status = message.status;

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: ListTile(
                        leading:
                            isUser ? null : _buildAvatar(name, false, status),
                        trailing:
                            isUser ? _buildAvatar(name, true, null) : null,
                        title: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isUser
                                ? theme.colorScheme.primary.withAlpha(50)
                                : theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: message.status == Status.inProgress
                              ? const AnimatedDots()
                              : message.status == Status.completed
                                  ? Text(message.text)
                                  : Text(
                                      "エラーが発生しました",
                                      style: TextStyle(
                                          color: theme.colorScheme.error),
                                    ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_lastMessage != null && _lastMessage!.answerOptions != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: _lastMessage!.answerOptions!.map((option) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: ElevatedButton(
                      onPressed: () => _sendMessageFromOption(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        option,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    enabled: _lastMessage?.isReplyAllowed,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力',
                      hintStyle: TextStyle(color: theme.hintColor),
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
