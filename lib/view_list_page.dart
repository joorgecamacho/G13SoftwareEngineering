import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_game_page.dart';
import 'edit_game_page.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(widget.listData['title'] ?? 'List'),
        iconTheme: const IconThemeData(color: Colors.white), // <-- ADD THIS LINE
      ),

      backgroundColor: const Color(0xFF1E1E2C),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
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
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.separated(
            itemCount: games.length,
            separatorBuilder: (_, __) => const Divider(
              indent: 72,
              endIndent: 16,
              thickness: 0.4,
              color: Colors.white24,
            ),
            itemBuilder: (context, index) {
              final game = games[index];
              final data = game.data() as Map<String, dynamic>;

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
                      content: const Text('Are you sure you want to delete this game from this list?'),
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
                onDismissed: (_) async {
                  await gamesCollectionRef.doc(game.id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Game deleted!')),
                  );
                },
                child: ListTile(
                  leading: data['coverUrl'] != null && data['coverUrl'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(data['coverUrl'], width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.videogame_asset, color: Colors.deepPurpleAccent),
                  title: Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['platform'] != null)
                        Text('Platform: ${data['platform']}', style: TextStyle(color: Colors.grey[400])),
                      if (data['releaseDate'] != null)
                        Text('Release: ${data['releaseDate']}', style: TextStyle(color: Colors.grey[400])),
                      if (data['rating'] != null)
                        Text('Rating: ${data['rating']}/5', style: TextStyle(color: Colors.amber[200])),
                      if (data['review'] != null && data['review'].toString().trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '"${data['review']}"',
                            style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditGamePage(
                          gameId: game.id,
                          gameData: data,
                          listId: widget.listId,
                        ),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
