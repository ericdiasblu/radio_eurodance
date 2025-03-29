import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/music.dart';

class GoogleDriveService {
  final String apiKey = "AIzaSyAkBHHqjeJa0C8vcWrKJeLA8977M9iqm5s";

  // Método para buscar músicas de uma pasta específica
  Future<List<Song>> getSongsFromFolder(String folderId) async {
    final url = Uri.parse(
      "https://www.googleapis.com/drive/v3/files?q='$folderId'+in+parents&fields=files(id,name,mimeType)&key=$apiKey",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Song> songs = [];
        int songId = 1;

        for (var file in data['files']) {
          // Verifica se o arquivo é de áudio
          if (_isAudioFile(file)) {
            String fileId = file['id'];
            String fileName = cleanupFileName(file['name'].toString());

            // Gera um ID único combinando folderId e songId
            String uniqueSongId = "${folderId}_$songId";
            songs.add(Song.fromGoogleDrive(uniqueSongId, fileName, fileId, folderId));
            songId++;
          }
        }

        print("🎵 Encontradas ${songs.length} músicas na pasta $folderId");
        return songs;
      } else {
        print("Erro na API: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exceção ao buscar músicas: $e");
      return [];
    }
  }

  // Verifica se o arquivo é um arquivo de áudio
  bool _isAudioFile(Map<String, dynamic> file) {
    return file['mimeType'].toString().contains('providers') ||
        file['name'].toString().toLowerCase().endsWith('.mp3') ||
        file['name'].toString().toLowerCase().endsWith('.wav') ||
        file['name'].toString().toLowerCase().endsWith('.ogg');
  }

  // Função para limpar o nome do arquivo
  String cleanupFileName(String fileName) {
    // Remove a extensão do arquivo
    if (fileName.contains('.')) {
      fileName = fileName.substring(0, fileName.lastIndexOf('.'));
    }

    // Remove IDs e sequências indesejadas do nome
    fileName = fileName
        .replaceAll(RegExp(r'\(ID:[^)]*\)'), '')
        .replaceAll(RegExp(r'\[ID:[^\]]*\]'), '')
        .replaceAll(RegExp(r'[a-zA-Z0-9_-]{25,}'), '')
        .trim();

    return fileName;
  }

  // Carrega todas as músicas de todas as pastas definidas nas playlists
  Future<Map<String, List<Song>>> loadAllPlaylists(List<Playlist> playlists) async {
    Map<String, List<Song>> loadedPlaylists = {};

    for (var playlist in playlists) {
      if (playlist.folderId.isNotEmpty) {
        try {
          List<Song> songs = await getSongsFromFolder(playlist.folderId);
          loadedPlaylists[playlist.name] = songs;
        } catch (e) {
          print("Erro ao carregar playlist ${playlist.name}: $e");
          loadedPlaylists[playlist.name] = [];
        }
      }
    }

    return loadedPlaylists;
  }
}
