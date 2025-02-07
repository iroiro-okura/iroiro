import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/model/chat.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:iroiro/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Stream<QuerySnapshot> _chatsStream;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeHistory();
      _isInitialized = true;
    }
  }

  void _initializeHistory() {
    final uid = Provider.of<UserProvider>(context, listen: false).user!.uid;
    _chatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CorggleAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('チャット履歴はありません。'));
          }

          final chats =
              snapshot.data!.docs.map((doc) => Chat.fromDocument(doc)).toList();

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
                },
              );
            },
          );
        },
      ),
    );
  }
}
