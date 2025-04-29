// Flutter UI framework
import 'package:flutter/material.dart';
// Firebase Authentication for current user access
import 'package:firebase_auth/firebase_auth.dart';
// Firestore for retrieving user data and lists
import 'package:cloud_firestore/cloud_firestore.dart';

// Pages for navigation
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'create_list_page.dart';
import 'view_list_page.dart';

/// The DashboardPage is the main screen users see after logging in.
/// It displays their profile and lists, and provides options to manage them.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Logs the user out and redirects to the login page.
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current signed-in user

    // Reference to the current user's lists in Firestore
    final listsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('lists')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          // Logout icon in the top right corner
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigates to the CreateListPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateListPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        // Background gradient
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: Profile sidebar
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              child: _buildProfileHeader(context, user),
            ),

            // RIGHT: Lists content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Lists',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Real-time stream of user-created lists
                    StreamBuilder<QuerySnapshot>(
                      stream: listsRef.snapshots(),
                      builder: (context, snapshot) {
                        // While data is loading
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // If no data is found
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'You haven\'t created any lists yet.',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // Data exists: render the list
                        final lists = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lists.length,
                          itemBuilder: (context, index) {
                            final list = lists[index];
                            final data = list.data() as Map<String, dynamic>? ?? {};

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: Colors.white.withOpacity(0.9),
                              child: ListTile(
                                title: Text(
                                  data['title'] ?? 'No Title',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: data['description'] != null
                                    ? Text(data['description'])
                                    : null,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Navigate to view details of the selected list
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewListPage(
                                        listId: list.id,
                                        listData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the left-side profile header with user details and Edit Profile button.
  Widget _buildProfileHeader(BuildContext context, User? user) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        // While loading profile data
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Profile icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurpleAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                userData['name'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                user?.email ?? 'No email',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              // Optional bio section
              if ((userData['bio'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  userData['bio'],
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],

              // Optional location
              if ((userData['location'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.deepPurpleAccent),
                    const SizedBox(width: 4),
                    Text(
                      userData['location'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],

              // Optional age
              if ((userData['age'] ?? 0) != 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cake, size: 18, color: Colors.deepPurpleAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Age: ${userData['age']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Edit profile button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
