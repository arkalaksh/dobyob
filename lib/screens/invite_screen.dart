import 'package:flutter/material.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {"name": "Alice Smith", "email": "alice@gmail.com"},
      {"name": "Bob Wilson", "email": "bob12@gmail.com"},
      {"name": "David Brown", "email": "db123@gmail.com"},
      {"name": "John Rk", "email": "john@gmail.com"},
      {"name": "Henry Taylor", "email": "taylor@gmail.com"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 10,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1, color: Color(0xFFF6C646)),
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
        currentIndex: 1,
        selectedItemColor: Color(0xFFF6C646),
        unselectedItemColor: Color(0xFFF6C646),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          // Only navigate if not already on InviteScreen
          if (i != 1) {
            if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            if (i == 2) Navigator.pushReplacementNamed(context, '/addpost');
            if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.person_add_alt_1, color: Color(0xFFF6C646), size: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Invite from Contacts',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Select friends to invite',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Contacts...",
                  hintStyle: const TextStyle(fontSize: 14),
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFF6C646)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFF6C646), width: 1.3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFF6C646), width: 1.8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFF6C646), width: 1.3),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: contacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final contact = contacts[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFF6C646),
                        child: Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(contact['email']!, style: const TextStyle(fontSize: 13)),
                      trailing: SizedBox(
                        height: 32,
                        width: 66,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6C646),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text("Invite", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
