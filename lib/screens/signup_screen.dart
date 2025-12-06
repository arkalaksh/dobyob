import 'package:dobyob_1/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dobyob_1/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  final ApiService apiService = ApiService();

  // ---------- validation helpers ----------

  // Email MUST be valid and MUST end with .com
  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    // basic email + .com at end
    final reg = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$',
    );
    return reg.hasMatch(trimmed);
  }

  // Name: 3–25 chars, letters + spaces only
  bool _isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 3 || trimmed.length > 25) return false;
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(trimmed);
  }

  // DOB string "dd/MM/yyyy" -> DateTime? (null if invalid)
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

  // Age check: user must be at least 16 years (birth year <= 2009 approx)
  bool _isValidAge(String dob) {
    final date = _parseDob(dob);
    if (date == null) return false;

    // exact 16 years check
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    return age >= 16;
  }

  // ----------------------------------------

  String getApiDate(String localDate) {
    final parts = localDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return localDate;
  }

  Future<void> _sendOtp() async {
    final name = fullNameController.text;
    final email = emailController.text;
    final dob = dobController.text;
    final phone = phoneController.text;

    if (name.isEmpty || email.isEmpty || dob.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Name validation (3–25 chars, only letters + space)
    if (!_isValidName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name must be 3–25 letters (A–Z) only'),
        ),
      );
      return;
    }

    // Email validation (.com and valid pattern)
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid .com email address'),
        ),
      );
      return;
    }

    // DOB format + age >= 16 check
    final parsedDob = _parseDob(dob);
    if (parsedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter DOB in dd/mm/yyyy format'),
        ),
      );
      return;
    }

    if (!_isValidAge(dob)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be at least 16 years old to create account'),
        ),
      );
      return;
    }

    final response = await apiService.sendOtp(
      fullName: name.trim(),
      email: email.trim(),
      dateOfBirth: getApiDate(dob.trim()),
      phone: phone.trim(),
    );

    if (response['success'] == true) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => OtpScreen(
        email: email.trim(),
        fullName: name.trim(),
        dateOfBirth: getApiDate(dob.trim()),
        phone: phone.trim(),
        deviceToken: "",
        deviceType: "",
      ),
    ),
  );
} else {
  final msg = (response['error'] ?? response['message'] ?? 'Failed to send OTP').toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
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
              Center(
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: circleColor,
                      child: Icon(Icons.person_add_alt_1,
                          color: Colors.white, size: 26),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Join DobYob community',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Full Name
              const Text(
                'Full Name',
                style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: fullNameController,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF38BDF8),
                maxLength: 25, // hard limit
                decoration: InputDecoration(
                  counterText: '', // hide counter
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
                    borderSide: const BorderSide(
                      color: Color(0xFF38BDF8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Email
              const Text(
                'Email address',
                style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF38BDF8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // DOB (manual + calendar)
              const Text(
                'Date of Birth',
                style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: dobController,
                readOnly: false,
                keyboardType: TextInputType.datetime,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF38BDF8),
                decoration: InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF9CA3AF),
                      size: 18,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        dobController.text =
                            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString()}";
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
                    borderSide: const BorderSide(
                      color: Color(0xFF38BDF8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Phone
              const Text(
                'Phone No',
                style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF38BDF8),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
                dropdownIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF9CA3AF),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  phoneController.text = phone.number;
                },
              ),

              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: circleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _sendOtp,
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
