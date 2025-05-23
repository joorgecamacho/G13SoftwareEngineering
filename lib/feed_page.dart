import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'public_profile_page.dart';

class FeedPage extends StatelessWidget {
  FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Not Logged In"));
    }

    return Container(
      color: const Color(0xFF1E1E2C), // Dark background for Feed Page
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();
          final following = List<String>.from(data?['following'] ?? []);

          if (following.isEmpty) {
            return const Center(child: Text("You're not following anyone yet.", style: TextStyle(color: Colors.white)));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('posts')
                .where('authorId', whereIn: following)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, postsSnapshot) {
              if (!postsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = postsSnapshot.data!.docs;

              if (posts.isEmpty) {
                return const Center(child: Text("No activity from the users you follow.", style: TextStyle(color: Colors.white)));
              }

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postData = post.data() as Map<String, dynamic>;

                  return Card(
                    color: Colors.white.withOpacity(0.08), // Dark semi-transparent card
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: postData['profilePicUrl'] != null && postData['profilePicUrl'].toString().isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(postData['profilePicUrl']),
                                  radius: 24,
                                )
                              : const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.deepPurpleAccent,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                          title: Text(
                            postData['authorName'] ?? 'Unknown User',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            _formatTimestamp(postData['createdAt']),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PublicProfilePage(userId: postData['authorId']),
                              ),
                            );
                          },
                        ),
                        if (postData['coverUrl'] != null && postData['coverUrl'].toString().isNotEmpty)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                postData['coverUrl'],
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                postData['title'] ?? 'Unknown Game',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (postData['platform'] != null)
                                Text(
                                  'Platform: ${postData['platform']}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              if (postData['rating'] != null)
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (postData['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              if (postData['review'] != null && postData['review'].toString().trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '"${postData['review']}"',
                                    style: const TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
