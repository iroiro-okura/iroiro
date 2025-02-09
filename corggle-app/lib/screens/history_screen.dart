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
  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<UserProvider>(context, listen: false).user!.uid;

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
            return const Center(child: Text('チャット履歴はありません。'));
          }

          final chats = snapshot.data;
          if (chats == null || chats.isEmpty) {
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
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: Icon(Icons.chat,
                            color: Theme.of(context).colorScheme.primary),
                        title: Text(
                          DateFormat('yyyy/MM/dd HH:mm').format(chat.createdAt),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(chat.scene),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.secondary),
                        onTap: () {
                          final chatProvider =
                              Provider.of<ChatProvider>(context, listen: false);
                          chatProvider.getChat(chat.chatId);
                          chatProvider.setScene(chat.scene);
                          widget.controller
                              .jumpToTab(1); // Navigate to chat tab
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
