class Song {
  final String id;
  final String title;
  final String url;
  final String playlistId;
  final String fileId;

  Song(this.id, this.title, this.url, this.playlistId, {this.fileId = ''});

  factory Song.fromGoogleDrive(String id, String title, String fileId, String playlistId) {
    String url = "https://drive.google.com/uc?export=download&id=$fileId";
    return Song(id, title, url, playlistId, fileId: fileId);
  }
}



class Playlist {
  final String name;
  final String imagePath;
  final List<Song> songs;
  final String folderId; // ID da pasta no Google Drive (opcional)

  Playlist(this.name, this.imagePath, this.songs, {this.folderId = ''});
}