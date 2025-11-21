import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final String infoText;
  const AppFooter({super.key, required this.infoText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          infoText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
