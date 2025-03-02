import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:radio_eurodance/models/music.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getter para o AudioPlayer
  AudioPlayer get audioPlayer => _audioPlayer;

  // Playlist completa (todas as músicas carregadas)
  List<Song> _playlist = [];

  // Adicione este método à sua classe AudioProvider

  List<Playlist> getAllPlaylists() {
    // Criando uma playlist principal com todas as músicas disponíveis
    Playlist mainPlaylist = Playlist('Todas as músicas', _playlist);

    // Se você tiver playlists categorizadas no futuro, pode adicioná-las aqui
    List<Playlist> allPlaylists = [mainPlaylist];

    // Retorne todas as playlists disponíveis
    return allPlaylists;
  }

  // Lista de reprodução atualmente ativa (pode ser a playlist completa ou a lista de favoritos)
  List<Song> _currentPlayingList = [];

  String _currentSongTitle = '';
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  // Lista para armazenar músicas favoritas
  List<Song> _favorites = [];

  bool _isNextSongCalled = false; // Variável de controle

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
      if (state.processingState == ProcessingState.completed && !_isNextSongCalled) {
        _isNextSongCalled = true;
        nextSong();
        Future.delayed(Duration(milliseconds: 500), () {
          _isNextSongCalled = false;
        });
      }
    });
  }

  // Getter para a playlist
  List<Song> get playlist => _playlist;

  /// Carrega os favoritos salvos no SharedPreferences, preservando a ordem em que foram salvos.
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteIds = prefs.getStringList('favorites');

    if (favoriteIds != null) {
      // Cria um mapa para lookup rápido com base na _playlist.
      final Map<String, Song> songMap = { for (var song in _playlist) song.id : song };

      // Mapeia os IDs dos favoritos na ordem armazenada.
      _favorites = favoriteIds
          .where((id) => songMap.containsKey(id))
          .map((id) => songMap[id]!)
          .toList();

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
    // Atualiza a lista de reprodução ativa antes de definir a música
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

    playSong(nextSong, _currentSongIndex, playingList: _currentPlayingList).then((_) {
      _isNextSongCalled = false;
    });
  }



  /// Volta para a música anterior na lista de reprodução atual.
  void previousSong() {
    if (_currentPlayingList.isEmpty) return;

    int newIndex = (_currentSongIndex > 0) ? _currentSongIndex - 1 : _currentPlayingList.length - 1;

    if (newIndex >= 0 && newIndex < _currentPlayingList.length) {
      playSong(_currentPlayingList[newIndex], newIndex, playingList: _currentPlayingList);
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

