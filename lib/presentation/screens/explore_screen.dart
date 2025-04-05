import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import '../../data/models/music.dart';
import '../../data/providers/audio/audio_provider.dart';
import '../widgets/audio_progress_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _EnhancedExploreScreenState createState() => _EnhancedExploreScreenState();
}

class _EnhancedExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchSongs(BuildContext context, String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final allPlaylists = audioProvider.getAllPlaylists();

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

  void _quickSearch(String category) {
    _searchController.text = category;
    _searchSongs(context, category);
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e Subtítulo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Buscar Músicas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Encontre suas músicas favoritas',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de Pesquisa
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
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => _searchSongs(context, value),
                ),
              ),

              // Resultados da Pesquisa
              Expanded(
                child: _buildSearchResults(audioProvider),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: audioProvider.currentSongTitle.isNotEmpty
          ? AudioProgressBar()
          : null,
    );
  }

  Widget _buildSearchResults(AudioProvider audioProvider) {
    if (_isSearching && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma música encontrada',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    if (!_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Busque suas músicas favoritas',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return OpenContainer(
      closedColor: Colors.transparent,
      closedBuilder: (context, openContainer) => ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          var song = _searchResults[index];
          bool isFavorite = audioProvider.isFavorite(song);

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                song.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                List<Song> searchPlaylist = List.from(_searchResults);
                audioProvider.setPlaylist(searchPlaylist);
                audioProvider.playSong(song, index);
              },
              trailing: IconButton(
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
            ),
          );
        },
      ),
      openBuilder: (context, closeContainer) => Container(), // Placeholder
      transitionType: ContainerTransitionType.fade,
    );
  }
}