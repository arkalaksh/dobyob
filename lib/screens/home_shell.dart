import 'package:flutter/material.dart';
import 'package:dobyob_1/widgets/main_bottom_nav.dart';
import 'package:dobyob_1/screens/feed_screen.dart';
import 'package:dobyob_1/screens/my_network_screen.dart';
import 'package:dobyob_1/screens/invite_screen.dart';
import 'package:dobyob_1/screens/profile_screen.dart';
import 'package:dobyob_1/screens/create_post_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0; // 0=Feed,1=Network,2=Invite,3=Post,4=Profile

  // ✅ KEY to access FeedScreen state
  final GlobalKey<FeedScreenState> feedKey = GlobalKey<FeedScreenState>();

  // ✅ KEY to access ProfileScreen state (for refreshing connection count)
  final GlobalKey<ProfileScreenState> profileKey = GlobalKey<ProfileScreenState>();

  void _goFeed() {
    if (!mounted) return;
    setState(() => currentIndex = 0);
  }

  Future<void> _openCreatePost(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );

    _goFeed();

    // ✅ IMPORTANT: refresh feed after post
    if (result == true) {
      feedKey.currentState?.refreshPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          FeedScreen(
            key: feedKey,
            onOpenMyProfileTab: () {
              setState(() => currentIndex = 4);
              // ✅ when opening profile tab from feed, refresh profile
              profileKey.currentState?.loadProfile();
            },
          ),

          NetworkScreen(
            onBackToFeed: _goFeed,
          ),

          InviteScreen(
            onBackToFeed: _goFeed,
          ),

          const SizedBox(), // Post placeholder

          ProfileScreen(
            key: profileKey,
            onBackToFeed: _goFeed,
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: currentIndex,
        onTap: (i) async {
          if (i == 3) {
            await _openCreatePost(context);
            return;
          }

          setState(() => currentIndex = i);

          // ✅ Profile tab selected -> refresh profile (connection count updated)
          if (i == 4) {
            profileKey.currentState?.loadProfile();
          }
        },
        onCreatePost: () async {
          await _openCreatePost(context);
        },
      ),
    );
  }
}
