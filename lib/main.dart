/// Main entry point of the Gamewise Flutter app.
///
/// This file initializes Firebase and runs the app. Firebase is used for authentication
/// and possibly other database operations. We first ensure that Flutter bindings are
/// initialized before any asynchronous code executes.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import navigation targets
import 'login_page.dart';
import 'signup_page.dart';
import 'dashboard_page.dart';

/// The `main` function is the starting point for any Flutter app.
/// Here, we make sure everything related to Flutter is initialized,
/// then initialize Firebase, and finally launch the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async setup in main()
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Platform-specific Firebase config
  );
  runApp(const GamewiseApp()); // Launch the root widget
}

/// Root widget of the Gamewise app.
/// This is a stateless widget because the root itself doesn't need to manage state.
class GamewiseApp extends StatelessWidget {
  const GamewiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamewise', // Title shown in app switcher
      debugShowCheckedModeBanner: false, // Hides the red debug banner
      home: const HomePage(), // Initial route of the app
    );
  }
}

/// Home screen shown on app launch.
/// Provides two main navigation options: Log In or Sign Up.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Background gradient styling
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome title
                const Text(
                  'Welcome to GameWise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Introductory description
                const Text(
                  'GameWise helps you track, review, and discover video games.\n'
                  'Create an account or log in to get started!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Log In button
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 20),

                // Sign Up button
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
Key Learning Points:
- Use WidgetsFlutterBinding.ensureInitialized() before async code in main().
- Use StatelessWidget for screens without internal state.
- Use Navigator.push() for navigation between pages.
- Prefer SizedBox for spacing instead of manual padding.
- Organize major pages in separate files for clarity and modularity.
- Apply early styling (e.g., background gradients) to improve UX.
*/
