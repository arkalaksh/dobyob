import 'package:flutter/material.dart';

class EditContactInfoScreen extends StatefulWidget {
  final String initialEmail;
  final String initialMobile;
  final String initialAddress;

  const EditContactInfoScreen({
    super.key,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAddress,
  });

  @override
  State<EditContactInfoScreen> createState() => _EditContactInfoScreenState();
}

class _EditContactInfoScreenState extends State<EditContactInfoScreen> {
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController addressController;

  String? emailError;
  String? mobileError;
  String? addressError;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
    mobileController = TextEditingController(text: widget.initialMobile);
    addressController = TextEditingController(text: widget.initialAddress);

    _validateFields();
  }

  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// Email MUST end with ".com" and nothing after that
  bool _isValidEmail(String email) {
    final reg = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$',
    );
    return reg.hasMatch(email.trim());
  }

  /// STRICT 10 DIGIT MOBILE CHECK
  bool _isValidMobile(String mobile) {
    final cleaned = mobile.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 10;
  }

  void _validateFields() {
    final emailText = emailController.text.trim();
    final mobileText = mobileController.text.trim();
    final addressText = addressController.text.trim();

    setState(() {
      // Email Validation
      if (emailText.isEmpty) {
        emailError = 'Email is required';
      } else if (!_isValidEmail(emailText)) {
        emailError = 'Enter valid .com email address';
      } else {
        emailError = null;
      }

      // Mobile Validation
      final mobileCleaned = mobileText.replaceAll(RegExp(r'[^\d]'), '');
      if (mobileText.isEmpty) {
        mobileError = 'Mobile is required';
      } else if (mobileCleaned.length != 10) {
        mobileError = 'Enter valid 10-digit mobile number';
      } else {
        mobileError = null;
      }

      // Address Validation (optional, 5–25 chars)
      if (addressText.isEmpty) {
        addressError = null;
      } else if (addressText.length < 5) {
        addressError = 'Address too short';
      } else if (addressText.length > 25) {
        addressError = 'Maximum 25 characters allowed';
      } else {
        addressError = null;
      }
    });
  }

  bool get _isFormValid {
    return emailError == null &&
        mobileError == null &&
        addressError == null;
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Contact Info",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: Color(0xFF1F2937),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _validateFields(),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: accent)),
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _validateFields(),
                decoration: InputDecoration(
                  labelText: "Mobile",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: accent)),
                  errorText: mobileError,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                onChanged: (_) => _validateFields(),
                decoration: InputDecoration(
                  labelText: "Address (optional)",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: accent)),
                  errorText: addressError,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? accent : Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isFormValid
                      ? () {
                          Navigator.pop(context, {
                            'email': emailController.text.trim(),
                            'mobile': mobileController.text.trim(),
                            'address': addressController.text.trim(),
                          });
                        }
                      : null,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
