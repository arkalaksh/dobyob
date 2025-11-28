import 'package:dobyob_1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  static const bgColor = Color(0xFF020617);
  static const cardColor = Color(0xFF020817);
  static const borderColor = Color(0xFF1F2937);
  static const accent = Color(0xFF0EA5E9);

  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allContacts = [];
  List<Map<String, String>> filteredContacts = [];

  bool isSending = false;
  bool isLoadingContacts = true;
  String userId = "5"; // TODO: actual logged‑in user id

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _loadDeviceContacts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContacts() async {
    // permission
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        isLoadingContacts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied')),
      );
      return;
    }

    // fetch contacts with properties (emails)
    final contacts =
        await FlutterContacts.getContacts(withProperties: true);

    final List<Map<String, String>> mapped = [];
    for (final c in contacts) {
      if (c.emails.isEmpty) continue; // invite साठी email हवा
      final name = c.displayName;
      for (final e in c.emails) {
        final email = e.address;
        if (email.isEmpty) continue;
        mapped.add({'name': name, 'email': email});
      }
    }

    if (!mounted) return;
    setState(() {
      allContacts
        ..clear()
        ..addAll(mapped);
      filteredContacts = List<Map<String, String>>.from(allContacts);
      isLoadingContacts = false;
    });
  }

  void _onSearchChanged() {
    final q = searchController.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        filteredContacts = List<Map<String, String>>.from(allContacts);
      } else {
        filteredContacts = allContacts
            .where((c) =>
                (c['name'] ?? '').toLowerCase().contains(q) ||
                (c['email'] ?? '').toLowerCase().contains(q))
            .toList();
      }
    });
  }

  Future<void> _sendInvite(Map<String, String> contact) async {
    final email = contact['email'] ?? '';
    final name = contact['name'] ?? '';
    if (email.isEmpty) return;

    setState(() => isSending = true);

    final res = await apiService.inviteFriend(
      userId: userId,
      friendName: name,
      friendEmail: email,
    );

    setState(() => isSending = false);

    final msg = res['message'] ??
        (res['success'] == true ? 'Invite sent' : 'Failed to send invite');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: searchController,
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
                  child: isLoadingContacts
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: accent,
                          ),
                        )
                      : filteredContacts.isEmpty
                          ? const Center(
                              child: Text(
                                'No contacts to show',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              itemCount: filteredContacts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final contact = filteredContacts[i];
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
                                      contact['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      contact['email'] ?? '',
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: isSending
                                            ? null
                                            : () => _sendInvite(contact),
                                        child: isSending
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
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
