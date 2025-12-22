import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/widgets/main_bottom_nav.dart';
import 'package:dobyob_1/screens/other_profile_screen.dart';

extension StringTitleCase on String {
  String toTitleCase() {
    if (trim().isEmpty) return '';
    return trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  String? myUserId;

  late TabController _tabController;

  bool loadingSuggestions = true;
  bool loadingRequests = true;

  List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final session = await DobYobSessionManager.getInstance();
    final uid = await session.getUserId();
    if (!mounted || uid == null) return;

    myUserId = uid.toString();
    await Future.wait([
      _loadSuggestions(),
      _loadRequests(),
    ]);
  }

  Future<void> _loadSuggestions() async {
    if (myUserId == null) return;
    setState(() => loadingSuggestions = true);
    final data = await _api.getPeopleSuggestions(myUserId!);
    if (!mounted) return;
    setState(() {
      suggestions = data;
      loadingSuggestions = false;
    });
  }

  Future<void> _loadRequests() async {
    if (myUserId == null) return;
    setState(() => loadingRequests = true);
    final data = await _api.getConnectionRequests(myUserId!);
    if (!mounted) return;
    setState(() {
      requests = data;
      loadingRequests = false;
    });
  }

  void _openProfileScreen(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtherProfileScreen(userId: userId),
      ),
    );
  }

  Future<void> _handleConnect(String otherUserId, int index) async {
    if (myUserId == null) return;
    final res = await _api.sendConnectionRequest(
      senderId: myUserId!,
      receiverId: otherUserId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? '')),
    );

    if (res['success'] == true) {
      setState(() {
        suggestions.removeAt(index);
      });
    }
  }

  Future<void> _handleRequestAction({
    required int index,
    required String connectionId,
    required String action,
  }) async {
    final res = await _api.respondToRequest(
      connectionId: connectionId,
      action: action,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? '')),
    );

    if (res['success'] == true) {
      setState(() {
        requests.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardColor = Color(0xFF020817);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text(
                    'My Network',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 38,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF020817),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Color(0xFF6B7280)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B7280),
          tabs: const [
            Tab(text: 'Grow'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
      body: myUserId == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSuggestionsTab(cardColor, borderColor, accent),
                _buildRequestsTab(cardColor, borderColor, accent),
              ],
            ),
    );
  }

  // ✅ GROW TAB - Working perfectly
  Widget _buildSuggestionsTab(Color cardColor, Color borderColor, Color accent) {
    if (loadingSuggestions) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
      );
    }
    if (suggestions.isEmpty) {
      return const Center(
        child: Text('No suggestions', style: TextStyle(color: Colors.white)),
      );
    }
    return RefreshIndicator(
      color: accent,
      onRefresh: _loadSuggestions,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: suggestions.length,
        itemBuilder: (context, i) {
          final u = suggestions[i];
          final String profilePic =
              DobYobSessionManager.resolveUrl(u['profile_pic']?.toString() ?? '');
          final String name = (u['full_name']?.toString() ?? '').toTitleCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: InkWell(
              onTap: () => _openProfileScreen(u['id'].toString()),
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: profilePic.isNotEmpty
                    ? CircleAvatar(
                        radius: 24,
                        backgroundColor: accent,
                        backgroundImage: NetworkImage(profilePic),
                      )
                    : CircleAvatar(
                        radius: 24,
                        backgroundColor: accent,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  u['city']?.toString() ?? '',
                  style: const TextStyle(color: Color(0xFF9CA3AF)),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  onPressed: () => _handleConnect(u['id'].toString(), i),
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ REQUESTS TAB - FULLY FIXED WITH ACTION BUTTONS
  Widget _buildRequestsTab(Color cardColor, Color borderColor, Color accent) {
    if (loadingRequests) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
      );
    }
    if (requests.isEmpty) {
      return const Center(
        child: Text('No requests', style: TextStyle(color: Colors.white)),
      );
    }
    return RefreshIndicator(
      color: accent,
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          final String profilePic =
              DobYobSessionManager.resolveUrl(r['profile_pic']?.toString() ?? '');
          final String senderId = r['sender_id']?.toString() ?? ''; // ✅ API मधील sender_id
          final String connectionId = r['connection_id']?.toString() ?? ''; // ✅ API मधील connection_id
          final String name = (r['full_name']?.toString() ?? '').toTitleCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: InkWell(
              onTap: senderId.isNotEmpty ? () => _openProfileScreen(senderId) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Profile Section - 80% width
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: accent,
                            backgroundImage: profilePic.isNotEmpty
                                ? NetworkImage(profilePic)
                                : null,
                            child: profilePic.isNotEmpty
                                ? null
                                : const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (r['city']?.toString().isNotEmpty == true)
                                  Text(
                                    r['city'].toString(),
                                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons - Right side
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reject Button
                        IconButton(
                          onPressed: connectionId.isNotEmpty
                              ? () => _handleRequestAction(
                                    index: i,
                                    connectionId: connectionId,
                                    action: 'reject',
                                  )
                              : null,
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(6),
                          ),
                          tooltip: 'Reject',
                        ),
                        const SizedBox(width: 8),
                        // Accept Button
                        IconButton(
                          onPressed: connectionId.isNotEmpty
                              ? () => _handleRequestAction(
                                    index: i,
                                    connectionId: connectionId,
                                    action: 'accept',
                                  )
                              : null,
                          icon: const Icon(Icons.check, color: Colors.white, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: accent,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(6),
                          ),
                          tooltip: 'Accept',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
