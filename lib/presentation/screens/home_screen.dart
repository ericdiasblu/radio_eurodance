import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/audio/audio_provider.dart';
import '../../data/providers/audio/playlist_provider.dart';
import '../widgets/audio_progress_bar.dart';
import '../widgets/image_slider.dart';
import 'song_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as playlists quando a tela for iniciada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaylistProvider>(context, listen: false).loadAllPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    // Configura a playlist principal se já carregou e ainda não estiver definida
    if (playlistProvider.initialized && audioProvider.playlist.isEmpty) {
      audioProvider.setPlaylist(playlistProvider.getAllSongs());
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
                Row(
                  children: [
                    SizedBox(width: 20),
                    Text(
                      'EuroMusic',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Imagem principal com sombra e cantos arredondados
                ImageSlider(
                  imagePaths: [
                    'assets/home_image1.png',
                    'assets/home_image2.png',
                    'assets/home_image3.png',
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

                // Mostrar indicador de carregamento ou lista de playlists
                playlistProvider.isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: playlistProvider.playlists.map((playlist) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongScreen(playlist),
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
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        playlist.imagePath,
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      if (playlist.songs.isNotEmpty)
                                        Positioned(
                                          right: 10,
                                          bottom: 10,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${playlist.songs.length}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
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
                SizedBox(height: 130),
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