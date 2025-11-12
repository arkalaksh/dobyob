import 'package:flutter/material.dart';
import 'social_buttons.dart';

class AppFooter extends StatelessWidget {
  final String infoText;
  const AppFooter({super.key, required this.infoText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(infoText),
        const SizedBox(height: 8),
        const SocialButtons(),
      ],
    );
  }
}
