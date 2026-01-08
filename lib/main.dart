import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:dobyob_1/screens/dobyob_intro_screen.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/screens/login_screen.dart';
import 'package:dobyob_1/screens/signup_screen.dart';

import 'package:dobyob_1/screens/home_shell.dart'; // ✅ NEW
import 'package:dobyob_1/screens/create_post_screen.dart';
import 'package:dobyob_1/screens/profile_screen.dart';
import 'package:dobyob_1/screens/invite_screen.dart';
import 'package:dobyob_1/screens/my_network_screen.dart'; // file name same (class inside = NetworkScreen)
import 'package:dobyob_1/screens/explore_app_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  String fcmToken = '';
  try {
    fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    // ignore: avoid_print
    print('✅ FCM Token: $fcmToken');
  } catch (e) {
    // ignore: avoid_print
    print('❌ FCM getToken error: $e');
    fcmToken = '';
  }

  final session = await DobYobSessionManager.getInstance();
  final bool isLoggedIn = await session.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn, fcmToken: fcmToken));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String fcmToken;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.fcmToken,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DobYob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Montserrat',
      ),

      // ✅ Login नसेल तर Intro, login असेल तर HomeShell
      initialRoute: isLoggedIn ? '/home' : '/intro',

      routes: {
        '/intro': (context) => const DobYobIntroScreen(),
        '/login': (context) => LoginScreen(fcmToken: fcmToken),
        '/signup': (context) => SignupScreen(fcmToken: fcmToken),

        // ✅ Bottom tabs container
        '/home': (context) => const HomeShell(),

        // ✅ Keep as standalone routes (fallback / direct open)
        '/addpost': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/invite': (context) => const InviteScreen(),

        // ✅ Option B: file = my_network_screen.dart पण class = NetworkScreen
        '/network': (context) => const NetworkScreen(),

        '/explore': (context) => const DobYobExploreScreen(),
      },
    );
  }
}
