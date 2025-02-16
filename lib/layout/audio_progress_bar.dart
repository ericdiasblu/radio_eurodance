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
            height: 150,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFF393737), // Fundo cinza escuro
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  audioProvider.currentSongTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Color(0xFFAE2012), // Verde-limão
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.red,
                    overlayColor: Colors.red.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: audioProvider.progress,
                    onChanged: (value) {
                      audioProvider.seek(value);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(Duration(
                          seconds: (audioProvider.progress * audioProvider.totalDuration.inSeconds).toInt())),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.skip_previous, color: Colors.white),
                          onPressed: audioProvider.previousSong,
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (audioProvider.isPlaying) {
                              audioProvider.pauseSong();
                            } else {
                              audioProvider.resumeSong();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFFC1FF72), // Verde-limão
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black, // Ícone preto para contraste
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.skip_next, color: Colors.white),
                          onPressed: audioProvider.nextSong,
                        ),
                      ],
                    ),
                    Text(
                      _formatDuration(audioProvider.totalDuration),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return Container(); // Retorna um Container vazio se não houver música tocando
      },
    );
  }
}
