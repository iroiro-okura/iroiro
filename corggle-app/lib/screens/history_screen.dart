import 'package:flutter/material.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/chat.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('チャット履歴はありません。'));
          }

          final chats = snapshot.data;
          if (chats == null || chats.isEmpty) {
            return const Center(child: Text('チャット履歴はありません。'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                title: Text(chat.createdAt.toString()),
                subtitle: Text(chat.scene),
                onTap: () {
                  final chatProvider =
                      Provider.of<ChatProvider>(context, listen: false);
                  chatProvider.getChat(chat.chatId);
                  chatProvider.setScene(chat.scene);
                  widget.controller.jumpToTab(1); // Navigate to chat tab
                },
              );
            },
          );
        },
      ),
    );
  }
}
