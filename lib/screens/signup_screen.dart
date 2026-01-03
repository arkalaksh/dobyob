import 'dart:io' show Platform;

import 'package:dobyob_1/screens/dobyob_wizard.dart';
import 'package:dobyob_1/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dobyob_1/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  final String fcmToken;
  const SignupScreen({super.key, required this.fcmToken});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print('SignupScreen FCM Token: ${widget.fcmToken}');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final reg = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$');
    return reg.hasMatch(trimmed);
  }

  bool _isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 3 || trimmed.length > 25) return false;
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(trimmed);
  }

  DateTime? _parseDob(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  bool _isValidAge(String dob) {
    final date = _parseDob(dob);
    if (date == null) return false;

    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }
    return age >= 16;
  }

  String getApiDate(String localDate) {
    final parts = localDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return localDate;
  }

  Future<void> _sendOtp() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final dobLocal = dobController.text.trim(); // dd/MM/yyyy
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || dobLocal.isEmpty || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (!_isValidName(name)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be 3–25 letters (A–Z) only')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid .com email address')),
      );
      return;
    }

    final parsedDob = _parseDob(dobLocal);
    if (parsedDob == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter DOB in dd/mm/yyyy format')),
      );
      return;
    }

    if (!_isValidAge(dobLocal)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 16 years old')),
      );
      return;
    }

    final dobApi = getApiDate(dobLocal); // yyyy-MM-dd

    final response = await apiService.sendOtp(
      fullName: name,
      email: email,
      dateOfBirth: dobApi,
      phone: phone,
      deviceToken: widget.fcmToken,
      deviceType: Platform.isAndroid ? 'android' : 'ios',
    );

    if (!mounted) return;

    if (response['success'] == true) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            email: email,
            fullName: name,
            dateOfBirth: dobApi,
            phone: phone,
            deviceToken: widget.fcmToken,
            deviceType: Platform.isAndroid ? 'android' : 'ios',
          ),
        ),
      );

      if (!mounted) return;

      if (result is Map && result['verified'] == true) {
        final userId = (result['userId'] ?? '').toString();
        if (userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('UserId missing after OTP verification')),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DobYobWizard(
              userId: userId,
              fullName: name,
              email: email,
              phone: phone,
              dateOfBirth: dobApi,
            ),
          ),
        );
      }
    } else {
      final errorMsg = (response['error'] ?? response['message'] ?? 'Failed to send OTP').toString();

      if (errorMsg.contains('already registered') || errorMsg.contains('Please log in')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already exists! Taking you to login...'),
            backgroundColor: Color.fromARGB(255, 11, 65, 88),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const fieldColor = Color(0xFF020617);
    const circleColor = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: circleColor,
                      child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 26),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Join DobYob community',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Full Name',
                  style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: fullNameController,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF38BDF8),
                maxLength: 25,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter your full name',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: fieldColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
              ),

              const SizedBox(height: 12),

              const Text('Email address',
                  style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF38BDF8),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email (.com only)',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: fieldColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
              ),

              const SizedBox(height: 12),

              const Text('Date of Birth',
                  style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: dobController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF38BDF8),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8), // ddMMyyyy
                  DobInputFormatter(), // dd/MM/yyyy
                ],
                decoration: InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Color(0xFF9CA3AF), size: 18),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        dobController.text =
                            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      }
                    },
                  ),
                  filled: true,
                  fillColor: fieldColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
              ),

              const SizedBox(height: 12),

              const Text('Phone No',
                  style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              IntlPhoneField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF38BDF8),
                dropdownTextStyle: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: fieldColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
                dropdownIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  phoneController.text = phone.number;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: circleColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _sendOtp,
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// ddMMyyyy digits -> dd/MM/yyyy
class DobInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if (i == 1 || i == 3) buffer.write('/');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
