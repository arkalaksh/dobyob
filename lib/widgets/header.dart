import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const AppHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.yellow[700],
          radius: 36,
          child: Icon(icon, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
