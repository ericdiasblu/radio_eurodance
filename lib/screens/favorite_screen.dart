import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Músicas Favoritas'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF023E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: audioProvider.favorites.isNotEmpty
            ? ListView.builder(
          itemCount: audioProvider.favorites.length,
          itemBuilder: (context, index) {
            final song = audioProvider.favorites[index];
            const itemMargin =
            EdgeInsets.symmetric(vertical: 8, horizontal: 16);
            const itemHeight = 75.0;
            const borderRadiusValue = 12.0;

            return Dismissible(
              key: Key(song.id),
              direction: DismissDirection.endToStart,
              background: Container(),
              confirmDismiss: (direction) async {
                // Retorna true para confirmar a exclusão
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: Text('Você tem certeza que deseja remover ${song.title} das favoritas?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                // Remover a música da lista com animação
                audioProvider.removeFromFavorites(song);

              },
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  AnimationController(
                    vsync: Navigator.of(context),
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
                child: Container(
                  margin: itemMargin,
                  height: itemHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadiusValue),
                    child: Card(
                      color: const Color(0xFF2A2A2A),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          audioProvider.playFavoriteSong(song);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        )
            : const Center(
          child: Text(
            'Nenhuma música favorita',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: audioProvider.currentSongTitle.isNotEmpty
          ? const AudioProgressBar()
          : null,
    );
  }
}
