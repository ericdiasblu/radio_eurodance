import 'package:flutter/material.dart';
import 'package:radio_eurodance/layout/audio_progress_bar.dart'; // Importe o novo widget

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioProgressBar(), // Utilize o novo widget aqui
          ],
        ),
      ),
    );
  }
}
