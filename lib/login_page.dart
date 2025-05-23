// Import core Flutter material UI library
import 'package:flutter/material.dart';
// Firebase Auth library for email/password and credential-based login
import 'package:firebase_auth/firebase_auth.dart';
// Google Sign-In library to allow Google-based authentication
import 'package:google_sign_in/google_sign_in.dart';
// Dashboard page shown after successful login
import 'dashboard_page.dart';
// HomePage allows users to return from login
import 'main.dart';

/// LoginPage is a stateful widget because it needs to track the values
/// of user inputs and handle login interactions.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers to capture user input for email and password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Handles login using email and password via Firebase Authentication.
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Simple input validation
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    try {
      // Attempt to sign in with Firebase using email/password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If successful, navigate to the dashboard and replace the current screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors and display user-friendly messages
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = 'Login failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Handles Google Sign-In and Firebase Authentication with Google credentials.
  Future<void> _signInWithGoogle() async {
    try {
      // Launch Google sign-in prompt
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '602783046019-5333cekolocth3ntgnbcgdummml1kg4l.apps.googleusercontent.com',
      ).signIn();

      // If user cancels login
      if (googleUser == null) {
        return;
      }

      // Get auth credentials from Google account
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Use credentials to sign in with Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } catch (e) {
      // Catch any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: const BoxDecoration(
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
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400), // max width for better desktop/tablet layout
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login to GameWise',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email input field
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password input field
                  TextField(
                    controller: _passwordController,
                    obscureText: true, // hides password input
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login button (email + password)
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),

                  // Divider with "or"
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.black54)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("or"),
                      ),
                      Expanded(child: Divider(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google sign-in button
                  OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Log in with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigation: Back to home
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                        (route) => false, // Clear the entire navigation stack
                      );
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
