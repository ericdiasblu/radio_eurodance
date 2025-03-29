import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/music.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getter para o AudioPlayer
  AudioPlayer get audioPlayer => _audioPlayer;

  // Lista global com todas as músicas de todas as playlists
  final List<Song> _allSongs = [];

  // Playlist atualmente ativa (pode ser apenas uma das playlists carregadas)
  List<Song> _playlist = [];

  // Lista de reprodução atualmente ativa (pode ser a playlist ou a lista de favoritos)
  List<Song> _currentPlayingList = [];

  String _currentSongTitle = '';
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  int _currentSongIndex = 0;
  bool _isPlaying = false;
  bool _isNextSongCalled = false; // Variável de controle

  // Lista para armazenar IDs de músicas favoritas (global, com IDs únicos)
  List<String> _favoriteIds = [];
  // Lista para armazenar músicas favoritas (objetos completos)
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

      // Verifica se a música terminou e evita chamadas duplicadas
      if (state.processingState == ProcessingState.completed &&
          !_isNextSongCalled) {
        _isNextSongCalled = true;
        nextSong();
        Future.delayed(Duration(milliseconds: 500), () {
          _isNextSongCalled = false;
        });
      }
    });
  }

  // Getter para a playlist atualmente ativa
  List<Song> get playlist => _playlist;

  // Getter para a lista global de favoritos
  List<Song> get favorites => _favorites;

  /// Carrega os favoritos salvos no SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteIds = prefs.getStringList('favorites');
    if (favoriteIds != null) {
      _favoriteIds = favoriteIds;
      _updateFavoritesFromIds();
      notifyListeners();
    }
  }

  /// Atualiza a lista de favoritos com base nos IDs salvos e na lista global de músicas
  void _updateFavoritesFromIds() {
    final Map<String, Song> songMap = {};
    for (var song in _allSongs) {
      songMap[song.id] = song;
    }
    _favorites = _favoriteIds
        .where((id) => songMap.containsKey(id))
        .map((id) => songMap[id]!)
        .toList();

    _favorites.removeWhere((song) => song.title.isEmpty && song.url.isEmpty);
  }

  /// Define a playlist ativa e adiciona as músicas à lista global, sem duplicatas
  Future<void> setPlaylist(List<Song> songs) async {
    _playlist = songs;
    // Adiciona as músicas carregadas à lista global, se ainda não estiverem presentes
    for (var song in songs) {
      if (!_allSongs.any((s) => s.id == song.id)) {
        _allSongs.add(song);
      }
    }
    await loadFavorites();
    _currentPlayingList = _playlist;
    notifyListeners();
  }

  /// Toca uma música a partir de uma lista de reprodução personalizada, se fornecida
  Future<void> playSong(Song song, int index, {List<Song>? playingList}) async {
    _currentPlayingList = playingList ?? _playlist;
    _currentSongTitle = song.title;
    _currentSongIndex = index;
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
  }

  /// Inicia a reprodução de uma música, garantindo que a lista ativa seja a de favoritos, se a música for um favorito.
  Future<void> playFavoriteSong(Song song) async {
    int index = _favorites.indexOf(song);
    if (index != -1) {
      await playSong(song, index, playingList: List<Song>.from(_favorites));
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

  void debugCurrentSongIndex() {
    print('Índice atual da música: $_currentSongIndex');
  }

  void nextSong() {
    if (_currentPlayingList.isEmpty) return;
    _currentSongIndex = (_currentSongIndex + 1) % _currentPlayingList.length;
    Song nextSong = _currentPlayingList[_currentSongIndex];
    debugCurrentSongIndex();
    print('Tocando a próxima música: ${nextSong.title}');
    playSong(nextSong, _currentSongIndex,
        playingList: _currentPlayingList).then((_) {
      _isNextSongCalled = false;
    });
  }

  /// Volta para a música anterior na lista de reprodução atual.
  void previousSong() {
    if (_currentPlayingList.isEmpty) return;
    int newIndex =
    (_currentSongIndex > 0) ? _currentSongIndex - 1 : _currentPlayingList.length - 1;
    if (newIndex >= 0 && newIndex < _currentPlayingList.length) {
      playSong(_currentPlayingList[newIndex], newIndex,
          playingList: _currentPlayingList);
    }
  }

  Future<void> seek(double value) async {
    final newPosition =
    Duration(seconds: (value * _totalDuration.inSeconds).toInt());
    await _audioPlayer.seek(newPosition);
  }

  /// Adiciona uma música aos favoritos (caso ainda não esteja na lista)
  void addFavorite(Song song) {
    if (!_favoriteIds.contains(song.id)) {
      _favoriteIds.add(song.id);
      _favorites.add(song);
      saveFavorites();
      notifyListeners();
    }
  }

  /// Remove uma música dos favoritos
  void removeFromFavorites(Song song) {
    _favoriteIds.remove(song.id);
    _favorites.removeWhere((s) => s.id == song.id);
    saveFavorites();
    notifyListeners();
  }

  /// Verifica se uma música é favorita
  bool isFavorite(Song song) {
    return _favoriteIds.contains(song.id);
  }

  /// Salva a lista de IDs de favoritos no SharedPreferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds);
  }

  // Getters para informações de reprodução
  String get currentSongTitle => _currentSongTitle;
  double get progress => _progress;
  bool get isPlaying => _isPlaying;
  Duration get totalDuration => _totalDuration;

  /// Método para obter todas as playlists disponíveis (inclui "Todas as músicas")
  List<Playlist> getAllPlaylists() {
    Playlist mainPlaylist = Playlist(
      'Todas as músicas',
      'assets/home_image.png',
      _playlist,
    );
    List<Playlist> allPlaylists = [mainPlaylist];
    return allPlaylists;
  }
}


