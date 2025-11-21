import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'create_post_screen.dart'; // याची फाईल lib/screens/ मध्ये असावी

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6C646),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 10),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  "https://randomuser.me/api/portraits/men/61.jpg",
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search',
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFFF6C646)),
            label: '',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: const Color(0xFFF6C646),
        unselectedItemColor: const Color(0xFFF6C646),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) async {
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/invite');
          }
          if (i == 2) {
            // + आयकॉन क्लिक केल्यावर CreatePostScreen open करा आणि Successfully Posted झालं तर feed refresh करा
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts yet!"));
          }
          final posts = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 90, top: 10),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final post = posts[i];

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfffff7d1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber, width: 1.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (post['profile_pic'] != null && post['profile_pic'] != "")
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      "https://arkalaksh.com/dobyob/${post['profile_pic']}",
                                    ),
                                    radius: 22,
                                  )
                                : const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.black12,
                                    child: Icon(Icons.person, color: Colors.grey),
                                  ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['full_name'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "User ID: ${post['user_id']}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              post['created_at']?.substring(11,16) ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_horiz, size: 22),
                              onPressed: () {},
                              splashRadius: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post['content'] ?? '',
                          style: const TextStyle(fontSize: 15),
                        ),
                        if (post['image_url'] != null && post['image_url'] != "null")
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(post['image_url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              "${post['likes_count']} Likes",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${post['comments_count']} Comments",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
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
