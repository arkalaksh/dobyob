import 'package:flutter/material.dart';

class DobYobIntroScreen extends StatelessWidget {
  const DobYobIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D0C6B), Color(0xFF22063E)],
          ),
        ),
       child: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔥 TOP: DobYob FULL LOGO (image already contains name)
        Column(
          children: [
            const SizedBox(height: 55),
            Center(
              child: Image.asset(
                'assets/images/dobyob_logo.png',
                height: 60,          // ✅ adjust if needed (60–70)
                fit: BoxFit.contain, // ✅ FULL logo visible, no crop
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    width: 160,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: const Text(
                      'Logo not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),

                // MIDDLE: main text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'A Network.',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You Were Born With.',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Social media you control.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE5E7EB),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                  ],
                ),

                // BUTTONS
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0ACF83),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/explore');
                      },
                      child: const Text(
                        'Explore the app',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFBFDBFE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                // BOTTOM: sign in row
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFFC94A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
