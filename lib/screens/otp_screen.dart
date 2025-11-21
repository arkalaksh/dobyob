import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String dateOfBirth;
  final String phone;
  final String deviceToken;
  final String deviceType;

  const OtpScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    required this.phone,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  final ApiService apiService = ApiService();

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _confirmOtp() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter 6 digit OTP")),
      );
      return;
    }

    final response = await apiService.verifyRegistrationOtp(
      email: widget.email,
      otp: otp,
      fullName: widget.fullName,
      dateOfBirth: widget.dateOfBirth,
      phone: widget.phone,
      deviceToken: widget.deviceToken,
      deviceType: widget.deviceType,
    );

    if (response['success'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Invalid OTP')),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusNodes[index].hasFocus;
    return Container(
      width: 44,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isFocused ? Colors.orange : Colors.deepPurple.shade200,
          width: isFocused ? 2.2 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: mq.size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  CircleAvatar(
                    backgroundColor: Colors.yellow[700],
                    radius: 38,
                    child: const Icon(Icons.verified_user, size: 38, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: Color(0xFF1D1C61),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the verification code we just sent your email address',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, _buildOtpBox),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "If you don't get the code. ",
                        style: TextStyle(fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {}, // TODO: resend OTP add here
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Resend Now',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    onPressed: _confirmOtp,
                    child: const Text(
                      'Confirm OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Or Sign up with",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.facebook, color: Colors.blue, size: 30),
                      SizedBox(width: 18),
                      Icon(Icons.alternate_email, color: Colors.lightBlue, size: 28),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
