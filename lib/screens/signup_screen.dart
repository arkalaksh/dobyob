import 'package:dobyob_1/widgets/header.dart';
import 'package:flutter/material.dart';
import '../widgets/app_footer.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  void _sendOtp() {
    // Dummy validation example
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Proceed to OTP verification screen
    Navigator.pushReplacementNamed(context, '/otp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(
                icon: Icons.person_outline,
                title: 'Create Account',
                subtitle: 'Join DobYob community',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                isPassword: false,
                controller: fullNameController,
              ),
              CustomTextField(
                label: 'Email address',
                hint: 'Enter your email',
                isPassword: false,
                controller: emailController,
              ),
              CustomTextField(
                label: 'Date of Birth',
                hint: 'dd/mm/yy',
                isPassword: false,
                suffixIcon: Icons.calendar_today,
                controller: dobController,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _sendOtp,
                child: const Text('Send otp', style: TextStyle(color: Colors.white)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text("Login"),
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
