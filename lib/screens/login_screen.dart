import 'package:dobyob_1/widgets/header.dart';
import 'package:flutter/material.dart';
import '../widgets/app_footer.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/social_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() {
    if (emailController.text == "test@email.com" && passwordController.text == "123456") {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials. Use test@email.com / 123456"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(  // Wrap for scrolling when keyboard opens
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(
                icon: Icons.person,
                title: 'Login Account',
                subtitle: 'Welcome back to DobYob',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Email address',
                hint: 'Enter your email',
                isPassword: false,
                controller: emailController,
              ),
              CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                isPassword: true,
                controller: passwordController,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password ?'),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _login,
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
              const AppFooter(
                infoText: 'Or Sign up with',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
