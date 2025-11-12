import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1, color: Color(0xFFF6C646)), // Invite Friends
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFFF6C646)),
            label: '',
          ),
        ],
        currentIndex: 3, // Profile tab is selected
        selectedItemColor: Color(0xFFF6C646),
        unselectedItemColor: Color(0xFFF6C646),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/invite'); // Invite tab
          // i == 2 is your future post/add icon
          // i == 3 is profile tab -- already here
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF1D1C61),
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 47,
                      backgroundColor: const Color(0xFFF6C646),
                      child: const Icon(Icons.person_outline, size: 70, color: Colors.white),
                    ),
                    Positioned(
                      right: 3,
                      bottom: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFFF6C646), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(3.5),
                        child: const Icon(Icons.camera_alt, color: Color(0xFFF6C646), size: 19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Date Of Birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6C646),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Saved (dummy)!")),
                      );
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
