import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio/provider/audio_provider.dart';
import '../layout/audio_progress_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Músicas Favoritas'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Container(
        color: const Color(0xFF1E1E1E),
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
              background: Container(
                margin: itemMargin,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                  child: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
              onDismissed: (direction) {
                audioProvider.removeFromFavorites(song);
              },
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

