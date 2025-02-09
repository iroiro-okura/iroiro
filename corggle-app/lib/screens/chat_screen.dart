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

  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.chat == null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final uid = userProvider.user!.uid;

      await chatProvider.createNewChat(uid, "");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context);
    if (_chatProvider != chatProvider) {
      _chatProvider = chatProvider;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
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
          isReplyAllowed: false,
        ),
      );
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
          if (chatProvider.chat == null)
            const CircularProgressIndicator()
          else
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream:
                    FirestoreService.messageStream(chatProvider.chat!.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: AnimatedDots());
                  }

                  final messages = snapshot.data;
                  if (messages == null || messages.isEmpty) {
                    return const Center(child: Text('チャット履歴はありません。'));
                  }

                  _scrollToBottom();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: messages.length,
                          cacheExtent: 1000,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isUser = message.sender == Sender.user;
                            final status = message.status;

                            return Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: isUser
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  child: ListTile(
                                    titleAlignment: ListTileTitleAlignment.top,
                                    leading: isUser
                                        ? null
                                        : _buildAvatar(name, false, status),
                                    trailing: isUser
                                        ? _buildAvatar(name, true, null)
                                        : null,
                                    title: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? theme.colorScheme.primary
                                                .withAlpha(50)
                                            : theme.colorScheme.tertiary,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                          topLeft: isUser
                                              ? Radius.circular(10)
                                              : Radius.circular(0),
                                          topRight: isUser
                                              ? Radius.circular(0)
                                              : Radius.circular(10),
                                        ),
                                      ),
                                      child: message.status == Status.inProgress
                                          ? const AnimatedDots()
                                          : message.status == Status.completed
                                              ? Text(message.text)
                                              : Text(
                                                  "エラーが発生しました",
                                                  style: TextStyle(
                                                      color: theme
                                                          .colorScheme.error),
                                                ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (messages.last.answerOptions != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.center,
                            children:
                                messages.last.answerOptions!.map((option) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _sendMessageFromOption(option),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    foregroundColor:
                                        theme.colorScheme.onSecondary,
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
                    ],
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
