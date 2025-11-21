import 'package:dobyob_1/screens/otp_screen.dart';
import 'package:dobyob_1/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../widgets/custom_textfield.dart';
import 'package:dobyob_1/services/api_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  final ApiService apiService = ApiService();

  String getApiDate(String localDate) {
    final parts = localDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return localDate;
  }

  Future<void> _sendOtp() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        dobController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final response = await apiService.sendOtp(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      dateOfBirth: getApiDate(dobController.text.trim()),
      phone: phoneController.text.trim(),
    );

    if (response['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            email: emailController.text.trim(),
            fullName: fullNameController.text.trim(),
            dateOfBirth: getApiDate(dobController.text.trim()),
            phone: phoneController.text.trim(),
            deviceToken: "", // तुमचा deviceToken द्या
            deviceType: "",  // deviceType उदाहरणार्थ 'android'
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(
                icon: Icons.person_outline,
                title: 'Create Account',
                subtitle: 'Join DobYob community',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                isPassword: false,
                controller: fullNameController,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Email address',
                hint: 'Enter your email',
                isPassword: false,
                controller: emailController,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Date of Birth',
                hint: 'dd/mm/yyyy',
                isPassword: false,
                controller: dobController,
                readOnly: true,
                suffixIcon: Icons.calendar_today,
                onTap: () async {
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
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Phone No',
                hint: '',
                isPassword: false,
                child: IntlPhoneField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    phoneController.text = phone.number;
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _sendOtp,
                child: const Text(
                  'Send otp',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
