import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:flutter/services.dart';

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

  String capitalizeName(String name) {
    if (name.isEmpty) return name;
    return name
        .trim()
        .split(" ")
        .where((e) => e.trim().isNotEmpty)
        .map((word) =>
            word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : ""))
        .join(" ");
  }

  String? _fullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$_baseUrl/${path.trim()}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final session = await DobYobSessionManager.getInstance();
    final id = await session.getUserId();
    viewerId = id?.toString();

    if (!mounted) return;
    if (viewerId == null) {
      setState(() => loading = false);
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

  /// ✅ Popup for Coming Soon
  Future<void> _showComingSoonPopup() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Coming soon',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This functionality is coming soon.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF0EA5E9))),
          ),
        ],
      ),
    );
  }

  /// Connect / Withdraw only (Unfriend is in 3-dots bottom sheet)
  Future<void> _handlePrimaryAction() async {
    if (viewerId == null || userData == null) return;

    final status = (userData!['connection_status'] ?? '').toString();
    final connectionId = (userData!['connection_id'] ?? '').toString();

    setState(() => actionLoading = true);

    Map<String, dynamic> res;

    if (status == 'pending') {
      if (connectionId.isEmpty) {
        res = {"success": false, "message": "Missing connection_id"};
      } else {
        res = await _api.cancelConnectionRequest(connectionId: connectionId);
      }
    } else {
      res = await _api.sendConnectionRequest(
        senderId: viewerId!,
        receiverId: widget.userId,
      );
    }

    if (!mounted) return;
    setState(() => actionLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? '')),
    );

    if (res['success'] == true) {
      setState(() {
        if (status == 'pending') {
          userData!['connection_status'] = '';
          userData!.remove('connection_id');
        } else {
          userData!['connection_status'] = 'pending';
        }
      });
      await _loadProfile();
    }
  }
/// Remove connection action (called after tapping option from bottom sheet)
Future<void> _handleUnfriend() async {
  if (userData == null) return;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text(
        'Remove connection',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Are you sure you want to remove this connection?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Remove',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final connectionId = (userData!['connection_id'] ?? '').toString();
  if (connectionId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Missing connection_id')),
    );
    return;
  }

  setState(() => actionLoading = true);

  final res = await _api.unfriendUser(connectionId: connectionId);

  if (!mounted) return;
  setState(() => actionLoading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(res['message']?.toString() ?? 'Connection removed'),
    ),
  );

  if (res['success'] == true) {
    setState(() {
      userData!['connection_status'] = '';
      userData!.remove('connection_id');
    });
    await _loadProfile();
  }
}

  /// ✅ LinkedIn-style bottom sheet menu for 3-dots
  void _openMoreActionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1220),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_remove, color: Colors.white),
                  title: const Text('Remove connection', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _handleUnfriend();
                    });
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.white),
                  title: const Text('Report or block', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF020617);

    // 🔥 PERFECT SMOOTH NAVIGATION - Single AnnotatedRegion
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF020617),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          automaticallyImplyLeading: false, // 🔥 Prevents conflicts
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)))
            : (userData == null
                ? const Center(
                    child: Text('User not found', style: TextStyle(color: Colors.white70)),
                  )
                : _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    const accent = Color(0xFF0EA5E9);
    const cardBg = Color(0xFF020617);
    const borderColor = Color(0xFF1F2937);

    final u = userData!;

    final String name = capitalizeName((u['full_name'] ?? '').toString());

    final String profession = (u['profession'] ?? '').toString();
    final String business = (u['business'] ?? '').toString();
    final String headline = [business, profession].where((e) => e.trim().isNotEmpty).join(' · ');

    final String location = [
      if ((u['city'] ?? '').toString().isNotEmpty) u['city'],
      if ((u['state'] ?? '').toString().isNotEmpty) u['state'],
      if ((u['country'] ?? '').toString().isNotEmpty) u['country'],
    ].whereType<String>().join(", ");

    final String? pic = _fullImageUrl(u['profile_pic']?.toString());

    final String industry = (u['industry'] ?? '').toString();
    final String dobRaw = (u['date_of_birth'] ?? '').toString();

    String dobDisplay = '';
    if (dobRaw.isNotEmpty && dobRaw != '0000-00-00') {
      try {
        final d = DateTime.parse(dobRaw);
        dobDisplay = DateFormat('dd-MM-yyyy').format(d);
      } catch (_) {
        dobDisplay = dobRaw;
      }
    }

    final String address = (u['address'] ?? '').toString();
    final String education = (u['education'] ?? '').toString();
    final String positions = (u['positions'] ?? '').toString();

    final String connectionStatus = (u['connection_status'] ?? '').toString();
    final bool isConnected = connectionStatus == 'accepted';
    final bool showPrivateInfo = isConnected;

    String buttonText = 'Connect';
    Color buttonColor = accent;
    if (connectionStatus == 'pending') {
      buttonText = 'Withdraw';
      buttonColor = const Color(0xFF10B981);
    } else {
      buttonText = 'Connect';
      buttonColor = accent;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HERO ANIMATION - Matches NetworkScreen tags
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔥 HERO TAG - Perfect match with NetworkScreen
                      Hero(
                        tag: 'profile_${widget.userId}',
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: const Color(0xFF1F2937),
                          backgroundImage: (pic != null) ? NetworkImage(pic) : null,
                          child: (pic == null)
                              ? const Icon(Icons.person, size: 34, color: Colors.white54)
                              : null,
                        ),
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
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: isConnected
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showComingSoonPopup,
                                icon: const Icon(Icons.message, size: 20),
                                label: const Text(
                                  'Message',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: _openMoreActionsSheet,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                                ),
                                child: const Icon(
                                  Icons.more_horiz,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: actionLoading ? null : _handlePrimaryAction,
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

                if (showPrivateInfo && industry.isNotEmpty) _detailRow('Industry', industry),
                if (showPrivateInfo && education.isNotEmpty) _detailRow('Education', education),
                if (showPrivateInfo && positions.isNotEmpty) _detailRow('Role', positions),
                if (showPrivateInfo && address.isNotEmpty) _detailRow('Address', address),

                if (!showPrivateInfo)
                  const Text(
                    'Connect to see more details.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  )
                else if (industry.isEmpty && education.isEmpty && positions.isEmpty && address.isEmpty)
                  const Text(
                    'No additional details.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
              ],
            ),
          ),

          if (dobDisplay.isNotEmpty && false)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(dobDisplay, style: const TextStyle(color: Colors.white54)),
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
          )
        ],
      ),
    );
  }
}
