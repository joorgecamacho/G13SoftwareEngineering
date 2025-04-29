// Flutter Material UI package
import 'package:flutter/material.dart';
// HTTP package for making API requests
import 'package:http/http.dart' as http;
// Dart package for decoding JSON responses
import 'dart:convert';

/// SearchGamePage allows users to search for video games using the RAWG API.
/// Results are displayed in a list, and users can select a game to return data back.
class SearchGamePage extends StatefulWidget {
  const SearchGamePage({super.key});

  @override
  State<SearchGamePage> createState() => _SearchGamePageState();
}

class _SearchGamePageState extends State<SearchGamePage> {
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();
  // List to store fetched games
  List<dynamic> _games = [];
  // Tracks if the app is currently fetching data
  bool _isLoading = false;

  /// Fetches game data from the RAWG.io API based on user's search query.
  Future<void> _searchGames() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return; // Don't perform a search if the field is empty

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final url = Uri.parse(
      'https://api.rawg.io/api/games?key=e8b316e7ebad41a3905354879d9e86ee&search=$query',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _games = data['results']; // Populate games list
      });
    } else {
      // Handle API fetch failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch games')),
      );
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Games'), // Page title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search input field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a game...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchGames, // Perform search
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Show loading spinner
                  : _games.isEmpty
                      ? const Center(child: Text('No games found')) // Show no results message
                      : ListView.builder(
                          itemCount: _games.length,
                          itemBuilder: (context, index) {
                            final game = _games[index];
                            return Card(
                              child: ListTile(
                                leading: game['background_image'] != null
                                    ? Image.network(
                                        game['background_image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.videogame_asset),
                                title: Text(game['name'] ?? 'No name'),
                                subtitle: Text('Released: ${game['released'] ?? 'Unknown'}'),
                                onTap: () {
                                  // Return the selected game data to the previous page
                                  Navigator.pop(context, {
                                    'title': game['name'] ?? '',
                                    'platforms': game['platforms'] ?? [],
                                    'background_image': game['background_image'] ?? '',
                                    'released': game['released'] ?? '',
                                    'genres': game['genres'] ?? [],
                                  });
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
