import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'public_profile_page.dart';

class DiscoverUsersPage extends StatefulWidget {
  const DiscoverUsersPage({super.key});

  @override
  State<DiscoverUsersPage> createState() => _DiscoverUsersPageState();
}

class _DiscoverUsersPageState extends State<DiscoverUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Not logged in."));
    }

    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    return FutureBuilder<DocumentSnapshot>(
      future: currentUserRef.get(),
      builder: (context, currentUserSnapshot) {
        if (!currentUserSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentUserData = currentUserSnapshot.data!.data() as Map<String, dynamic>;
        final following = List<String>.from(currentUserData['following'] ?? []);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search users by name or bio...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final userId = doc.id;
                    final userData = doc.data() as Map<String, dynamic>;

                    final name = (userData['name'] ?? '').toString().toLowerCase();
                    final bio = (userData['bio'] ?? '').toString().toLowerCase();

                    final matchesSearch = name.contains(_searchQuery) || bio.contains(_searchQuery);

                    // Exclude self, already followed users, and apply search filter
                    return userId != currentUser.uid && 
                           !following.contains(userId) && 
                           matchesSearch;
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(child: Text("No users found."));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userDoc = users[index];
                      final userData = userDoc.data() as Map<String, dynamic>;

                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.deepPurpleAccent),
                        title: Text(userData['name'] ?? 'No Name'),
                        subtitle: Text(userData['bio'] ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfilePage(userId: userDoc.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
