import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.buttonTitle,
      required this.buttonStyle,
      required this.textStyle});

  final VoidCallback onPressed;
  final String buttonTitle;
  final ButtonStyle buttonStyle;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(
        buttonTitle,
        style: textStyle,
      ),
    );
  }
}
