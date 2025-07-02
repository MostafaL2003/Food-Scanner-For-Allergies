import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/local_storage.dart';

void main() async {
  // Ensure widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();


  // Load the saved user data before running the app.
  final userData = await LocalStorage.loadUserData();
  final userName = userData['name'] ?? '';
  final userAllergies = userData['allergies'] ?? [];

  runApp(FoodSafetyApp(
    userName: userName,
    userAllergies: userAllergies,
  ));
}

class FoodSafetyApp extends StatelessWidget {
  final String userName;
  final List<String> userAllergies;

  const FoodSafetyApp({
    Key? key,
    required this.userName,
    required this.userAllergies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFFFF9800),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFFF9800),
          secondary: const Color(0xFFFFC107),
          background: Colors.white,
          surface: Colors.white,
          error: const Color(0xFFFF5252),
          onPrimary: Colors.white,
          onSecondary: Colors.black87,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF9800),
          foregroundColor: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
      ),
      // Conditionally choose the starting screen.
      home: userName.isNotEmpty
          ? HomeScreen(userName: userName, userAllergies: userAllergies)
          : const WelcomeScreen(),
    );
  }
}