import 'package:dobyob_1/screens/create_post_screen.dart';
import 'package:dobyob_1/screens/dobyob_intro_screen.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/screens/invite_screen.dart';
import 'package:dobyob_1/screens/login_screen.dart';
import 'package:dobyob_1/screens/my_network_screen.dart';
import 'package:dobyob_1/screens/signup_screen.dart';
import 'package:dobyob_1/screens/feed_screen.dart';
import 'package:dobyob_1/screens/profile_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = await DobYobSessionManager.getInstance();
  final bool isLoggedIn = await session.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DobYob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Montserrat',
      ),
      initialRoute: isLoggedIn ? '/home' : '/intro',
      routes: {
        '/intro': (context) => const DobYobIntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const FeedScreen(),
        '/addpost': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/invite': (context) => const InviteScreen(),
        '/network': (context) => const NetworkScreen(),

      },
    );
  }
}
