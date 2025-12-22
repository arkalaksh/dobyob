import 'package:dobyob_1/screens/create_post_screen.dart';
import 'package:dobyob_1/screens/dobyob_intro_screen.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/screens/explore_app_page.dart';
import 'package:dobyob_1/screens/invite_screen.dart';
import 'package:dobyob_1/screens/login_screen.dart';
import 'package:dobyob_1/screens/my_network_screen.dart';
import 'package:dobyob_1/screens/signup_screen.dart';
import 'package:dobyob_1/screens/feed_screen.dart';
import 'package:dobyob_1/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  String fcmToken = '';
  try {
    fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    print('✅ FCM Token: $fcmToken');
  } catch (e) {
    // IMPORTANT: swallow the error so app does NOT crash
    print('❌ FCM getToken error: $e');
    fcmToken = ''; // continue without token
  }

  final session = await DobYobSessionManager.getInstance();
  final bool isLoggedIn = await session.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn, fcmToken: fcmToken));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String fcmToken;
  
  const MyApp({super.key, required this.isLoggedIn, required this.fcmToken});

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
        '/login': (context) => LoginScreen(fcmToken: fcmToken),
        '/signup': (context) => SignupScreen(fcmToken: fcmToken),
        '/home': (context) => const FeedScreen(),
        '/addpost': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/invite': (context) => const InviteScreen(),
        '/network': (context) => const NetworkScreen(),
        '/explore': (context) => const DobYobExploreScreen(),
      },
    );
  }
}
