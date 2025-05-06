import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchGamePage extends StatefulWidget {
  const SearchGamePage({super.key});

  @override
  State<SearchGamePage> createState() => _SearchGamePageState();
}

class _SearchGamePageState extends State<SearchGamePage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<dynamic> _results = [];

  void _searchGames(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    final url = Uri.parse('https://api.rawg.io/api/games?key=6469bcadbd654cd790bf47c07943e8ab&search=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _results = data['results'];
      });
    } else {
      setState(() => _results = []);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchGames(query.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Search Game'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              onSubmitted: _searchGames,
              decoration: InputDecoration(
                hintText: 'Search for a game...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No results', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final game = _results[index];
                        return Card(
                          color: Colors.white.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: game['background_image'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      game['background_image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.videogame_asset, color: Colors.deepPurpleAccent),
                            title: Text(game['name'], style: const TextStyle(color: Colors.white)),
                            subtitle: game['released'] != null
                                ? Text('Released: ${game['released']}', style: const TextStyle(color: Colors.white70))
                                : null,
                            onTap: () => Navigator.pop(context, {
                              'title': game['name'],
                              'platforms': game['platforms'],
                              'background_image': game['background_image'],
                              'released': game['released'],
                              'genres': game['genres'],
                            }),
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
