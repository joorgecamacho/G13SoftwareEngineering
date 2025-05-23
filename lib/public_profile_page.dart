import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  Map<String, dynamic>? userData;
  bool isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (widget.userId == currentUser?.uid) return; // Prevent viewing own profile here

    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (doc.exists) {
      final data = doc.data()!;
      final followers = List<String>.from(data['followers'] ?? []);
      final following = List<String>.from(data['following'] ?? []);
      setState(() {
        userData = data;
        followersCount = followers.length;
        followingCount = following.length;
        isFollowing = followers.contains(currentUser?.uid);
      });
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || widget.userId == currentUser.uid) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    final targetSnapshot = await userRef.get();
    final currentSnapshot = await currentUserRef.get();

    final followers = List<String>.from(targetSnapshot.data()?['followers'] ?? []);
    final following = List<String>.from(currentSnapshot.data()?['following'] ?? []);

    setState(() {
      if (isFollowing) {
        followers.remove(currentUser.uid);
        following.remove(widget.userId);
        followersCount--;
      } else {
        followers.add(currentUser.uid);
        following.add(widget.userId);
        followersCount++;
      }
      isFollowing = !isFollowing;
    });

    await userRef.update({'followers': followers});
    await currentUserRef.update({'following': following});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (widget.userId == currentUser?.uid) {
      return const Scaffold(
        body: Center(child: Text("You are viewing your own profile.")),
      );
    }

    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(userData!['name'] ?? 'User Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.deepPurpleAccent),
            const SizedBox(height: 16),
            Text(userData!['name'] ?? 'No Name', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(userData!['bio'] ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('Followers: $followersCount'),
            Text('Following: $followingCount'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
