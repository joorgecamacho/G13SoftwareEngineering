import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// You can move this function to another utils file if you want later
Future<void> saveGame({
  required String title,
  required String platform,
  required String status,
  required String review,
  required int rating,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final gamesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('games');

  await gamesRef.add({
    'title': title,
    'platform': platform,
    'status': status,
    'review': review,
    'rating': rating,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

class AddGamePage extends StatefulWidget {
  const AddGamePage({super.key});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final _titleController = TextEditingController();
  final _platformController = TextEditingController();
  final _reviewController = TextEditingController();
  String _status = 'Played';
  int _rating = 5;

  void _save() async {
    await saveGame(
      title: _titleController.text.trim(),
      platform: _platformController.text.trim(),
      status: _status,
      review: _reviewController.text.trim(),
      rating: _rating,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game saved successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Game')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Game Title'),
            ),
            TextField(
              controller: _platformController,
              decoration: const InputDecoration(labelText: 'Platform'),
            ),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(labelText: 'Review'),
            ),
            DropdownButton<String>(
              value: _status,
              items: ['Played', 'Playing', 'Wishlist'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            Slider(
              value: _rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value.round();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Game'),
            ),
          ],
        ),
      ),
    );
  }
}
