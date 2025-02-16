import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/audio/provider/audio_provider.dart';
import 'package:radio_eurodance/models/playlist.dart';
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
    audioProvider.setPlaylist(widget.playlist.songs);
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
              child: ListView.builder(
                itemCount: widget.playlist.songs.length,
                itemBuilder: (context, index) {
                  var song = widget.playlist.songs[index];
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

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? '${song.title} removido dos favoritos'
                                    : '${song.title} adicionado aos favoritos',
                              ),
                            ),
                          );
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
