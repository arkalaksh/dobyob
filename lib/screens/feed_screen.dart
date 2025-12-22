import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/widgets/main_bottom_nav.dart';
import 'package:dobyob_1/screens/search_users_screen.dart';
import 'package:dobyob_1/screens/other_profile_screen.dart';
import 'create_post_screen.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Map<String, dynamic>>> postsFuture;
  String? myUserId;
  String? myProfilePic;
  final ApiService _api = ApiService();

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserAndLoad();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initUserAndLoad() async {
    final session = await DobYobSessionManager.getInstance();
    final uidInt = await session.getUserId();
    if (!mounted || uidInt == null) return;

    String? localPic = await session.getProfilePicture();
    String? finalPic = localPic;

    if (localPic == null || localPic.isEmpty) {
      final user = await _api.getProfile(uidInt.toString());
      final apiPic = user?['profile_pic']?.toString();

      if (apiPic != null && apiPic.isNotEmpty) {
        finalPic = apiPic;
        await session.updateProfilePicture(apiPic);
      }
    }

    setState(() {
      myUserId = uidInt.toString();
      myProfilePic = finalPic ?? "";
      postsFuture = _api.getPosts(userId: myUserId!);
    });
  }

  void refreshPosts() {
    if (myUserId == null) return;
    setState(() {
      postsFuture = _api.getPosts(userId: myUserId!);
    });
  }

  String _formatPostTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';

    try {
      final dt =
          DateFormat("yyyy-MM-dd hh:mm:ss a").parse(createdAt).toLocal();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final postDay = DateTime(dt.year, dt.month, dt.day);

      final difference = today.difference(postDay).inDays;

      if (difference == 0) {
        return DateFormat('hh:mm a').format(dt);
      }
      if (difference == 1) {
        return "Yesterday";
      }
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
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
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
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
  }

  void _openUserProfileFromId(String userId) {
    if (myUserId != null && userId == myUserId) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherProfileScreen(userId: userId),
        ),
      );
    }
  }

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
                                child: Text(
                                  "No comments yet",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.builder(
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
                                        ? () =>
                                            _openUserProfileFromId(commenterId)
                                        : null,
                                    child: ListTile(
                                      leading: (picUrl.isNotEmpty)
                                          ? CircleAvatar(
                                              radius: 18,
                                              backgroundImage:
                                                  NetworkImage(picUrl),
                                            )
                                          : const CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  Color(0xFF111827),
                                              child: Icon(Icons.person,
                                                  color: Colors.white,
                                                  size: 18),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              if (myProfilePic != null &&
                                  myProfilePic!.isNotEmpty)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    DobYobSessionManager.resolveUrl(
                                        myProfilePic!),
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
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Write a comment...',
                                    hintStyle: const TextStyle(
                                        color: Color(0xFF6B7280)),
                                    filled: true,
                                    fillColor: const Color(0xFF020817),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF1F2937)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF1F2937)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF0EA5E9)),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                  ),
                                  maxLines: null,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) {
                                    _postComment(commentCtrl, postId,
                                        setSheetState, comments);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _postComment(
                                    commentCtrl,
                                    postId,
                                    setSheetState,
                                    comments),
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
      List<Map<String, dynamic>> comments) async {
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

    if (mounted) {
      refreshPosts();
    }
  }

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
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                            child: Text(
                              "No likes yet",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: likes.length,
                            itemBuilder: (_, i) {
                              final u = likes[i];
                              final String uid =
                                  u['user_id']?.toString() ?? '';
                              final String name =
                                  _titleCase(u['full_name']?.toString());
                              final String picRaw =
                                  u['profile_pic']?.toString() ?? '';
                              final String picUrl =
                                  DobYobSessionManager.resolveUrl(picRaw);

                              return InkWell(
                                onTap: uid.isNotEmpty
                                    ? () => _openUserProfileFromId(uid)
                                    : null,
                                child: ListTile(
                                  leading: (picUrl.isNotEmpty)
                                      ? CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              NetworkImage(picUrl),
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
        (myUserId != null &&
                myProfilePic != null &&
                myProfilePic!.trim().isNotEmpty)
            ? myProfilePic!.trim()
            : null;

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
              onTap: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: accent,
                backgroundImage: (headerPhoto != null)
                    ? NetworkImage(
                        DobYobSessionManager.resolveUrl(headerPhoto))
                    : null,
                child: (headerPhoto != null)
                    ? null
                    : const Icon(Icons.person,
                        color: Colors.white, size: 26),
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
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF020817),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.search,
                          color: Color(0xFF6B7280), size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_box_rounded,
                  color: Colors.white, size: 24),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePostScreen(),
                  ),
                );
                if (result == true) {
                  refreshPosts();
                }
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
      body: myUserId == null
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0EA5E9)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts yet!",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final posts = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        bottom: 90, top: 8),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final post = posts[i];
                      final bool isLiked =
                          post['is_liked'].toString() == "1" ||
                              post['is_liked']
                                      .toString()
                                      .toLowerCase() ==
                                  "true";

                      final String postOwnerId =
                          post['user_id'].toString();

                      void _openOwnerProfile() {
                        _openUserProfileFromId(postOwnerId);
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: borderColor, width: 1.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _openOwnerProfile,
                                    child: (DobYobSessionManager
                                                    .resolveUrl(
                                                        post['profile_pic']) !=
                                                null &&
                                            DobYobSessionManager
                                                    .resolveUrl(
                                                        post['profile_pic']) !=
                                                "")
                                        ? CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(
                                              DobYobSessionManager
                                                  .resolveUrl(
                                                      post['profile_pic']),
                                            ),
                                            radius: 22,
                                          )
                                        : const CircleAvatar(
                                            radius: 22,
                                            backgroundColor:
                                                Color(0xFF111827),
                                            child: Icon(Icons.person,
                                                color: Colors.white),
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openOwnerProfile,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            _titleCase(post['full_name']
                                                ?.toString()),
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatPostTime(post['created_at']
                                        ?.toString()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post['content'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              if (post['image_url'] != null &&
                                  post['image_url'] != "null" &&
                                  post['image_url'] != "")
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(
                                          vertical: 12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    color: const Color(0xFF020817),
                                    border: Border.all(
                                        color: borderColor),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    child: Image.network(
                                      post['image_url'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                    onPressed: () =>
                                        _handleToggleLike(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.mode_comment_outlined,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        _openComments(post),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showLikesSheet(post),
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
                                    onTap: () =>
                                        _openComments(post),
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
