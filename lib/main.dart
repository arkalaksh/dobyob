import 'package:dobyob_1/screens/create_post_screen.dart';
import 'package:dobyob_1/screens/invite_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/otp_screen.dart';
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
      title: 'Auth UI',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/login', // Or '/signup' if you want signup first
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SigninScreen(),
        '/home': (context) => const FeedScreen(),    // <-- Show posts/feed for home!
         '/addpost': (context) => const CreatePostScreen(),
        // '/otp': (context) => const OtpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/invite': (context) => const InviteScreen(),

      },
    );
  }
}
