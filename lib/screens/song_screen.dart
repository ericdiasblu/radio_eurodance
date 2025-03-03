import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';
import '../models/music.dart';

class SongsScreen extends StatefulWidget {
  final Playlist playlist;

  SongsScreen(this.playlist);

  @override
  _SongsScreenState createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  @override
  void initState() {
    super.initState();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Só define a playlist se ela tiver músicas
    if (widget.playlist.songs.isNotEmpty) {
      audioProvider.setPlaylist(widget.playlist.songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.playlist.name,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1E1E1E),
      ),
      body: Container(
        color: Color(0xFF1E1E1E),
        child: Column(
          children: [
            Expanded(
              child: widget.playlist.songs.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_off,
                      color: Colors.white54,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma música encontrada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Verifique a pasta no Google Drive',
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: widget.playlist.songs.length,
                itemBuilder: (context, index) {
                  var song = widget.playlist.songs[index];
                  // Use o método isFavorite para verificar pelo ID
                  bool isFavorite = audioProvider.isFavorite(song);

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
                      onTap: () => audioProvider.playSong(song, index),
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
            ),
            if (audioProvider.currentSongTitle.isNotEmpty) ...[
              AudioProgressBar(),
            ],
          ],
        ),
      ),
    );
  }
}