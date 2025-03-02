import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/audio/provider/audio_provider.dart';

class AudioProgressBar extends StatefulWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  @override
  _AudioProgressBarState createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  bool _isExpanded = true;
  final double expandedHeight = 150;
  final double collapsedHeight = 40;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentSongTitle.isNotEmpty) {
          return GestureDetector(
            // Detecta arraste vertical para alternar o estado
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! > 5 && _isExpanded) {
                setState(() {
                  _isExpanded = false;
                });
              } else if (details.primaryDelta! < -5 && !_isExpanded) {
                setState(() {
                  _isExpanded = true;
                });
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              height: _isExpanded ? expandedHeight : collapsedHeight,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: _isExpanded ? 12 : 4,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF393737),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: _isExpanded
                    ? Column(
                  key: ValueKey('expanded'),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Título da música
                    Flexible(
                      child: Text(
                        audioProvider.currentSongTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Slider minimalista
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        activeTrackColor: Color(0xFFC1FF72),
                        inactiveTrackColor: Colors.white24,
                        thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 6),
                        thumbColor: Color(0xFFC1FF72),
                        overlayColor: Color(0xFFC1FF72).withOpacity(0.2),
                        overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: audioProvider.progress,
                        onChanged: (value) {
                          audioProvider.seek(value);
                        },
                      ),
                    ),
                    // Controles de reprodução e tempos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tempo atual
                        Text(
                          _formatDuration(Duration(
                              seconds: (audioProvider.progress *
                                  audioProvider.totalDuration.inSeconds)
                                  .toInt())),
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        // Botões de controle
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous,
                                  color: Colors.white, size: 28),
                              onPressed: audioProvider.previousSong,
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (audioProvider.isPlaying) {
                                  audioProvider.pauseSong();
                                } else {
                                  audioProvider.resumeSong();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFC1FF72),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  audioProvider.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 28,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.skip_next,
                                  color: Colors.white, size: 28),
                              onPressed: audioProvider.nextSong,
                            ),
                          ],
                        ),
                        // Duração total
                        Text(
                          _formatDuration(audioProvider.totalDuration),
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                )
                    : Center(
                  key: ValueKey('collapsed'),
                  child: GestureDetector(
                    onTap: _toggleExpanded,
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
