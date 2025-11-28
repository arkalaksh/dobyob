import 'package:flutter/material.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardColor = Color(0xFF020817);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    final contacts = [
      {"name": "Alice Smith", "email": "alice@gmail.com"},
      {"name": "Bob Wilson", "email": "bob12@gmail.com"},
      {"name": "David Brown", "email": "db123@gmail.com"},
      {"name": "John Rk", "email": "john@gmail.com"},
      {"name": "Henry Taylor", "email": "taylor@gmail.com"},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 20,
                backgroundColor: accent,
                child: Icon(Icons.person_add_alt_1,
                    color: Colors.white, size: 22),
              ),
              SizedBox(width: 10),
              Text(
                'Invite from Contacts',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF020817),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 1,
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xFF6B7280),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i != 1) {
            if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            if (i == 2) Navigator.pushReplacementNamed(context, '/addpost');
            if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 8),
                  child: Text(
                    'Select friends to invite',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: accent,
                    decoration: InputDecoration(
                      hintText: "Search Contacts...",
                      hintStyle: const TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280)),
                      isDense: true,
                      prefixIcon: const Icon(Icons.search,
                          color: accent, size: 20),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: borderColor, width: 1.3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: borderColor, width: 1.3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: accent, width: 1.8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final contact = contacts[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            radius: 22,
                            backgroundColor: accent,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 22),
                          ),
                          title: Text(
                            contact['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            contact['email']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          trailing: SizedBox(
                            height: 32,
                            width: 76,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // TODO: send invite
                              },
                              child: const Text(
                                "Invite",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
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
        ),
      ),
    );
  }
}
