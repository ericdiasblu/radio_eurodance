// music.dart
class Song {
  final String id;
  final String title;
  final String url;

  Song(this.id,this.title, this.url);
}

class Playlist {
  final String name;
  final List<Song> songs;

  Playlist(this.name, this.songs);
}
