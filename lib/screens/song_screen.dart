import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';
import '../models/music.dart';

class SongScreen extends StatefulWidget {
  final Playlist playlist;

  const SongScreen(this.playlist, {Key? key}) : super(key: key);

  @override
  _SongScreenState createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  @override
  void initState() {
    super.initState();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    if (widget.playlist.songs.isNotEmpty) {
      audioProvider.setPlaylist(widget.playlist.songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: true);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: mediaQuery.size.height * 0.35,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Playlist Image or Placeholder
                      Image.asset(
                        widget.playlist.imagePath,
                        // Certifique-se de que o caminho está correto
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint("Erro ao carregar a imagem: $error");
                          return _buildPlaceholderImage();
                        },
                      ),
                      // Dark Gradient Overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ],
                  ),
                  title: Text(
                    widget.playlist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 43, bottom: 16),
                );
              },
            ),
            backgroundColor: Color(0xFF1E1E1E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Play Button and Song Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.playlist.songs.length} músicas',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.playlist.songs.isNotEmpty
                        ? () => audioProvider.playSong(
                            widget.playlist.songs.first, 0)
                        : null,
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text('Reproduzir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Song List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var song = widget.playlist.songs[index];
                bool isFavorite = audioProvider.isFavorite(song);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => audioProvider.playSong(song, index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorite ? Colors.blue : Colors.white70,
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
                    ),
                  ),
                );
              },
              childCount: widget.playlist.songs.length,
            ),
          ),

          // Bottom padding for AudioProgressBar
          SliverToBoxAdapter(
            child: SizedBox(
              height: audioProvider.currentSongTitle.isNotEmpty ? 80 : 0,
            ),
          ),
        ],
      ),

      // Audio Progress Bar at the bottom
      bottomSheet: audioProvider.currentSongTitle.isNotEmpty
          ? const AudioProgressBar()
          : null,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(
          Icons.music_note,
          color: Colors.white54,
          size: 64,
        ),
      ),
    );
  }
}
