import 'package:flutter/material.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  /// ✅ Optional: HomeShell/IndexedStack style tab switching
  final ValueChanged<int>? onTap;

  /// Optional: “Post” tab क्लिकवर custom action (screen push)
  final VoidCallback? onCreatePost;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0EA5E9);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF020817),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Network'),
        BottomNavigationBarItem(icon: Icon(Icons.person_add_alt), label: 'Invite'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: 'Post'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: accent,
      unselectedItemColor: const Color(0xFF6B7280),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (i) {
        if (i == currentIndex) return;

        // ✅ If parent callback provided (HomeShell), use it
        if (onTap != null) {
          if (i == 3) {
            onCreatePost?.call();
            return;
          }
          onTap!(i);
          return;
        }

        // ✅ Fallback: old behavior (route navigation)
        switch (i) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/network');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/invite');
            break;
          case 3:
            Navigator.pushNamed(context, '/addpost');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
    );
  }
}
