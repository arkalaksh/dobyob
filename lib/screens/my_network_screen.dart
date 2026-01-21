import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/screens/other_profile_screen.dart';

extension StringTitleCase on String {
  String toTitleCase() {
    if (trim().isEmpty) return '';
    return trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class NetworkScreen extends StatefulWidget {
  final VoidCallback? onBackToFeed;
  const NetworkScreen({super.key, this.onBackToFeed});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  String? myUserId;

  late final TabController _tabController;

  // Lists
  bool loadingPending = true;
  bool loadingSuggestions = true;
  bool loadingRequests = true;

  List<Map<String, dynamic>> pendingConnections = [];
  List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> requests = [];

  // Search
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  bool searching = false;
  List<Map<String, dynamic>> searchResults = [];

  // ✅ AUTO REFRESH TIMER REMOVED ✅

  // Pagination
  static const int _limit = 20;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  final ScrollController _growScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _growScroll.addListener(_onGrowScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF020617),
          statusBarIconBrightness: Brightness.light,
        ),
      );
      _loadUserAndData();
    });
  }

  Future<void> _loadUserAndData() async {
    final session = await DobYobSessionManager.getInstance();
    final uid = await session.getUserId();
    if (!mounted || uid == null) return;

    setState(() => myUserId = uid.toString());

    await Future.wait([
      _loadRequests(),
      _loadPendingConnections(),
      _loadSuggestions(reset: true),
    ]);

    // ✅ AUTO REFRESH REMOVED - No _startAutoRefresh() call
  }

  // ✅ _startAutoRefresh() METHOD COMPLETELY DELETED ✅

  Future<void> _refreshGrow() async {
    await Future.wait([
      _loadPendingConnections(),
      _loadSuggestions(reset: true),
    ]);
  }

  Future<void> _loadSuggestions({
  required bool reset,
  bool silent = false,
}) async {
  if (myUserId == null) return;

  if (!silent) {
    setState(() => loadingSuggestions = true);
  }

  if (reset) {
    _page = 1;
    _hasMore = true;
    _loadingMore = false;
    suggestions.clear();
  }

  final res = await _api.getPeopleSuggestions(
    userId: myUserId!,
    page: _page,
    limit: _limit,
  );

  if (!mounted) return;

  if (res['success'] != true) {
    debugPrint('❌ Suggestions failed: ${res['message'] ?? res['error']}');
    if (!silent) {
      setState(() => loadingSuggestions = false);
    }
    return;
  }

  final List<Map<String, dynamic>> list =
      List<Map<String, dynamic>>.from(res['suggestions'] ?? []);

  final bool serverHasMore = res['has_more'] == true;

  setState(() {
    if (reset) {
      suggestions = list;
    } else {
      suggestions.addAll(list);
    }

    _hasMore = serverHasMore && list.length == _limit;
    loadingSuggestions = false;
    _loadingMore = false;
  });

  // 🔥 THIS IS THE ONLY CHANGE NEEDED!
  if (!reset) _page++; // Next page for infinite scroll

  debugPrint(
    '✅ Loaded page $_page | Total=${suggestions.length} | hasMore=$_hasMore',
  );
}

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    if (myUserId == null) return;

    setState(() => _loadingMore = true);
    _page++;

    await _loadSuggestions(reset: false, silent: true);

    if (!mounted) return;
    setState(() => _loadingMore = false);
  }

  void _onGrowScroll() {
    if (!_growScroll.hasClients) return;
    if (_loadingMore || !_hasMore) return;

    final pos = _growScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      _loadMore();
    }
  }

  Set<String> _excludedUserIds() {
    final Set<String> ids = {};
    if (myUserId != null) ids.add(myUserId!);

    for (final p in pendingConnections) {
      final fid = p['friend_id']?.toString() ?? '';
      if (fid.isNotEmpty) ids.add(fid);
    }

    for (final r in requests) {
      final sid = r['sender_id']?.toString() ?? '';
      if (sid.isNotEmpty) ids.add(sid);
    }

    return ids;
  }

  Future<void> _loadRequests({bool silent = false}) async {
    if (myUserId == null) return;
    if (!silent) setState(() => loadingRequests = true);

    final data = await _api.getConnectionRequests(myUserId!);
    if (!mounted) return;

    setState(() {
      requests = data;
      loadingRequests = false;
    });
  }

  Future<void> _loadPendingConnections({bool silent = false}) async {
    if (myUserId == null) return;
    if (!silent) setState(() => loadingPending = true);

    final data = await _api.getPendingConnections(myUserId!);
    if (!mounted) return;

    setState(() {
      pendingConnections = data;
      loadingPending = false;
    });
  }

  void _openProfileScreen(String userId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtherProfileScreen(userId: userId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        opaque: false,
        barrierColor: Colors.black54,
      ),
    ).then((_) {
      if (mounted) {
        _refreshGrow();
      }
    });
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
        if (index >= 0 && index < suggestions.length) {
          suggestions.removeAt(index);
        }
        searchResults.removeWhere((u) => u['id']?.toString() == otherUserId);
      });

      await _loadPendingConnections();
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
        if (index >= 0 && index < requests.length) {
          requests.removeAt(index);
        }
      });

      await _refreshGrow();
    }
  }

  Future<void> _withdrawPending({
    required int index,
    required Map<String, dynamic> pendingRow,
  }) async {
    final connectionId = pendingRow['connection_id']?.toString() ?? '';
    if (connectionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing connection_id in pending list')),
      );
      return;
    }

    final res = await _api.cancelConnectionRequest(connectionId: connectionId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? '')),
    );

    if (res['success'] == true) {
      setState(() {
        if (index >= 0 && index < pendingConnections.length) {
          pendingConnections.removeAt(index);
        }
      });

      await _loadSuggestions(reset: true);
    }
  }

  void _onSearchChanged(String value) {
    final q = value.trim();
    _searchDebounce?.cancel();

    if (q.length < 2) {
      setState(() {
        searching = false;
        searchResults.clear();
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    if (myUserId == null) return;

    setState(() => searching = true);

    final data = await _api.searchUsers(
      currentUserId: myUserId!,
      query: query,
    );
    if (!mounted) return;

    final excluded = _excludedUserIds();
    final filtered = data.where((u) {
      final id = u['id']?.toString() ?? '';
      return id.isNotEmpty && !excluded.contains(id);
    }).toList();

    setState(() {
      searchResults = filtered;
      searching = false;
    });
  }

  void _goFeed() {
    if (widget.onBackToFeed != null) {
      widget.onBackToFeed!();
      return;
    }
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    // ✅ AUTO REFRESH TIMER CANCEL REMOVED ✅
    _growScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardColor = Color(0xFF020817);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF020617),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goFeed,
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
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: Color(0xFF6B7280), size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Color(0xFF6B7280)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {
                              searchResults.clear();
                              searching = false;
                            });
                          },
                          child: const Icon(Icons.close,
                              color: Colors.white70, size: 18),
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
            splashFactory: NoSplash.splashFactory,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: const [
              Tab(text: 'Grow'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: myUserId == null
            ? const Center(child: CircularProgressIndicator(color: accent))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildGrowTab(cardColor, borderColor, accent),
                  _buildRequestsTab(cardColor, borderColor, accent),
                ],
              ),
      ),
    );
  }

  // ✅ ALL BUILD METHODS SAME AS ORIGINAL ✅
  Widget _buildAvatar({
    required String profilePic,
    required Color accent,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent,
      ),
      child: profilePic.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                profilePic,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, color: Colors.white, size: 24),
              ),
            )
          : Icon(Icons.person, color: Colors.white, size: 24),
    );
  }
Widget _buildGrowTab(Color cardColor, Color borderColor, Color accent) {
  if (loadingSuggestions || loadingPending) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
    );
  }

  final bool isSearchMode = _searchCtrl.text.trim().length >= 2;
  final list = isSearchMode ? searchResults : suggestions;
  final bool isEmptyAll = pendingConnections.isEmpty && list.isEmpty;

  return RefreshIndicator(
    color: accent,
    onRefresh: _refreshGrow,
    displacement: 40, // Pull indicator को थोड़ा ऊपर लाने के लिए
    child: CustomScrollView(
      controller: _growScroll,
      physics: const AlwaysScrollableScrollPhysics(), // 🔧 यह line add करो!
      slivers: [
        // Pending connections section
        if (!isSearchMode && pendingConnections.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${pendingConnections.length} Pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  pendingConnections.length,
                  (i) => _buildPendingCard(
                    pendingConnections[i],
                    i,
                    cardColor,
                    borderColor,
                    accent,
                  ),
                ),
              ],
            ),
          ),

        // Title section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isSearchMode
                  ? 'Search Results (${searchResults.length})'
                  : 'Suggestions (${suggestions.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Search loading
        if (isSearchMode && searching)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
              ),
            ),
          ),

        // Empty state
        if (isEmptyAll)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No suggestions right now.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),

        // Main list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              if (i >= list.length) {
                if (!isSearchMode && _loadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF0EA5E9)),
                    ),
                  );
                }
                return null;
              }

              return _buildSuggestionCard(
                list[i],
                i,
                cardColor,
                borderColor,
                accent,
              );
            },
            childCount: list.length + ((!isSearchMode && _loadingMore) ? 1 : 0),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPendingCard(
    Map<String, dynamic> p,
    int index,
    Color cardColor,
    Color borderColor,
    Color accent,
  ) {
    final String profilePic =
        DobYobSessionManager.resolveUrl(p['profile_pic']?.toString() ?? '');
    final String name = (p['full_name']?.toString() ?? '').toTitleCase();
    final String friendId = p['friend_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: friendId.isNotEmpty ? () => _openProfileScreen(friendId) : null,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: SizedBox(
            width: 48,
            height: 48,
            child: _buildAvatar(
              profilePic: profilePic,
              accent: accent,
            ),
          ),
          title: Text(
            name,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            p['city']?.toString() ?? '',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _withdrawPending(index: index, pendingRow: p),
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(6),
                ),
                tooltip: 'Withdraw',
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty,
                        size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Pending',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(
    Map<String, dynamic> u,
    int index,
    Color cardColor,
    Color borderColor,
    Color accent,
  ) {
    final String profilePic =
        DobYobSessionManager.resolveUrl(u['profile_pic']?.toString() ?? '');
    final String name = (u['full_name']?.toString() ?? '').toTitleCase();
    final String id = u['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: id.isNotEmpty ? () => _openProfileScreen(id) : null,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: SizedBox(
            width: 48,
            height: 48,
            child: _buildAvatar(
              profilePic: profilePic,
              accent: accent,
            ),
          ),
          title: Text(
            name,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            u['city']?.toString() ?? '',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            onPressed: id.isEmpty ? null : () => _handleConnect(id, index),
            child: const Text('Connect', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

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
      onRefresh: () => _loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          final String profilePic = DobYobSessionManager.resolveUrl(
            r['profile_pic']?.toString() ?? '',
          );

          final String senderId = r['sender_id']?.toString() ?? '';
          final String connectionId = r['connection_id']?.toString() ?? '';
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
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: _buildAvatar(
                              profilePic: profilePic,
                              accent: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        ),
                        const SizedBox(width: 8),
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
}
