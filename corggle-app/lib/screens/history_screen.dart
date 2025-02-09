import 'package:flutter/material.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/chat.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final PersistentTabController controller;
  const HistoryScreen({super.key, required this.controller});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final uid = Provider.of<UserProvider>(context, listen: false).user!.uid;
    final chats = await FirestoreService.getAllChats(uid);
    setState(() {
      _chats = chats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<UserProvider>(context, listen: false).user!.uid;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
        appBar: CorggleAppBar(),
        body: StreamBuilder<List<Chat>>(
          stream: FirestoreService.chatStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ));
            }

            final chats = snapshot.data ?? _chats;
            if (chats.isEmpty) {
              return const Center(child: Text('チャット履歴はありません。'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'チャット履歴: ${chats.length}件',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: Icon(Icons.chat,
                              color: Theme.of(context).colorScheme.secondary),
                          title: Text(
                            chat.title ?? 'Untitled',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy/MM/dd HH:mm')
                                    .format(chat.createdAt),
                              ),
                              if (chat.scene != "")
                                Text(
                                  chat.scene,
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('確認'),
                                    content: const Text('このチャットを削除しますか？'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('キャンセル'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('削除'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                chatProvider.deleteChat(chat.chatId);
                              }
                            },
                          ),
                          onTap: () async {
                            final chatProvider = Provider.of<ChatProvider>(
                                context,
                                listen: false);
                            await chatProvider.getChat(chat.chatId);
                            chatProvider.setScene(chat.scene);
                            widget.controller
                                .jumpToTab(1); // Navigate to chat tab
                          },
                        ),
                      );
                    },
                  ),
                )),
              ],
            );
          },
        ));
  }
}
