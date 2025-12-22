import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dobyob_1/widgets/main_bottom_nav.dart';

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
  String userId = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _initUserAndContacts();
  }

  Future<void> _initUserAndContacts() async {
    final session = await DobYobSessionManager.getInstance();
    final uidInt = await session.getUserId();
    if (!mounted || uidInt == null) {
      setState(() => isLoadingContacts = false);
      return;
    }

    setState(() {
      userId = uidInt.toString();
    });

    await _loadDeviceContacts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContacts() async {
    final status = await Permission.contacts.status;

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      setState(() => isLoadingContacts = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contacts permission is permanently denied. Please enable it from Settings.',
          ),
        ),
      );
      await openAppSettings();
      return;
    }

    if (!status.isGranted) {
      final req = await Permission.contacts.request();
      if (!req.isGranted) {
        if (!mounted) return;
        setState(() => isLoadingContacts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied')),
        );
        return;
      }
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);

    final List<Map<String, String>> mapped = [];
    for (final c in contacts) {
      final name = c.displayName;

      String contactValue = '';
      String type = '';

      if (c.emails.isNotEmpty) {
        contactValue = c.emails.first.address;
        type = 'email';
      } else if (c.phones.isNotEmpty) {
        contactValue = c.phones.first.number;
        type = 'phone';
      }

      if (contactValue.isEmpty) continue;

      mapped.add({
        'name': name,
        'value': contactValue,
        'type': type,
      });
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
                (c['value'] ?? '').toLowerCase().contains(q))
            .toList();
      }
    });
  }

  Future<void> _sendInvite(Map<String, String> contact) async {
    if (userId.isEmpty) return;

    final value = contact['value'] ?? '';
    final name = contact['name'] ?? '';
    final type = contact['type'] ?? 'email';
    if (value.isEmpty) return;

    setState(() => isSending = true);

    final res = await apiService.inviteFriend(
      userId: userId,
      friendName: name,
      friendEmail: value,
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
       bottomNavigationBar: const MainBottomNav(currentIndex: 2), // tab index
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 60,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Row(
            children: [
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
                      prefixIcon:
                          const Icon(Icons.search, color: accent, size: 20),
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
                                final isEmail =
                                    (contact['type'] ?? '') == 'email';
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
                                      contact['value'] ?? '',
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
                                            : Text(
                                                isEmail ? "Invite" : "Share",
                                                style: const TextStyle(
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
