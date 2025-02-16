import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/layout/audio_progress_bar.dart'; // Importe o novo widget
import 'package:radio_eurodance/audio/provider/audio_provider.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context); // Acesse o AudioProvider

    return Scaffold(
      body: Container(
        color: Colors.yellow,
        child: Center(
          child: Text(
            'Explore Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      bottomNavigationBar: audioProvider.currentSongTitle.isNotEmpty
          ? AudioProgressBar() // Exibe a barra de progresso se a música estiver tocando
          : null, // Se não houver música tocando, não exibe a barra de progresso
    );
  }
}
