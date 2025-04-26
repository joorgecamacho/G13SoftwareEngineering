/// Main entry point of the Gamewise Flutter app.
/// 
/// This file initializes Firebase and runs the app. Firebase is used for authentication and possibly database operations.
/// We first ensure that Flutter bindings are initialized before any async code.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import the pages you will navigate to from the HomePage.
import 'login_page.dart';
import 'signup_page.dart';
import 'dashboard_page.dart';

/// The `main` function is the starting point for every Dart/Flutter app.
/// Here, we make sure everything related to Flutter is initialized, then initialize Firebase.
/// After that, we run the app by calling `runApp()` and passing our root widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This ensures that binding is ready before any async operation
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initializes Firebase with correct settings for the platform (iOS, Android, Web)
  );
  runApp(const GamewiseApp()); // Launch the app
}

/// `GamewiseApp` is the root widget of the app.
/// In Flutter, everything is a widget. We define a `StatelessWidget` because the app root doesn't need to change state.
class GamewiseApp extends StatelessWidget {
  const GamewiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamewise', // Title of the app that appears in the app switcher
      debugShowCheckedModeBanner: false, // Removes the debug banner from the top right corner
      home: const HomePage(), // Sets the initial screen to be shown: HomePage
    );
  }
}

/// `HomePage` is the first screen the user sees.
/// It provides a simple interface with options to either Login or Sign Up.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sets background color to white
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Applies padding around the column for a nicer look
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the widgets vertically
            children: [
              // Welcome text
              const Text(
                'Welcome to GameWise',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Adds vertical space of 20 pixels

              // Description text
              const Text(
                'GameWise helps you track, review, and discover video games.\n'
                'Create an account or log in to get started!',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40), // More space before the buttons

              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to LoginPage when the Login button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20), // Space between Login and Sign Up button

              // Sign Up Button
              OutlinedButton(
                onPressed: () {
                  // Navigate to SignUpPage when the Sign Up button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
Key Learning Points from this code:
- Always initialize Flutter binding if you do async work in main()
- Use StatelessWidget when your widget doesn't hold state.
- Navigator.push() is used to move between pages/screens in Flutter.
- Use SizedBox for spacing between widgets instead of padding each time.
- Separate pages into different files for better organization and cleaner code.
- Always style your app early (like setting backgroundColor) for a more polished look.
*/
