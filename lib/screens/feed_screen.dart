import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> posts = [
      {
        "author": "Christine Perkins",
        "subtitle": "CEO of Solar Stashi",
        "minutes": "23 mins",
        "text":
            "Really excited to see the technological progress happening in solar right now. Where do you guys think the biggest impact will be?",
        "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        "link": "SolarCity to Make High-Efficiency Panel\nnytimes.com",
        "likes": 29,
        "comments": 12
      },
      {
        "author": "Christine Perkins",
        "subtitle": "CEO of Solar Stashi",
        "minutes": "23 mins",
        "text":
            "🎉 Just found out there are 342 people with my exact birthday! This app is amazing for connecting with birthday twins. Anyone else born on Jan 15, 1995?",
        "image": null,
        "link": null,
        "likes": 29,
        "comments": 12
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFFF6C646)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1, color: Color(0xFFF6C646)), // Invite friends
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
        selectedItemColor: Color(0xFFF6C646),
        unselectedItemColor: Color(0xFFF6C646),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/invite');
          if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
          // You can handle i==2 for post/add action in future
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF6C646),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.amber, width: 1.2),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.amber),
                    SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.amber),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final post = posts[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post['subtitle'],
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        post['minutes'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, size: 22),
                        onPressed: () {},
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(post['text']),
                  if (post['image'] != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(post['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (post['link'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        post['link'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Text("${post['likes']} Likes",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      Text("${post['comments']} Comments",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
