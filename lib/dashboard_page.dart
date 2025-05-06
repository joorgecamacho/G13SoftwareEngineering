import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'add_game_page.dart';
import 'create_list_page.dart';
import 'edit_profile_page.dart';
import 'edit_game_page.dart';
import 'view_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }
  
  Future<void> deleteGameEverywhere(String gameId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // 1. Delete from "My Games"
  await userRef.collection('games').doc(gameId).delete();

  // 2. Fetch all user lists
  final listsSnapshot = await userRef.collection('lists').get();

  for (final listDoc in listsSnapshot.docs) {
    final listId = listDoc.id;
    final gameDocRef = userRef
        .collection('lists')
        .doc(listId)
        .collection('games')
        .doc(gameId);

    final gameDoc = await gameDocRef.get();
    if (gameDoc.exists) {
      await gameDocRef.delete();
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("GameWise Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurpleAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.videogame_asset, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(user?.email ?? '', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.gamepad),
              title: const Text("My Games"),
              selected: _selectedIndex == 0,
              onTap: () => _navigateTo(0),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("My Lists"),
              selected: _selectedIndex == 1,
              onTap: () => _navigateTo(1),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              selected: _selectedIndex == 2,
              onTap: () => _navigateTo(2),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildGamesView(context, user),
          _buildListsView(context, user),
          _buildProfileView(context, user),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGamePage()));
              },
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 1
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListPage()));
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  Widget _buildGamesView(BuildContext context, User? user) {
  final gamesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('games')
      .orderBy('createdAt', descending: true);

  return Container(
  color: const Color(0xFF1E1E2C),
  padding: const EdgeInsets.all(16),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Games',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search games...',
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: gamesRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('You haven\'t added any games yet.',
                      style: TextStyle(color: Colors.white70)),
                );
              }

              final games = snapshot.data!.docs.where((doc) {
                final title = (doc['title'] ?? '').toString().toLowerCase();
                return title.contains(_searchQuery);
              }).toList();

              if (games.isEmpty) {
                return const Center(
                  child: Text('No matching games found.',
                      style: TextStyle(color: Colors.white70)),
                );
              }

              return ListView.separated(
                itemCount: games.length,
                separatorBuilder: (_, __) => const Divider(indent: 72, endIndent: 16, thickness: 0.4, color: Colors.white24),
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
                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Game?'),
                          content: const Text('Are you sure you want to delete this game?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) async {
                      await deleteGameEverywhere(game.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Game deleted from My Games and all lists')),
                      );
                    },
                    child: ListTile(
                      leading: data['coverUrl'] != null && data['coverUrl'] != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(data['coverUrl'], width: 50, height: 50, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.videogame_asset, color: Colors.deepPurpleAccent),
                      title: Text(data['title'] ?? 'No Title',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data['platform'] != null) Text('Platform: ${data['platform']}', style: const TextStyle(color: Colors.white70)),
                          if (data['releaseDate'] != null) Text('Release: ${data['releaseDate']}', style: const TextStyle(color: Colors.white70)),
                          if (data['rating'] != null) Text('Rating: ${data['rating']}/5', style: const TextStyle(color: Colors.amber)),
                          if (data['review'] != null && data['review'].toString().trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('"${data['review']}"', style: const TextStyle(color: Colors.white60, fontStyle: FontStyle.italic)),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditGamePage(gameId: game.id, gameData: data)),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  ),
);
}
  Widget _buildListsView(BuildContext context, User? user) {
  final listsRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('lists')
      .orderBy('createdAt', descending: true);

  return Container(
    color: const Color(0xFF1E1E2C),
    padding: const EdgeInsets.all(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Lists',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: listsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You haven\'t created any lists yet.',
                        style: TextStyle(color: Colors.white70)),
                  );
                }

                final lists = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: lists.length,
                  separatorBuilder: (_, __) => const Divider(indent: 72, endIndent: 16, thickness: 0.4, color: Colors.white24),
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final data = list.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(list.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete List?'),
                            content: const Text('Are you sure you want to delete this list?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('lists')
                            .doc(list.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('List deleted')),
                        );
                      },
                      child: ListTile(
                        leading: const Icon(Icons.list_alt, color: Colors.deepPurpleAccent),
                        title: Text(
                          data['title'] ?? 'No Title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: data['description'] != null && data['description'].toString().trim().isNotEmpty
                            ? Text(data['description'], style: const TextStyle(color: Colors.white70))
                            : null,
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewListPage(listId: list.id, listData: data),
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
          ),
        ],
      ),
    ),
  );
}

Widget _buildProfileView(BuildContext context, User? user) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

      final gamesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('games')
          .orderBy('createdAt', descending: true);

      final listsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('lists')
          .orderBy('createdAt', descending: true);

      return Container(
        color: const Color(0xFF1E1E2C),
        child: Row(
          children: [
            // LEFT PANEL: Profile Info
            Container(
              width: 300,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.deepPurpleAccent),
                  const SizedBox(height: 16),
                  Text(data['name'] ?? 'No Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(user?.email ?? 'No email', style: const TextStyle(color: Colors.black54)),
                  if ((data['bio'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(data['bio'], textAlign: TextAlign.center),
                  ],
                  if ((data['location'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Text(data['location']),
                    ]),
                  ],
                  if ((data['age'] ?? 0) != 0) ...[
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.cake, size: 18),
                      const SizedBox(width: 4),
                      Text('Age: ${data['age']}'),
                    ]),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C5364), // same as the dark gradient tone
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
            // RIGHT PANEL: Recent games and lists with clearer sections
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    // Recently Added Games Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recently Added Games',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: gamesRef.limit(5).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                final docs = snapshot.data!.docs;
                                if (docs.isEmpty) {
                                  return const Text('No recent games', style: TextStyle(color: Colors.white70));
                                }
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final game = docs[index].data() as Map<String, dynamic>;
                                    return ListTile(
                                      dense: true,
                                      leading: game['coverUrl'] != null && game['coverUrl'] != ''
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Image.network(game['coverUrl'], width: 40, height: 40, fit: BoxFit.cover),
                                            )
                                          : const Icon(Icons.videogame_asset, color: Colors.deepPurpleAccent),
                                      title: Text(game['title'] ?? 'No Title', style: const TextStyle(color: Colors.white)),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Recently Created Lists Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recently Created Lists',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: listsRef.limit(5).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                final docs = snapshot.data!.docs;
                                if (docs.isEmpty) {
                                  return const Text('No recent lists', style: TextStyle(color: Colors.white70));
                                }
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final list = docs[index].data() as Map<String, dynamic>;
                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.list_alt, color: Colors.deepPurpleAccent),
                                      title: Text(list['title'] ?? 'No Title', style: const TextStyle(color: Colors.white)),
                                      subtitle: list['description'] != null
                                          ? Text(list['description'], style: const TextStyle(color: Colors.white70))
                                          : null,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      );
    },
  );
}


}
