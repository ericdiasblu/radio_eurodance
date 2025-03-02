import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/layout/audio_progress_bar.dart';
import 'package:radio_eurodance/audio/provider/audio_provider.dart';
import 'package:radio_eurodance/models/music.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método para buscar músicas em todas as playlists
  void _searchSongs(BuildContext context, String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final allPlaylists = audioProvider.getAllPlaylists(); // Você precisará implementar este método

    List<Song> results = [];

    for (var playlist in allPlaylists) {
      for (var song in playlist.songs) {
        if (song.title.toLowerCase().contains(query.toLowerCase())) {
          results.add(song);
        }
      }
    }

    setState(() {
      _searchResults = results;
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF023E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar músicas...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _isSearching = false;
                      });
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => _searchSongs(context, value),
              ),
            ),
            Expanded(
              child: _isSearching && _searchResults.isEmpty
                  ? Center(
                child: Text(
                  'Nenhuma música encontrada',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
                  : !_isSearching
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Busque suas músicas favoritas',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var song = _searchResults[index];
                  bool isFavorite = audioProvider.favorites.contains(song);

                  return Card(
                    color: Color(0xFF2A2A2A),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        song.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Criar uma playlist temporária com os resultados da busca
                        List<Song> searchPlaylist = List.from(_searchResults);
                        audioProvider.setPlaylist(searchPlaylist);
                        audioProvider.playSong(song, index);
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.blue : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isFavorite) {
                                  audioProvider.removeFromFavorites(song);
                                } else {
                                  audioProvider.addFavorite(song);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: audioProvider.currentSongTitle.isNotEmpty
          ? AudioProgressBar()
          : null,
    );
  }
}