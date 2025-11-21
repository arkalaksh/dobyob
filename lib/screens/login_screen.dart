import 'package:flutter/material.dart';
import 'package:dobyob_1/widgets/header.dart';
import '../widgets/app_footer.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/social_buttons.dart';
import 'package:dobyob_1/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final otpFocusNodes = List.generate(6, (index) => FocusNode());
  final ApiService apiService = ApiService();

  bool otpFieldVisible = false;
  bool isLoading = false;

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _sendOtp() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    setState(() => isLoading = true);
    final res = await apiService.sendEmailOtp(
      email: emailController.text.trim(),
    );
    setState(() => isLoading = false);

    if (res['success'] == true) {
      setState(() {
        otpFieldVisible = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'OTP sent to your email')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6 digit OTP')),
      );
      return;
    }
    setState(() => isLoading = true);

    // Note: API endpoint is now loginwithotp.php for login flow!
    final res = await apiService.verifyLoginOtp(
      email: emailController.text.trim(),
      otp: otp,
    );

    setState(() => isLoading = false);

    if (res['success'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'OTP verification failed')),
      );
    }
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => Container(
          width: 44,
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: otpFocusNodes[index].hasFocus ? Colors.orange : Colors.deepPurple.shade200,
              width: otpFocusNodes[index].hasFocus ? 2.2 : 1.3,
            ),
          ),
          child: Center(
            child: TextField(
              controller: otpControllers[index],
              focusNode: otpFocusNodes[index],
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              onChanged: (value) => _onOtpChanged(index, value),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: const [
                  SizedBox(height: 10),
                  AppHeader(
                    icon: Icons.person,
                    title: 'Login Account',
                    subtitle: 'Welcome back to DobYob',
                  ),
                ],
              ),

              // Middle Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'Email address',
                    hint: 'Enter your email',
                    isPassword: false,
                    controller: emailController,
                  ),
                  const SizedBox(height: 8),

                  if (otpFieldVisible)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildOtpRow(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isLoading
                        ? null
                        : (otpFieldVisible ? _verifyOtp : _sendOtp),
                    child: isLoading
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.7,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            otpFieldVisible ? "Verify OTP" : "Send OTP",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Bottom Section
              Column(
                children: const [
                  SizedBox(height: 10),
                  AppFooter(infoText: 'Or Sign up with'),
                  SizedBox(height: 10),
                  SocialButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
