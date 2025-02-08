import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/audio/provider/audio_provider.dart';

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentSongTitle.isNotEmpty) {
          return Container(
            height: 120,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  audioProvider.currentSongTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: audioProvider.progress,
                  onChanged: (value) {
                    audioProvider.seek(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(Duration(
                        seconds: (audioProvider.progress * audioProvider.totalDuration.inSeconds).toInt()))),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.skip_previous),
                          onPressed: audioProvider.previousSong,
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(audioProvider.isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (audioProvider.isPlaying) {
                              audioProvider.pauseSong();
                            } else {
                              audioProvider.resumeSong();
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.skip_next),
                          onPressed: audioProvider.nextSong,
                        ),
                      ],
                    ),
                    Text(_formatDuration(audioProvider.totalDuration)),
                  ],
                ),
              ],
            ),
          );
        }
        return Container(); // Retorna um Container vazio se não houver música
      },
    );
  }
}
