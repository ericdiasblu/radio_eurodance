import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/models/playlist.dart';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';
import '../models/music.dart';
import 'song_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Playlist> playlists = getPlaylists();

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    // Verifica se a playlist já foi configurada
    if (audioProvider.playlist.isEmpty) {
      audioProvider.setPlaylist(playlists.expand((playlist) => playlist.songs).toList());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Rádio EuroDance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFC1FF72),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongsScreen(playlists[index]),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 50,
                      color: Color(0xFFC1FF72),
                    ),
                    SizedBox(height: 10),
                    Text(
                      playlists[index].name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: audioProvider.currentSongTitle.isNotEmpty
          ? AudioProgressBar()
          : null,
    );
  }
}
