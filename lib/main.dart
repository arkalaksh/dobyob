import 'package:dobyob_1/screens/create_post_screen.dart';
import 'package:dobyob_1/screens/dobyob_intro_screen.dart';
import 'package:dobyob_1/screens/invite_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DobYob',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Montserrat',
      ),
      // App सुरू होताना सगळ्यात आधी Intro स्क्रीन दिसेल
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const DobYobIntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const FeedScreen(),      // main feed/home
        '/addpost': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/invite': (context) => const InviteScreen(),
        // OTP स्क्रीनला named routeने जायचं असेल तर इथे पण add करू शकतोस
        // '/otp': (context) => const OtpScreen(...),  // गरजेनुसार
      },
    );
  }
}
