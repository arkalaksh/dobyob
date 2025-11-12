import 'package:flutter/material.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.facebook),
          color: Colors.blue,
          iconSize: 32,
        ),
        SizedBox(width: 16),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.alternate_email),
          color: Colors.lightBlue,
          iconSize: 32,
        ),
      ],
    );
  }
}
