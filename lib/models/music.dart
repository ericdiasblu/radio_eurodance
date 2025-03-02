// music.dart
class Song {
  final String id;
  final String title;
  final String url;

  Song(this.id,this.title, this.url);
}

class Playlist {
  final String name;
  final String imagePath; // Caminho da imagem
  final List<Song> songs;

  Playlist(this.name, this.imagePath, this.songs);
}
