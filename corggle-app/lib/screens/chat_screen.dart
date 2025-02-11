import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:iroiro/components/animation_dot.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/chat.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:iroiro/screens/error_screen.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _optionsHeight = 100.0;

  ChatProvider? _chatProvider;
  String? _failedMessage;

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

  void _retrySendMessage() async {
    if (_failedMessage != null) {
      final targetChat = _chatProvider?.chat;
      if (targetChat?.chatId != null) {
        try {
          await FirestoreService.sendMessage(
            targetChat!.chatId,
            Message(
                sender: Sender.user,
                text: _failedMessage!,
                status: Status.completed,
                isReplyAllowed: false),
          );
          setState(() {
            _failedMessage = null;
          });
        } catch (e) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ErrorScreen(errorMessage: "チャット中のエラー"),
              ),
            );
          }
        }
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + _optionsHeight,
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '新しいチャットを開始',
            style: TextStyle(fontSize: 18),
          ),
          content: const Text('シーンを選択してください。'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await chatProvider.createNewChat(uid, "");
                chatProvider.setScene("");
              },
              child: const Text('フリートーク'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await chatProvider.createNewChat(uid, dating);
                chatProvider.setScene(dating);
              },
              child: const Text(dating),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await chatProvider.createNewChat(uid, reunion);
                chatProvider.setScene(reunion);
              },
              child: const Text(reunion),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await chatProvider.createNewChat(uid, companyGathering);
                chatProvider.setScene(companyGathering);
              },
              child: const Text(companyGathering),
            ),
          ],
        );
      },
    );
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    logger.d(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  List<TextSpan> _buildTextSpans(String text) {
    final RegExp markdownRegExp = RegExp(
      r"(\*\*(.*?)\*\*)" // **太字**
      r"|(\*(.*?)\*)" // *斜体*
      r"|(`(.*?)`)" // `コード`
      r"|\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)" // [リンクテキスト](URL)
      r"|(https?:\/\/[a-zA-Z0-9.-]+(?:\/[a-zA-Z0-9-._~:/?#[\]@!$&'()*+,;=]*)?)", // 通常のURL
      caseSensitive: false,
      multiLine: true,
    );

    final List<TextSpan> spans = [];
    final matches = markdownRegExp.allMatches(text);

    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      if (match.group(2) != null) {
        // **太字**
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(4) != null) {
        // *斜体*
        spans.add(TextSpan(
          text: match.group(4),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(6) != null) {
        // `コード`
        spans.add(TextSpan(
          text: match.group(6),
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.withAlpha(20),
          ),
        ));
      } else if (match.group(7) != null && match.group(8) != null) {
        // [リンクテキスト](URL)
        final linkText = match.group(7)!;
        final url = match.group(8)!;
        spans.add(
          TextSpan(
            text: linkText,
            style: const TextStyle(
                color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
          ),
        );
      } else if (match.group(9) != null) {
        // 通常のURL
        final url = match.group(9)!;
        spans.add(
          TextSpan(
            text: url,
            style: const TextStyle(
                color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final name = Provider.of<UserProvider>(context, listen: false).user!.name;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CorggleAppBar(),
      floatingActionButton: SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
            onPressed: _startNewChat,
            backgroundColor: theme.colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.add_comment_rounded,
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Column(
        children: <Widget>[
          const Gap(20),
          if (chatProvider.chat == null)
            const Center(child: Text('チャット履歴はありません。'))
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
                    return const Center(child: CircularProgressIndicator());
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

                            if (message.status == Status.failed) {
                              final userMessages = messages
                                  .where((msg) => msg.sender == Sender.user)
                                  .toList();
                              if (userMessages.isNotEmpty) {
                                _failedMessage = userMessages.last.text;
                              } else {
                                _failedMessage = "";
                              }
                            }
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
                                              ? SelectableText.rich(
                                                  TextSpan(
                                                    children: _buildTextSpans(
                                                        message.text),
                                                  ),
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "エラーが発生しました",
                                                      style: TextStyle(
                                                          color: theme
                                                              .colorScheme
                                                              .error),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          _retrySendMessage,
                                                      child: Text(
                                                        "リトライ",
                                                        style: TextStyle(
                                                            color: theme
                                                                .colorScheme
                                                                .primary),
                                                      ),
                                                    ),
                                                  ],
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
                        StatefulBuilder(builder: (context, setState) {
                          return Column(
                            children: [
                              GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  setState(() {
                                    _optionsHeight -= details.delta.dy;
                                    if (_optionsHeight < 50) {
                                      _optionsHeight = 50;
                                    } else if (_optionsHeight > 150) {
                                      _optionsHeight = 150;
                                    }
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 14,
                                      width: MediaQuery.of(context).size.width,
                                      color: theme.colorScheme.tertiary
                                          .withAlpha(70),
                                      child: Center(
                                        child: Container(
                                          height: 4,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.tertiary,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    SizedBox(
                                      height: _optionsHeight,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Wrap(
                                                spacing: 4.0,
                                                runSpacing: 4.0,
                                                alignment: WrapAlignment.start,
                                                children: messages
                                                    .last.answerOptions!
                                                    .map((option) {
                                                  return ElevatedButton(
                                                    onPressed: () =>
                                                        _sendMessageFromOption(
                                                            option),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: theme
                                                          .colorScheme
                                                          .secondary,
                                                      foregroundColor: theme
                                                          .colorScheme
                                                          .onSecondary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 8),
                                                    ),
                                                    child: Text(
                                                      option,
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: theme.colorScheme
                                                            .onSecondary,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
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
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
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
