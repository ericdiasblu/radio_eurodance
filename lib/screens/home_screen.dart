import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/models/playlist.dart'; // Importa a função para obter as playlists
import '../models/music.dart';
import 'song_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Playlist> playlists = getPlaylists();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlists'),
      ),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(playlists[index].name),
              onTap: () {
                // Aqui você deve garantir que o Provider esteja configurado corretamente
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongsScreen(playlists[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
