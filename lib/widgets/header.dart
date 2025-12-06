import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;      // उदा. user चे नाव
  final String subtitle;   // उदा. email / tagline
  final String? photoUrl;  // प्रोफाइल फोटो URL (null / रिकामा असेल तर icon)

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.yellow[700],
          backgroundImage: hasPhoto ? NetworkImage(photoUrl!.trim()) : null,
          child: hasPhoto
              ? null
              : const Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.white,
                ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
