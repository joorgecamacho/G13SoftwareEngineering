import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_game_page.dart';

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
  if (user == null) return;

  final baseRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final gameId = baseRef.collection('games').doc().id;

  final gameData = {
    'id': gameId,
    'title': title,
    'platform': platform,
    'status': status,
    'review': review,
    'rating': rating,
    'coverUrl': coverUrl,
    'releaseDate': releaseDate,
    'genres': genres,
    'createdAt': FieldValue.serverTimestamp(),
  };

  await baseRef.collection('games').doc(gameId).set(gameData);

  if (listId != null) {
    await baseRef
        .collection('lists')
        .doc(listId)
        .collection('games')
        .doc(gameId)
        .set(gameData);
  }
}

class AddGamePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? listId;

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

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      final platformsList = widget.initialData!['platforms'] as List<dynamic>? ?? [];
      if (platformsList.isNotEmpty) {
        final platformName = platformsList[0]['platform']['name'] ?? 'PC';
        _selectedPlatform = platformName;
      }
      _coverUrl = widget.initialData!['background_image'];
      _releaseDate = widget.initialData!['released'];
      final genresList = widget.initialData!['genres'] as List<dynamic>? ?? [];
      _genres = genresList.map((g) => g['name'].toString()).toList();
    }
  }

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
          _selectedPlatform = platformName;
        }
        _coverUrl = selectedGame['background_image'] ?? '';
        _releaseDate = selectedGame['released'];
        final genresList = selectedGame['genres'] as List<dynamic>? ?? [];
        _genres = genresList.map((g) => g['name'].toString()).toList();
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Game'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        color: const Color(0xFF1E1E2C),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24.0),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openSearchPage,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text('Search Game', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5364),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Game Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the game title' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      items: [
                        'PC', 'PlayStation 5', 'PlayStation 4', 'PlayStation 3',
                        'Xbox Series S/X', 'Xbox One', 'Xbox 360',
                        'Nintendo Switch', 'Nintendo DS', 'Nintendo 3DS',
                        'Game Boy', 'Game Boy Advance', 'Game Boy Color', 'Mobile'
                      ].map((platform) => DropdownMenuItem(value: platform, child: Text(platform))).toList(),
                      onChanged: (value) => setState(() => _selectedPlatform = value!),
                      decoration: const InputDecoration(
                        labelText: 'Platform',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: ['Played', 'Playing', 'Wishlist'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                      onChanged: (value) => setState(() => _selectedStatus = value!),
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Review',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Rating', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setState(() => _rating = index + 1),
                          icon: Icon(
                            _rating > index ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5364),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
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
