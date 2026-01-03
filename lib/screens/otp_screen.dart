import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isLoading = false;

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _showSnack(String msg, {Color? bg}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  // ✅ Clean MPIN BottomSheet (returns mpin or null)
  Future<String?> _showSetMpinPopup(String userId) async {
    final mpinController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showModalBottomSheet<String?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final mpin = mpinController.text.trim();
            final confirm = confirmController.text.trim();

            final mismatch =
                mpin.isNotEmpty && confirm.isNotEmpty && mpin != confirm;

            final canSubmit = mpin.length == 6 &&
                confirm.length == 6 &&
                mpin == confirm &&
                RegExp(r'^\d{6}$').hasMatch(mpin);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF020617),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(color: Color(0xFF1F2937), width: 1.1),
                    left: BorderSide(color: Color(0xFF1F2937), width: 1.1),
                    right: BorderSide(color: Color(0xFF1F2937), width: 1.1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 46,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0EA5E9).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9)
                                      .withOpacity(0.35),
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Color(0xFF0EA5E9),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create MPIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Set a 6-digit MPIN for quick login',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter MPIN',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _pinField(
                          controller: mpinController,
                          hint: '● ● ● ● ● ●',
                          accent: const Color(0xFF0EA5E9),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Confirm MPIN',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _pinField(
                          controller: confirmController,
                          hint: '● ● ● ● ● ●',
                          accent: const Color(0xFF0ACF83),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                        const SizedBox(height: 12),
                        if (mismatch)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.35),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'MPIN does not match.',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx, null),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFF334155)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    foregroundColor: Colors.white70,
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: canSubmit
                                      ? () => Navigator.pop(ctx, mpin)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0EA5E9),
                                    disabledBackgroundColor:
                                        const Color(0xFF0EA5E9)
                                            .withOpacity(0.25),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save MPIN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    mpinController.dispose();
    confirmController.dispose();
    return result;
  }

  // ✅ MPIN input (digits only)
  Widget _pinField({
    required TextEditingController controller,
    required String hint,
    required Color accent,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      obscureText: true,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.w800,
        letterSpacing: 10,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2.0),
        ),
      ),
      onChanged: onChanged,
    );
  }

 // तुझा सगळा code जसाच्याच तसा, फक्त _confirmOtp() शेवट बदल:

Future<void> _confirmOtp() async {
  final otp = _controllers.map((c) => c.text).join();

  if (otp.length != 6) {
    _showSnack("Please enter 6 digit OTP");
    return;
  }

  setState(() => isLoading = true);

  try {
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
      final data = response['user'] ?? response;
      final userId = (data['user_id'] ?? data['id'] ?? '0').toString();
      
      if (userId == '0') {
        if (mounted) setState(() => isLoading = false);
        _showSnack('UserId missing from server response');
        return;
      }

      if (mounted) setState(() => isLoading = false);

      final mpin = await _showSetMpinPopup(userId);
      if (!mounted) return;

      if (mpin == null) {
        _showSnack('MPIN setup cancelled');
        return;
      }

      setState(() => isLoading = true);

      final upd = await apiService.updateMpin(
        userId: userId,
        mpin: mpin,
      );

      if (!mounted) return;

      if (upd['success'] != true) {
        setState(() => isLoading = false);
        _showSnack(upd['message']?.toString() ?? 'Failed to set MPIN');
        return;
      }

      // Session save (unchanged)
      try {
        final session = await DobYobSessionManager.getInstance();
        await session.saveUserSession(
          userId: int.parse(userId),
          name: (data['full_name'] ?? widget.fullName).toString(),
          email: widget.email,
          phone: widget.phone,
          deviceToken: widget.deviceToken,
          deviceType: widget.deviceType,
          profilePicture: data['profile_pic']?.toString(),
        );
      } catch (_) {}

      if (!mounted) return;
      setState(() => isLoading = false);

      FocusScope.of(context).unfocus();

      // ✅ FIXED: Map return with userId
      Navigator.pop(context, {
        'verified': true,
        'userId': userId,  // ← SignupScreen ला userId मिळेल
      });
    } else {
      if (mounted) setState(() => isLoading = false);
      _showSnack(response['message']?.toString() ?? 'Invalid OTP');
    }
  } catch (e) {
    if (mounted) setState(() => isLoading = false);
    _showSnack('Network error: $e');
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
    final isFocused = _focusNodes[index].hasFocus;

    return SizedBox(
      width: 44,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isFocused ? const Color(0xFF0EA5E9) : const Color(0xFF1F2937),
            width: isFocused ? 2.0 : 1.3,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => _onOtpChanged(index, value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const circleColor = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                          child: Icon(Icons.verified_user,
                              color: Colors.white, size: 26),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Verify Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter the 6‑digit code sent to your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, _buildOtpBox),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't get the code? ",
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: resend OTP
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Resend now',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: circleColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading ? null : _confirmOtp,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm OTP',
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
        ),
      ),
    );
  }
}
