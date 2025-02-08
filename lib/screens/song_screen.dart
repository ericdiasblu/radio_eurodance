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
    // Configura a playlist no initState
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.setPlaylist(widget.playlist.songs);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.playlist.songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.playlist.songs[index].title),
                  onTap: () => audioProvider.playSong(widget.playlist.songs[index], index),
                );
              },
            ),
          ),
          if (audioProvider.currentSongTitle.isNotEmpty) ...[
            AudioProgressBar()
          ],
        ],
      ),
    );
  }
}
