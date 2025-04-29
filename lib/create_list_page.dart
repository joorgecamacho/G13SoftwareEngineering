// Flutter UI library
import 'package:flutter/material.dart';
// Firebase Authentication to access the current user
import 'package:firebase_auth/firebase_auth.dart';
// Firebase Firestore to save lists
import 'package:cloud_firestore/cloud_firestore.dart';

/// Page that allows the user to create a new list (for organizing games).
class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  // Form key to validate the form fields
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Saves the new list to Firestore under the current user's document.
  void _saveList() async {
    if (!_formKey.currentState!.validate()) return; // Validate the form first

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is authenticated

    final listsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('lists');

    await listsRef.add({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(), // Timestamp for sorting
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('List created successfully!')), // Show success message
    );

    Navigator.pop(context); // Return to the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New List'), // Page title
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title input field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'List Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a list title'; // Validate title is not empty
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description input field (optional)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _saveList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Create List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
