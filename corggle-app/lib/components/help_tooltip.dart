import 'package:flutter/material.dart';

class HelpTooltip extends StatelessWidget {
  const HelpTooltip({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      height: 50,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontSize: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      triggerMode: TooltipTriggerMode.tap,
      enableFeedback: true,
      child: Icon(
        Icons.help,
        color: Theme.of(context).colorScheme.secondary,
        size: 24,
      ),
    );
  }
}
