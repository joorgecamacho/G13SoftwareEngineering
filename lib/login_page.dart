/// Login Page of the Gamewise Flutter App.
/// 
/// This page allows users to login using email/password or Google sign-in.
/// On successful login, users are navigated to the DashboardPage.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// LoginPage is a StatefulWidget because we need to manage the state of the form fields.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// _LoginPageState handles the logic and UI of the login page.
class _LoginPageState extends State<LoginPage> {
  // Controllers to read text input from the TextFields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Handles login with email and password
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Basic validation: check if fields are empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    try {
      // Attempt to sign in with Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If login succeeds, navigate to DashboardPage and replace current page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );

    } on FirebaseAuthException catch (e) {
      // Handle different FirebaseAuth errors
      String message = '';

      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = 'Login failed: ${e.message}';
      }

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Handles login with Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '602783046019-5333cekolocth3ntgnbcgdummml1kg4l.apps.googleusercontent.com',
      ).signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credentials and sign in with Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to DashboardPage after successful Google Sign-In
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } catch (e) {
      // If Google Sign-In fails, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Add padding to the screen
        child: Column(
          children: [
            // Email TextField
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),

            // Password TextField
            TextField(
              controller: _passwordController,
              obscureText: true, // Hides password input
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),

            // Google Sign-In Button
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
Key Learning Points from this code:
- Use StatefulWidget when you need to manage input fields and async actions.
- Always validate user input before sending it to Firebase.
- Use Navigator.pushReplacement() to replace login page after a successful login.
- GoogleSignIn package allows easy authentication with a Google account.
- Handle errors properly and show user-friendly error messages.
*/