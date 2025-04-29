// Flutter Material UI library
import 'package:flutter/material.dart';
// Firebase Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication to identify the user
import 'package:firebase_auth/firebase_auth.dart';

/// Page for editing a specific game's details.
/// Can handle games from either a general collection or a nested list.
class EditGamePage extends StatefulWidget {
  final String gameId; // ID of the game document
  final Map<String, dynamic> gameData; // Initial game data to populate the form
  final String? listId; // Optional: if editing a game inside a list

  const EditGamePage({
    super.key,
    required this.gameId,
    required this.gameData,
    this.listId,
  });

  @override
  State<EditGamePage> createState() => _EditGamePageState();
}

class _EditGamePageState extends State<EditGamePage> {
  final _formKey = GlobalKey<FormState>(); // Used for validating the form
  late TextEditingController _titleController;
  late TextEditingController _reviewController;

  // Default values pre-filled in the form
  String _selectedPlatform = 'PC';
  String _selectedStatus = 'Played';
  int _rating = 3;

  /// Initializes the form fields with data passed through the widget
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.gameData['title'] ?? '');
    _reviewController = TextEditingController(text: widget.gameData['review'] ?? '');
    _selectedPlatform = widget.gameData['platform'] ?? 'PC';
    _selectedStatus = widget.gameData['status'] ?? 'Played';
    _rating = widget.gameData['rating'] ?? 3;
  }

  /// Saves the updated game information to Firestore
  Future<void> _save() async {
    // Validate form before saving
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Choose collection path based on whether this game is part of a list
    final baseRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final gameRef = widget.listId != null
        ? baseRef.collection('lists').doc(widget.listId).collection('games').doc(widget.gameId)
        : baseRef.collection('games').doc(widget.gameId);

    // Update the document in Firestore
    await gameRef.update({
      'title': _titleController.text.trim(),
      'platform': _selectedPlatform,
      'status': _selectedStatus,
      'review': _reviewController.text.trim(),
      'rating': _rating,
    });

    // Show confirmation and return to previous screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game updated successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Game'), // Page title
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Game title input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Game Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the game title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Platform selection dropdown
              DropdownButtonFormField<String>(
                value: _selectedPlatform,
                items: [
                  'PC', 'PlayStation 5', 'PlayStation 4', 'PlayStation 3',
                  'Xbox Series S/X', 'Xbox One', 'Xbox 360',
                  'Nintendo Switch', 'Nintendo DS', 'Nintendo 3DS',
                  'Game Boy', 'Game Boy Advance', 'Game Boy Color',
                  'iOS', 'Android', 'Mac', 'Linux', 'Web', 'Mobile'
                ].map((platform) {
                  return DropdownMenuItem(
                    value: platform,
                    child: Text(platform),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlatform = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Platform'),
              ),
              const SizedBox(height: 16),

              // Status selection dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Played', 'Playing', 'Wishlist'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 16),

              // Review input
              TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
              const SizedBox(height: 16),

              // Rating stars
              const Text('Rating'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      _rating > index ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
