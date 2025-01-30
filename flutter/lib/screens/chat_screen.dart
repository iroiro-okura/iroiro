import 'package:flutter/material.dart';
import 'package:iroiro/main.dart';
import 'package:provider/provider.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = Provider.of<ChatArgumentsProvider>(context).argument;

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
          onPressed: null,
          icon: Image.asset('assets/icon/icon_transparent.png'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              argument.isNotEmpty ? argument : '普通のチャット',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
