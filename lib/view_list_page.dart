import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_game_page.dart';
import 'edit_game_page.dart'; // New import for editing games

class ViewListPage extends StatefulWidget {
  final String listId;
  final Map<String, dynamic> listData;

  const ViewListPage({super.key, required this.listId, required this.listData});

  @override
  State<ViewListPage> createState() => _ViewListPageState();
}

class _ViewListPageState extends State<ViewListPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final gamesCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('lists')
        .doc(widget.listId)
        .collection('games');

    final gamesQuery = gamesCollectionRef.orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listData['title'] ?? 'List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGamePage(listId: widget.listId),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
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
        child: StreamBuilder<QuerySnapshot>(
          stream: gamesCollectionRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No games added to this list yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final games = snapshot.data!.docs;

            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final data = game.data() as Map<String, dynamic>? ?? {};

                return Dismissible(
                  key: Key(game.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Game?'),
                        content: const Text('Are you sure you want to delete this game?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await gamesCollectionRef.doc(game.id).delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Game deleted!')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading: data['coverUrl'] != null && data['coverUrl'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['coverUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.videogame_asset, size: 40),
                      title: Text(
                        data['title'] ?? 'No Title',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Platform: ${data['platform'] ?? 'Unknown'}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGamePage(
                              gameId: game.id,
                              gameData: data,
                              listId: widget.listId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
