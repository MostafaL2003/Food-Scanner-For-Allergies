import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pleasegod/cubit/profile_cubit.dart'; // Make sure this path is right!
import 'package:pleasegod/screens/welcome_screen.dart';
import 'package:pleasegod/services/database_service.dart';

void main() async {
  // 1. Set up all our services
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('products');
  await Hive.openBox('user');

  // 2. Load the product database into Hive one time
  await DatabaseService().initProductDatabase();

  // 3. Run the app
  runApp(const FoodSafetyApp());
}

class FoodSafetyApp extends StatelessWidget {
  const FoodSafetyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 4. This is the "plumbing." It provides the "brain" (ProfileCubit)
    //    to the entire app that lives below it.
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // ... all your theme data can go here ...
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

        // 5. This is the first screen the user sees.
        //    It no longer needs any variables passed to it.
        home: const WelcomeScreen(),
      ),
    );
  }
}
