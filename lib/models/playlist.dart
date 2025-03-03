import 'package:flutter/cupertino.dart';
import 'music.dart';

// Playlists iniciais com IDs de pastas do Google Drive
List<Playlist> getPlaylists() {
  return [
    Playlist(
      'Anos 90',
      'assets/anos90.webp',
      [], // Músicas serão carregadas dinamicamente
      folderId: '104yuR_u8wj7wXX-R3ud5_SAPjv20EgwC', // ID da pasta Anos 90
    ),
    Playlist(
      'Anos 80',
      'assets/anos80.jpeg',
      [],
      folderId: '17NDhTIPmL2zEz3P1pTeXlXR2UAwH7r4D', // Substitua pelo ID da pasta do Google Drive
    ),
    Playlist(
      'Anos 70',
      'assets/anos70.jpeg',
      [],
      folderId: '', // Substitua pelo ID da pasta do Google Drive
    ),
    Playlist(
      'Anos 60',
      'assets/anos90.webp',
      [],
      folderId: '', // Substitua pelo ID da pasta do Google Drive
    ),
  ];
}

// Função para atualizar as músicas em uma playlist
void updatePlaylistSongs(Playlist playlist, List<Song> songs) {
  playlist.songs.clear();
  playlist.songs.addAll(songs);
}