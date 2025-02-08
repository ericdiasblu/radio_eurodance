import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:radio_eurodance/models/music.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  String _currentSongTitle = '';
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  AudioProvider() {
    _audioPlayer.positionStream.listen((position) {
      if (_totalDuration.inSeconds > 0) {
        _progress = position.inSeconds.toDouble() / _totalDuration.inSeconds.toDouble();
        notifyListeners();
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing; // Atualiza isPlaying
      notifyListeners(); // Notifica os ouvintes sobre a mudança
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
    });
  }

  void setPlaylist(List<Song> songs) {
    _playlist = songs;
    notifyListeners();
  }

  Future<void> playSong(Song song, int index) async {
    _currentSongTitle = song.title;
    _currentSongIndex = index;

    // Criação do MediaItem com os metadados
    final mediaItem = MediaItem(
      id: song.id,
      title: song.title,
    );

    await _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(song.url), // URL da música
        tag: mediaItem, // Adiciona o MediaItem
      ),
    );

    await _audioPlayer.play();
    _isPlaying = true; // Atualiza isPlaying antes de notificar
    notifyListeners();

    // Atualiza a notificação de áudio em segundo plano
    await JustAudioBackground.init();
  }

  Future<void> pauseSong() async {
    await _audioPlayer.pause();
    _isPlaying = false; // Atualiza isPlaying antes de notificar
    notifyListeners();
  }

  Future<void> resumeSong() async {
    await _audioPlayer.play();
    _isPlaying = true; // Atualiza isPlaying antes de notificar
    notifyListeners();
  }

  void nextSong() {
    if (_currentSongIndex < _playlist.length - 1) {
      playSong(_playlist[_currentSongIndex + 1], _currentSongIndex + 1);
    } else {
      playSong(_playlist[0], 0);
    }
  }

  void previousSong() {
    if (_currentSongIndex > 0) {
      playSong(_playlist[_currentSongIndex - 1], _currentSongIndex - 1);
    } else {
      playSong(_playlist[_playlist.length - 1], _playlist.length - 1);
    }
  }

  Future<void> seek(double value) async {
    final newPosition = Duration(seconds: (value * _totalDuration.inSeconds).toInt());
    await _audioPlayer.seek(newPosition);
  }

  String get currentSongTitle => _currentSongTitle;
  double get progress => _progress;
  bool get isPlaying => _isPlaying;
  Duration get totalDuration => _totalDuration;
}
