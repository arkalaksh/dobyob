import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/screens/other_profile_screen.dart';
import 'package:dobyob_1/screens/search_users_screen.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  // ✅ HomeShell कडून Profile tab open करण्यासाठी callback
  final VoidCallback? onOpenMyProfileTab;

  const FeedScreen({super.key, this.onOpenMyProfileTab});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {
  Future<List<Map<String, dynamic>>> postsFuture =
      Future<List<Map<String, dynamic>>>.value([]);

  String? myUserId;
  String? myProfilePic;

  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  final ScrollController _feedScrollCtrl = ScrollController();
  Timer? _picDebounce;
  bool _checkingPic = false;

  // cache-bust only when we detect profile pic change
  int _myAvatarBust = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ NEW: listen profile-pic change globally (instant update)
    DobYobSessionManager.profilePicVersion.addListener(_onGlobalProfilePicChanged);

    _initUserAndLoad();

    _feedScrollCtrl.addListener(() {
      // user scroll करताना pic sync (fallback)
      _debouncedSyncMyProfilePic();
    });
  }

  void _onGlobalProfilePicChanged() {
    // profile screen ने session.updateProfilePicture() केलं की हा call होईल
    _syncMyProfilePicFromSessionAndApi(forceApi: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DobYobSessionManager.profilePicVersion.removeListener(_onGlobalProfilePicChanged);

    _picDebounce?.cancel();
    _feedScrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // app resume ला पण pic sync
    if (state == AppLifecycleState.resumed) {
      _syncMyProfilePicFromSessionAndApi(forceApi: false);
    }
  }

  void _debouncedSyncMyProfilePic() {
    _picDebounce?.cancel();
    _picDebounce = Timer(const Duration(milliseconds: 250), () {
      _syncMyProfilePicFromSessionAndApi(forceApi: false);
    });
  }

  Future<void> _initUserAndLoad() async {
    final session = await DobYobSessionManager.getInstance();
    final uidInt = await session.getUserId();
    if (!mounted || uidInt == null) return;

    myUserId = uidInt.toString();

    // initial sync (API check once)
    await _syncMyProfilePicFromSessionAndApi(forceApi: true);

    setState(() {
      postsFuture = _api.getPosts(userId: myUserId!);
    });
  }

  Future<void> _syncMyProfilePicFromSessionAndApi({required bool forceApi}) async {
    if (_checkingPic) return;
    if (myUserId == null) return;

    _checkingPic = true;
    try {
      final session = await DobYobSessionManager.getInstance();

      // 1) Session मधून घ्या
      String? localPic = await session.getProfilePicture();
      String? finalPic = localPic;

      // 2) forceApi असेल किंवा session empty असेल तर API call
      if (forceApi || finalPic == null || finalPic.isEmpty) {
        final user = await _api.getProfile(myUserId!);

        // backend key: profile_pic
        final apiPic = user?['profile_pic']?.toString();

        if (apiPic != null && apiPic.isNotEmpty) {
          finalPic = apiPic;
          await session.updateProfilePicture(apiPic); // will notify too
        }
      }

      finalPic ??= "";

      if (!mounted) return;

      // ✅ changed असेल तर UI update + cache bust + (optional) feed rebuild
      if ((myProfilePic ?? "") != finalPic) {
        // evict old/new to be safe
        final oldUrl = (myProfilePic != null && myProfilePic!.isNotEmpty)
            ? DobYobSessionManager.resolveUrl(myProfilePic!)
            : "";
        final newUrl = finalPic.isNotEmpty
            ? DobYobSessionManager.resolveUrl(finalPic)
            : "";

        if (oldUrl.isNotEmpty) {
          await CachedNetworkImage.evictFromCache(oldUrl);
        }
        if (newUrl.isNotEmpty) {
          await CachedNetworkImage.evictFromCache(newUrl);
        }

        setState(() {
          myProfilePic = finalPic;
          _myAvatarBust = DateTime.now().millisecondsSinceEpoch;

          // 🔥 rebuild posts so "my post avatar" recalculates
          postsFuture = _api.getPosts(userId: myUserId!);
        });
      }
    } catch (_) {
      // ignore
    } finally {
      _checkingPic = false;
    }
  }

  void refreshPosts() {
    if (myUserId == null) return;
    setState(() {
      postsFuture = Future.delayed(Duration.zero, () {
        return _api.getPosts(userId: myUserId!);
      });
    });
  }

  String _formatPostTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    try {
      final dt = DateFormat("yyyy-MM-dd hh:mm:ss a").parse(createdAt).toLocal();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final postDay = DateTime(dt.year, dt.month, dt.day);

      final difference = today.difference(postDay).inDays;

      if (difference == 0) return DateFormat('hh:mm a').format(dt);
      if (difference == 1) return "Yesterday";
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (e) {
      return '';
    }
  }

  String _titleCase(String? input) {
    if (input == null || input.trim().isEmpty) return '';
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> _handleToggleLike(Map<String, dynamic> post) async {
    if (myUserId == null) return;

    final bool wasLiked = post['is_liked'].toString() == "1" ||
        post['is_liked'].toString().toLowerCase() == "true";
    final int oldCount = int.tryParse(post['likes_count'].toString()) ?? 0;

    setState(() {
      post['is_liked'] = wasLiked ? "0" : "1";
      post['likes_count'] = wasLiked ? (oldCount - 1) : (oldCount + 1);
    });

    final res = await _api.toggleLike(
      postId: post['id'].toString(),
      userId: myUserId!,
    );

    if (res['success'] != true) {
      if (!mounted) return;
      setState(() {
        post['is_liked'] = wasLiked ? "1" : "0";
        post['likes_count'] = oldCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? "Like failed")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadComments(String postId) {
    return _api.getComments(postId);
  }

  Future<void> _addComment(String postId, String content) async {
    if (myUserId == null || content.trim().isEmpty) return;
    await _api.addComment(postId: postId, userId: myUserId!, content: content);
  }

  Future<List<Map<String, dynamic>>> _loadLikes(String postId) {
    return _api.getPostLikes(postId);
  }

  List<Map<String, dynamic>> _sortCommentsByDate(
      List<Map<String, dynamic>> comments) {
    return comments
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
  }

  void _openUserProfileFromId(String userId) {
    if (myUserId != null && userId == myUserId) {
      widget.onOpenMyProfileTab?.call();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtherProfileScreen(userId: userId)),
    ).then((_) {
      _syncMyProfilePicFromSessionAndApi(forceApi: false);
    });
  }

  // ===========================
  // Edit/Delete Post
  // ===========================

  void _openPostOptionsSheet(
    Map<String, dynamic> post,
    int index,
    List<Map<String, dynamic>> posts,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020617),
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text("Edit", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _openEditPostSheet(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeletePost(post, index, posts);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openEditPostSheet(Map<String, dynamic> post) {
    if (myUserId == null) return;

    final ctrl = TextEditingController(text: (post['content'] ?? '').toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF020617),
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset,
            left: 14,
            right: 14,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Edit post",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Update your post...",
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: const Color(0xFF020817),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () async {
                      final newText = ctrl.text.trim();
                      if (newText.isEmpty) return;

                      Navigator.pop(ctx);

                      setState(() {
                        post['content'] = newText;
                      });

                      final res = await _api.updatePost(
                        postId: post['id'].toString(),
                        userId: myUserId!,
                        content: newText,
                      );

                      if (res['success'] != true && mounted) {
                        refreshPosts();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              res['message']?.toString() ?? "Failed to update post",
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePost(
    Map<String, dynamic> post,
    int index,
    List<Map<String, dynamic>> posts,
  ) {
    if (myUserId == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020617),
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Delete post?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This action cannot be undone.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F2937)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () async {
                        Navigator.pop(ctx);

                        setState(() {
                          if (index >= 0 && index < posts.length) posts.removeAt(index);
                        });

                        final res = await _api.deletePost(
                          postId: post['id'].toString(),
                          userId: myUserId!,
                        );

                        if (res['success'] != true && mounted) {
                          refreshPosts();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message']?.toString() ?? "Failed to delete post",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================
  // Comments Sheet
  // ===========================

  void _showCommentsSheet(Map<String, dynamic> post) async {
    final postId = post['id'].toString();
    final TextEditingController commentCtrl = TextEditingController();

    List<Map<String, dynamic>> comments = await _loadComments(postId);
    comments = _sortCommentsByDate(comments);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF020617),
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.7,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Comments",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF1F2937)),
                      Expanded(
                        child: comments.isEmpty
                            ? const Center(
                                child: Text("No comments yet",
                                    style: TextStyle(color: Colors.white70)),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (_, i) {
                                  final c = comments[i];
                                  final String commenterId =
                                      c['user_id']?.toString() ?? '';
                                  final String fullName =
                                      _titleCase(c['full_name']?.toString());
                                  final String rawPic =
                                      c['profile_pic']?.toString() ?? '';
                                  final String picUrl =
                                      DobYobSessionManager.resolveUrl(rawPic);

                                  return InkWell(
                                    onTap: commenterId.isNotEmpty
                                        ? () => _openUserProfileFromId(commenterId)
                                        : null,
                                    child: ListTile(
                                      leading: picUrl.isNotEmpty
                                          ? CircleAvatar(
                                              radius: 18,
                                              backgroundImage: CachedNetworkImageProvider(
                                                commenterId == myUserId
                                                    ? '$picUrl?v=$_myAvatarBust'
                                                    : picUrl,
                                              ),
                                            )
                                          : const CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Color(0xFF111827),
                                              child: Icon(Icons.person,
                                                  color: Colors.white, size: 18),
                                            ),
                                      title: Text(
                                        fullName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        c['content'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(color: Color(0xFF1F2937)),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              if (myProfilePic != null && myProfilePic!.isNotEmpty)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: CachedNetworkImageProvider(
                                    '${DobYobSessionManager.resolveUrl(myProfilePic!)}?v=$_myAvatarBust',
                                  ),
                                )
                              else
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF111827),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 18),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: commentCtrl,
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Write a comment...',
                                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                    filled: true,
                                    fillColor: const Color(0xFF020817),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(color: Color(0xFF1F2937)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(color: Color(0xFF1F2937)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  maxLines: null,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) {
                                    _postComment(commentCtrl, postId, setSheetState, comments);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _postComment(
                                    commentCtrl, postId, setSheetState, comments),
                                child: const Text(
                                  "Post",
                                  style: TextStyle(
                                    color: Color(0xFF0EA5E9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      refreshPosts();
    });
  }

  void _postComment(
    TextEditingController ctrl,
    String postId,
    StateSetter setSheetState,
    List<Map<String, dynamic>> comments,
  ) async {
    final text = ctrl.text.trim();
    if (text.isEmpty || myUserId == null) return;

    await _addComment(postId, text);
    ctrl.clear();

    final newComment = {
      'user_id': myUserId,
      'full_name': 'You',
      'profile_pic': myProfilePic ?? '',
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
    };

    setSheetState(() {
      comments.insert(0, newComment);
    });

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (mounted) {
        final fresh = await _loadComments(postId);
        final sorted = _sortCommentsByDate(fresh);
        setSheetState(() {
          comments
            ..clear()
            ..addAll(sorted);
        });
      }
    });

    if (mounted) refreshPosts();
  }

  // ===========================
  // Likes Sheet
  // ===========================

  void _showLikesSheet(Map<String, dynamic> post) async {
    final postId = post['id'].toString();
    List<Map<String, dynamic>> likes = await _loadLikes(postId);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020617),
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Likes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFF1F2937)),
              Expanded(
                child: likes.isEmpty
                    ? const Center(
                        child: Text("No likes yet",
                            style: TextStyle(color: Colors.white70)),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: likes.length,
                        itemBuilder: (_, i) {
                          final u = likes[i];
                          final String uid = u['user_id']?.toString() ?? '';
                          final String name = _titleCase(u['full_name']?.toString());
                          final String picRaw = u['profile_pic']?.toString() ?? '';
                          final String picUrl = DobYobSessionManager.resolveUrl(picRaw);

                          return InkWell(
                            onTap: uid.isNotEmpty ? () => _openUserProfileFromId(uid) : null,
                            child: ListTile(
                              leading: picUrl.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: CachedNetworkImageProvider(picUrl),
                                    )
                                  : const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Color(0xFF111827),
                                      child: Icon(Icons.person,
                                          color: Colors.white, size: 18),
                                    ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openComments(Map<String, dynamic> post) {
    _showCommentsSheet(post);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardBg = Color(0xFF020617);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    final String? headerPhoto =
        (myUserId != null && myProfilePic != null && myProfilePic!.trim().isNotEmpty)
            ? myProfilePic!.trim()
            : null;

    final String headerUrl = (headerPhoto != null && headerPhoto.isNotEmpty)
        ? DobYobSessionManager.resolveUrl(headerPhoto)
        : "";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => widget.onOpenMyProfileTab?.call(),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: (headerUrl.isNotEmpty)
                    ? CachedNetworkImageProvider('$headerUrl?v=$_myAvatarBust')
                    : null,
                child: (headerUrl.isNotEmpty)
                    ? null
                    : const Icon(Icons.person, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (myUserId == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchUsersScreen(
                        currentUserId: myUserId!,
                        query: '',
                      ),
                    ),
                  ).then((_) {
                    _syncMyProfilePicFromSessionAndApi(forceApi: false);
                  });
                },
                child: Container(
                  height: 40,
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
                      Text(
                        'Search',
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_box_rounded, color: Colors.white, size: 24),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
                if (result == true) refreshPosts();
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      body: myUserId == null
          ? const Center(child: CircularProgressIndicator(color: accent))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: accent));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No posts yet!", style: TextStyle(color: Colors.white)),
                  );
                }

                final posts = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView.separated(
                    controller: _feedScrollCtrl,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    key: const PageStorageKey('feed_list'),
                    padding: const EdgeInsets.only(bottom: 90, top: 8),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final post = posts[i];

                      final bool isLiked = post['is_liked'].toString() == "1" ||
                          post['is_liked'].toString().toLowerCase() == "true";

                      final String postOwnerId = post['user_id'].toString();

                      final String postImageUrl =
                          (post['image'] ?? post['post_image'] ?? '').toString();

                      void openOwnerProfile() => _openUserProfileFromId(postOwnerId);

                      final bool isMyPost = post['user_id'].toString() == myUserId;

                      // ✅ IMPORTANT: My posts => myProfilePic, others => post profile_pic
                      final String rawPic = isMyPost
                          ? (myProfilePic ?? '')
                          : (post['profile_pic']?.toString() ?? '');

                      final String picUrl = DobYobSessionManager.resolveUrl(rawPic);

                      return Container(
                        key: ValueKey(post['id']),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: openOwnerProfile,
                                    child: picUrl.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 22,
                                            backgroundColor: const Color(0xFF111827),
                                            backgroundImage: CachedNetworkImageProvider(
                                              isMyPost ? '$picUrl?v=$_myAvatarBust' : picUrl,
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Color(0xFF111827),
                                            child: Icon(Icons.person, color: Colors.white),
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: openOwnerProfile,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _titleCase(post['full_name']?.toString()),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatPostTime(post['created_at']?.toString()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (myUserId != null && postOwnerId == myUserId)
                                    IconButton(
                                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                                      onPressed: () => _openPostOptionsSheet(post, i, posts),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post['content'] ?? '',
                                style: const TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              if (postImageUrl.isNotEmpty && postImageUrl != "null")
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF020817),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(postImageUrl, fit: BoxFit.contain),
                                  ),
                                ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () => _handleToggleLike(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.mode_comment_outlined,
                                        color: Colors.white),
                                    onPressed: () => _openComments(post),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showLikesSheet(post),
                                    child: Text(
                                      "${post['likes_count']} Likes",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _openComments(post),
                                    child: Text(
                                      "${post['comments_count']} Comments",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}