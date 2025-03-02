import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/models/playlist.dart';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';
import '../layout/image_slider.dart';
import '../models/music.dart';
import 'song_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Playlist> playlists = getPlaylists();

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    // Configura a playlist principal se ainda não estiver definida
    if (audioProvider.playlist.isEmpty) {
      audioProvider.setPlaylist(
          playlists.expand((playlist) => playlist.songs).toList());
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF023E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título do App
                SizedBox(height: 20),
                Text(
                  'EuroMusic',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                  ),
                ),
                SizedBox(height: 20),
                // Imagem principal com sombra e cantos arredondados
                // Dentro do seu build:
                ImageSlider(
                  imagePaths: [
                    'assets/home_image.png',
                    'assets/home_image.png',
                    'assets/home_image.png',

                  ],
                ),

                SizedBox(height: 30),
                // Título das Playlists
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Playlists Destaque',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Lista de Playlists com rolagem horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: playlists.map((playlist) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongsScreen(playlist),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    playlist.imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: 150,
                                alignment: Alignment.center,
                                child: Text(
                                  playlist.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20), // Espaço inferior para finalizar o scroll
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: audioProvider.currentSongTitle.isNotEmpty
          ? AudioProgressBar()
          : null,
    );
  }
}
