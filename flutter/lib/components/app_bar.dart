import 'package:flutter/material.dart';

class CorggleAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  const CorggleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
}
