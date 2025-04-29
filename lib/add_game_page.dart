// Flutter UI toolkit
import 'package:flutter/material.dart';
// Firebase Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication for user management
import 'package:firebase_auth/firebase_auth.dart';
// Page for searching games via external API
import 'search_game_page.dart';

/// Helper function to save a new game to Firestore.
/// It handles whether the game is part of a specific list or the general collection.
Future<void> saveGame({
  required String title,
  required String platform,
  required String status,
  required String review,
  required int rating,
  String? coverUrl,
  String? releaseDate,
  List<String>? genres,
  String? listId,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // Ensure user is authenticated

  final baseRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  final gamesRef = listId != null
      ? baseRef.collection('lists').doc(listId).collection('games') // Game inside a list
      : baseRef.collection('games'); // Game at root level

  await gamesRef.add({
    'title': title,
    'platform': platform,
    'status': status,
    'review': review,
    'rating': rating,
    'coverUrl': coverUrl,
    'releaseDate': releaseDate,
    'genres': genres,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

/// AddGamePage allows users to manually add or search and add a new game.
class AddGamePage extends StatefulWidget {
  final Map<String, dynamic>? initialData; // Data if coming from Search page
  final String? listId; // List ID if adding into a list

  const AddGamePage({super.key, this.initialData, this.listId});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reviewController = TextEditingController();

  String _selectedPlatform = 'PC';
  String _selectedStatus = 'Played';
  int _rating = 3;
  String? _coverUrl;
  String? _releaseDate;
  List<String> _genres = [];

  /// Pre-fills form fields if initial data is provided (e.g., after a game search).
  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      final platformsList = widget.initialData!['platforms'] as List<dynamic>? ?? [];
      if (platformsList.isNotEmpty) {
        final platformName = platformsList[0]['platform']['name'] ?? 'PC';
        const allowedPlatforms = [
          'PC', 'PlayStation 5', 'PlayStation 4', 'PlayStation 3',
          'Xbox Series S/X', 'Xbox One', 'Xbox 360', 'Nintendo Switch',
          'iOS', 'Android', 'Mac', 'Linux', 'Web'
        ];
        if (allowedPlatforms.contains(platformName)) {
          _selectedPlatform = platformName;
        } else {
          _selectedPlatform = 'PC';
        }
      }
      _coverUrl = widget.initialData!['background_image'];
      _releaseDate = widget.initialData!['released'];
      final genresList = widget.initialData!['genres'] as List<dynamic>? ?? [];
      _genres = genresList.map((g) => g['name'].toString()).toList();
    }
  }

  /// Opens the SearchGamePage and populates fields with selected game data.
  Future<void> _openSearchPage() async {
    final selectedGame = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchGamePage()),
    );

    if (selectedGame != null) {
      setState(() {
        _titleController.text = selectedGame['title'] ?? '';

        final platformsList = selectedGame['platforms'] as List<dynamic>? ?? [];
        if (platformsList.isNotEmpty) {
          final platformName = platformsList[0]['platform']['name'] ?? 'PC';
          const allowedPlatforms = [
            'PC', 'PlayStation 5', 'PlayStation 4', 'PlayStation 3',
            'Xbox Series S/X', 'Xbox One', 'Xbox 360',
            'Nintendo Switch', 'Nintendo DS', 'Nintendo 3DS',
            'Game Boy', 'Game Boy Advance', 'Game Boy Color', 'Mobile'
          ];
          if (allowedPlatforms.contains(platformName)) {
            _selectedPlatform = platformName;
          } else {
            _selectedPlatform = 'PC';
          }
        }

        _coverUrl = selectedGame['background_image'] ?? '';
        _releaseDate = selectedGame['released'];
        final genresList = selectedGame['genres'] as List<dynamic>? ?? [];
        _genres = genresList.map((g) => g['name'].toString()).toList();
      });
    }
  }

  /// Saves the new game to Firestore.
  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await saveGame(
      title: _titleController.text.trim(),
      platform: _selectedPlatform,
      status: _selectedStatus,
      review: _reviewController.text.trim(),
      rating: _rating,
      coverUrl: _coverUrl ?? '',
      releaseDate: _releaseDate ?? '',
      genres: _genres,
      listId: widget.listId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game saved successfully!')),
    );

    Navigator.pop(context); // Return to the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Game'), // Page title
      ),
      body: Container(
        decoration: const BoxDecoration(
          // Background gradient
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
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500), // Limit form width
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Button to search games
                    ElevatedButton.icon(
                      onPressed: _openSearchPage,
                      icon: const Icon(Icons.search),
                      label: const Text('Search Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title input
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Game Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the game title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Platform dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      items: [
                        'PC', 'PlayStation 5', 'PlayStation 4', 'PlayStation 3',
                        'Xbox Series S/X', 'Xbox One', 'Xbox 360',
                        'Nintendo Switch', 'Nintendo DS', 'Nintendo 3DS',
                        'Game Boy', 'Game Boy Advance', 'Game Boy Color', 'Mobile'
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
                      decoration: const InputDecoration(
                        labelText: 'Platform',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status dropdown
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
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Review input
                    TextFormField(
                      controller: _reviewController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Review',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rating stars
                    const Text('Rating', style: TextStyle(fontSize: 16)),
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
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Game', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
