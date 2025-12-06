import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ ADD THIS
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';

class OtherProfileScreen extends StatefulWidget {
  final String userId;

  const OtherProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final ApiService _api = ApiService();

  String? viewerId;
  Map<String, dynamic>? userData;
  bool loading = true;
  bool actionLoading = false;

  static const String _baseUrl = 'https://dobyob.arkalaksh.com';

  String? _fullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$_baseUrl/${path.trim()}';
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await DobYobSessionManager.getInstance();
    final id = await session.getUserId();
    viewerId = id?.toString();

    if (viewerId == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (viewerId == null) return;
    setState(() => loading = true);

    final data = await _api.getUserProfile(
      userId: widget.userId,
      viewerId: viewerId!,
    );

    if (!mounted) return;
    setState(() {
      userData = data;
      loading = false;
    });
  }

  Future<void> _handleConnect() async {
    if (viewerId == null || userData == null) return;

    setState(() => actionLoading = true);

    final res = await _api.sendConnectionRequest(
      senderId: viewerId!,
      receiverId: widget.userId,
    );

    if (!mounted) return;
    setState(() => actionLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? '')),
    );

    if (res['success'] == true) {
      setState(() {
        userData!['connection_status'] = 'pending';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF020617);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            )
          : (userData == null
              ? const Center(
                  child: Text(
                    'User not found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : _buildBody()),
    );
  }

  Widget _buildBody() {
    const accent = Color(0xFF0EA5E9);
    const cardBg = Color(0xFF020617);
    const borderColor = Color(0xFF1F2937);

    final u = userData!;
    final String name = (u['full_name'] ?? '').toString();
    final String profession = (u['profession'] ?? '').toString();
    final String business = (u['business'] ?? '').toString();
    final String headline =
        [business, profession].where((e) => e.trim().isNotEmpty).join(' · ');
    final String location = [
      if ((u['city'] ?? '').toString().isNotEmpty) u['city'],
      if ((u['state'] ?? '').toString().isNotEmpty) u['state'],
      if ((u['country'] ?? '').toString().isNotEmpty) u['country'],
    ].whereType<String>().join(", ");

    final String? pic = _fullImageUrl(u['profile_pic']?.toString());

    final String industry = (u['industry'] ?? '').toString();
    final String email = (u['email'] ?? '').toString();
    final String phone = (u['phone'] ?? '').toString();
    final String dobRaw = (u['date_of_birth'] ?? '').toString();

    // ✅ Format DOB as dd-MM-yyyy
    String dobDisplay = '';
    if (dobRaw.isNotEmpty && dobRaw != '0000-00-00') {
      try {
        final d = DateTime.parse(dobRaw); // expects yyyy-MM-dd
        dobDisplay = DateFormat('dd-MM-yyyy').format(d);
      } catch (_) {
        dobDisplay = dobRaw;
      }
    }

    final String address = (u['address'] ?? '').toString();
    final String education = (u['education'] ?? '').toString();
    final String positions = (u['positions'] ?? '').toString();

    final String connectionStatus =
        (u['connection_status'] ?? '').toString();

    String buttonText;
    bool buttonEnabled = true;

    if (connectionStatus == 'accepted') {
      buttonText = 'Message';
      buttonEnabled = true;
    } else if (connectionStatus == 'pending') {
      buttonText = 'Pending';
      buttonEnabled = false;
    } else {
      buttonText = 'Connect';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAIN CARD
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // avatar + name/prof/location
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFF1F2937),
                        backgroundImage:
                            (pic != null) ? NetworkImage(pic) : null,
                        child: (pic == null)
                            ? const Icon(Icons.person,
                                size: 34, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (headline.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  headline,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            if (location.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // phone + DOB (email hidden)
                if (phone.isNotEmpty || dobDisplay.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (phone.isNotEmpty)
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        if (dobDisplay.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              "DOB: $dobDisplay", // ✅ dd-MM-yyyy
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: actionLoading
                        ? null
                        : () {
                            if (connectionStatus == 'accepted') {
                              // TODO: open chat
                            } else if (buttonEnabled) {
                              _handleConnect();
                            }
                          },
                    child: actionLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ABOUT card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                if (industry.isNotEmpty) _detailRow('Industry', industry),
                if (education.isNotEmpty) _detailRow('Education', education),
                if (positions.isNotEmpty) _detailRow('Role', positions),
                if (address.isNotEmpty) _detailRow('Address', address),
                if (industry.isEmpty &&
                    education.isEmpty &&
                    positions.isEmpty &&
                    address.isEmpty)
                  const Text(
                    'No additional details.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
