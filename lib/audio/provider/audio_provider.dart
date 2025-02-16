import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:radio_eurodance/models/music.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Playlist completa (todas as músicas carregadas)
  List<Song> _playlist = [];

  // Lista de reprodução atualmente ativa (pode ser a playlist completa ou a lista de favoritos)
  List<Song> _currentPlayingList = [];

  String _currentSongTitle = '';
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  // Lista para armazenar músicas favoritas
  List<Song> _favorites = [];

  AudioProvider() {
    _audioPlayer.positionStream.listen((position) {
      if (_totalDuration.inSeconds > 0) {
        _progress =
            position.inSeconds.toDouble() / _totalDuration.inSeconds.toDouble();
        notifyListeners();
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
    });
  }

  /// Carrega os favoritos salvos no SharedPreferences, preservando a ordem em que foram salvos.
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteIds = prefs.getStringList('favorites');

    if (favoriteIds != null) {
      // Cria um mapa para lookup rápido com base na _playlist.
      final Map<String, Song> songMap = { for (var song in _playlist) song.id : song };

      // Mapeia os IDs dos favoritos na ordem armazenada.
      _favorites = favoriteIds.map((id) => songMap[id] ?? Song(id, '', '')).toList();

      // Remove itens inválidos (músicas sem título e URL)
      _favorites.removeWhere((song) => song.title.isEmpty && song.url.isEmpty);
      notifyListeners();
    }
  }

  /// Define a playlist completa e, em seguida, carrega os favoritos.
  Future<void> setPlaylist(List<Song> songs) async {
    _playlist = songs;
    await loadFavorites();
    // Inicialmente, a lista de reprodução ativa é a playlist completa.
    _currentPlayingList = _playlist;
    notifyListeners();
  }

  /// Toca uma música a partir de uma lista de reprodução personalizada, se fornecida.
  Future<void> playSong(Song song, int index, {List<Song>? playingList}) async {
    _currentSongTitle = song.title;
    _currentSongIndex = index;

    // Se uma lista personalizada for fornecida, ela se torna a lista ativa; caso contrário, usa a _playlist.
    if (playingList != null) {
      _currentPlayingList = playingList;
    } else {
      _currentPlayingList = _playlist;
    }

    // Verifica se a URL da música é válida
    if (song.url.isEmpty) {
      print('URL da música está vazia: ${song.title}');
      return;
    }

    final mediaItem = MediaItem(
      id: song.id,
      title: song.title,
    );

    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(song.url),
          tag: mediaItem,
        ),
      );

      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Erro ao reproduzir a música: $e');
    }

    await JustAudioBackground.init();
  }

  /// Inicia a reprodução de uma música, garantindo que a lista ativa seja a de favoritos, se a música for um favorito.
  Future<void> playFavoriteSong(Song song) async {
    print(_favorites);
    int index = _favorites.indexOf(song);
    if (index != -1) {
      _currentPlayingList = _favorites; // Define a lista de reprodução atual como a lista de favoritos
      await playSong(song, index, playingList: _currentPlayingList);
    } else {
      print('A música não está nos favoritos.');
    }
  }

  Future<void> pauseSong() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeSong() async {
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  /// Avança para a próxima música na lista de reprodução atual.
  void nextSong() {
    if (_currentPlayingList.isEmpty) return;
    if (_currentSongIndex < _currentPlayingList.length - 1) {
      playSong(
        _currentPlayingList[_currentSongIndex + 1],
        _currentSongIndex + 1,
        playingList: _currentPlayingList,
      );
    } else {
      playSong(
        _currentPlayingList[0],
        0,
        playingList: _currentPlayingList,
      );
    }
  }

  /// Volta para a música anterior na lista de reprodução atual.
  void previousSong() {
    if (_currentPlayingList.isEmpty) return;
    if (_currentSongIndex > 0) {
      playSong(
        _currentPlayingList[_currentSongIndex - 1],
        _currentSongIndex - 1,
        playingList: _currentPlayingList,
      );
    } else {
      playSong(
        _currentPlayingList[_currentPlayingList.length - 1],
        _currentPlayingList.length - 1,
        playingList: _currentPlayingList,
      );
    }
  }

  Future<void> seek(double value) async {
    final newPosition =
    Duration(seconds: (value * _totalDuration.inSeconds).toInt());
    await _audioPlayer.seek(newPosition);
  }

  List<Song> get favorites => _favorites;

  void addFavorite(Song song) {
    if (!_favorites.contains(song)) {
      _favorites.add(song);
      saveFavorites();
      notifyListeners();
    }
  }

  void removeFromFavorites(Song song) {
    _favorites.remove(song);
    saveFavorites();
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = _favorites.map((song) => song.id).toList();
    await prefs.setStringList('favorites', favoriteIds);
  }

  String get currentSongTitle => _currentSongTitle;
  double get progress => _progress;
  bool get isPlaying => _isPlaying;
  Duration get totalDuration => _totalDuration;
}
