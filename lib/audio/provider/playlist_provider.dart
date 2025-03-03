import 'package:flutter/foundation.dart';
import '../../models/music.dart';
import '../../models/playlist.dart';
import '../../services/google_drive_service.dart';


class PlaylistProvider extends ChangeNotifier {
  final List<Playlist> _playlists = [];
  final GoogleDriveService _driveService = GoogleDriveService();
  bool _isLoading = false;
  bool _initialized = false;

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  PlaylistProvider() {
    _playlists.addAll(getPlaylists());
  }

  Future<void> loadAllPlaylists() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      Map<String, List<Song>> loadedSongs = await _driveService.loadAllPlaylists(_playlists);

      // Atualiza cada playlist com as músicas carregadas
      for (var playlist in _playlists) {
        if (loadedSongs.containsKey(playlist.name)) {
          // Atualiza as músicas na playlist
          playlist.songs.clear();
          playlist.songs.addAll(loadedSongs[playlist.name]!);
        }
      }

      _initialized = true;
    } catch (e) {
      print("Erro ao carregar playlists: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtém todas as músicas de todas as playlists
  List<Song> getAllSongs() {
    return _playlists.expand((playlist) => playlist.songs).toList();
  }
}