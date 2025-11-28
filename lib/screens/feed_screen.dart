import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Map<String, dynamic>>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = ApiService().getPosts();
  }

  void refreshPosts() {
    setState(() {
      postsFuture = ApiService().getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardBg = Color(0xFF020617);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

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
            const CircleAvatar(
              radius: 22,
              backgroundColor: accent,
              child: Icon(Icons.person, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 40,
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
                    const Expanded(
                      child: TextField(
                        style:
                            TextStyle(fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle:
                              TextStyle(color: Color(0xFF6B7280)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF020817),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xFF6B7280),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) async {
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/invite');
          }
          if (i == 2) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreatePostScreen()),
            );
            if (result == 'posted') {
              refreshPosts();
            }
          }
          if (i == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF0EA5E9)),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 90, top: 8),
              itemCount: posts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final post = posts[i];
                return Container(
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
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            (post['profile_pic'] != null &&
                                    post['profile_pic'] != "")
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      "https://arkalaksh.com/dobyob/${post['profile_pic']}",
                                    ),
                                    radius: 22,
                                  )
                                : const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Color(0xFF111827),
                                    child: Icon(Icons.person,
                                        color: Colors.white),
                                  ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['full_name'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "User ID: ${post['user_id']}",
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              post['created_at']?.substring(11, 16) ??
                                  '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_horiz,
                                  size: 22, color: Colors.white),
                              onPressed: () {},
                              splashRadius: 18,
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
                                const EdgeInsets.symmetric(vertical: 12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF020817),
                              border: Border.all(color: borderColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                post['image_url'],
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, progress) {
                                  if (progress == null) return child;
                                  return SizedBox(
                                    height: 180,
                                    child: Center(
                                      child:
                                          CircularProgressIndicator(
                                        color: accent,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              "${post['likes_count']} Likes",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${post['comments_count']} Comments",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
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
