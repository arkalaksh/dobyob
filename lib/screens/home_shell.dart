import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// ✅ FIX: Use GlobalKey instead of UniqueKey
  final GlobalKey<FeedScreenState> feedKey =
      GlobalKey<FeedScreenState>();

  final GlobalKey<ProfileScreenState> profileKey =
      GlobalKey<ProfileScreenState>();

  void _goFeed() {
    if (!mounted) return;
    setState(() => currentIndex = 0);

    /// ✅ Important: refresh feed when coming back
    feedKey.currentState?.refreshPosts();
  }

  // ✅ Create post screen
  Future<void> _openCreatePost(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreatePostScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));

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
    );

    if (!mounted) return;

    /// ✅ Refresh feed only if post created
    if (result == true) {
      feedKey.currentState?.refreshPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: bgColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: IndexedStack(
          index: currentIndex,
          children: [
            FeedScreen(
              key: feedKey,
              onOpenMyProfileTab: () =>
                  setState(() => currentIndex = 4),
            ),
            const NetworkScreen(onBackToFeed: null),
            const InviteScreen(onBackToFeed: null),
            const SizedBox.shrink(),
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
          },
          onCreatePost: () async {
            await _openCreatePost(context);
          },
        ),
      ),
    );
  }
}
