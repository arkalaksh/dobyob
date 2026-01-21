import 'package:flutter/material.dart';

class DobYobExploreScreen extends StatelessWidget {
  const DobYobExploreScreen({super.key});

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
            colors: [
              Color(0xFF3D0C6B),
              Color(0xFF22063E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                // Header with back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, 
                        color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Discover DobYob',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
// ✅ LOGO
Image.asset(
  'assets/images/dobyob_logo.png',
  height: 90,
),

const SizedBox(height: 20),
                // Welcome message - Updated for DOB/YOB concept
                const Text(
                  'Connect by your date',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Professional network for your generation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE5E7EB),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Features showcase - DOB/YOB focused
                Expanded(
                  child: ListView(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.cake,
                        title: 'Birth Year Groups',
                        description: 'Connect with people born in your year. Find your generation, share experiences.',
                        color: Color(0xFF0ACF83),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.date_range,
                        title: 'DOB Connections',
                        description: 'Match by exact birth dates. Celebrate birthdays together, build real bonds.',
                        color: Color(0xFFFFC94A),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.business,
                        title: 'Build Professional Networks',
                        description: 'Professional networking based on age groups. Career advice from your peers.',
                        color: Color(0xFF007AFF),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.group,
                        title: 'Year-Based Communities',
                        description: 'Join 1990s, 2000s, GenZ groups. Events, discussions, and networking by birth decade.',
                        color: Color(0xFFBFDBFE),
                      ),
                    ],
                  ),
                ),

                // Get Started button
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
                      'Join App now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}