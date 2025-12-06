import 'package:flutter/material.dart';
 
class MainBottomNav extends StatelessWidget {
  final int currentIndex;
 
  const MainBottomNav({
    super.key,
    required this.currentIndex,
  });
 
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0EA5E9);
 
    return BottomNavigationBar(
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
        // 🚫 Prevent reloading the same active tab
        if (i == currentIndex) return;
 
        switch (i) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/network');
            break;
          case 2:
            Navigator.pushNamed(context, '/invite');
            break;
          case 3:
            Navigator.pushNamed(context, '/addpost');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}