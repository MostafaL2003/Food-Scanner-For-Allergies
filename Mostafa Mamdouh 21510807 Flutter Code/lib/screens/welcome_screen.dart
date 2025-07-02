import 'package:flutter/material.dart';
import 'user_profile_screen.dart'; // Ensure this file exists in your project

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply a gradient background for depth and warmth.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE082)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // headline with refined typography.
                Text(
                  'Is This Safe?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9800), // Vibrant orange accent
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // subheading with a professional style.
                Text(
                  'Check food safety for your allergies',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // LOGO.
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    'assets/professional_food_safety.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // "Get Started" button .
                ElevatedButton(
                  onPressed: () {
                    // Navigate directly to the next page (UserProfileScreen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserProfileScreen(currentName: '', currentAllergies: [],)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
