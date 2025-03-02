// playlists.dart
import 'package:flutter/cupertino.dart';

import 'music.dart'; // Importa a classe Song e Playlist

List<Playlist> getPlaylists() {
  return [
    Playlist(
        'Anos 90',
        'assets/anos90.webp', // Caminho da imagem
        [
          Song('1', '2 Raff - Dont Stop The Music',
              'https://drive.google.com/uc?export=download&id=1kGwVMLKmjjehr9sHn2epdiJjTKufM98p'),
          Song('2', '2 Unlimited - No Limit (1993)',
              'https://drive.google.com/uc?export=download&id=1RJ9M_mkkHoCGCWpzVGblg6e0Rd0IHRYK'),
          Song('3', '2 Unlimited - Twilight Zone',
              'https://drive.google.com/uc?export=download&id=19wbpQHcuadqG_wBcRDU0A8nq1IOMgMB5'),
          Song('4', 'Activate - Let Rhythm Take Control',
              'https://drive.google.com/uc?export=download&id=1WlRIhs39o3Xj09H4niQx5YEOw3T0hYyg'),
          Song('5', 'Afrika Bambaataa - Feel The Vibe (Extended Mix)',
              'https://drive.google.com/uc?export=download&id=1SGmpWqVxWGC46wwPfdQzpFUcTXkFGfvq'),
          Song('6', 'Antares - Ride On A Meteorite (Extended Mix)',
              'https://drive.google.com/uc?export=download&id=1qTFNm8QOC61p-PyqHgrxZJHGzmhxx_iN'),
          Song('7', 'Antares - You Belong To Me',
              'https://drive.google.com/uc?export=download&id=1Av3pRFutENWe2EsiivCWjyBNCPGaJCtA'),
          Song('8', 'B.G. The Prince Of Rap - The Colour Of My Dreams',
              'https://drive.google.com/uc?export=download&id=1Y7lGSyLVB1VdIxp5pXYNUocgFmnlz4a_'),
          Song('9', 'Best of 1995 Megamix - Eurodance',
              'https://drive.google.com/uc?export=download&id=1lCGD3bljeN8UR017D4y72yYYnvia0Nhc'),
          Song('10', 'Black White - Do You Know (Extended Version)',
              'https://drive.google.com/uc?export=download&id=1y8OHUBPoEKEvqh2atBpjFLR7iTTpbBkb'),
          Song('11', 'Cartouche - Touch The Sky (Euro Mix Extended)',
              'https://drive.google.com/uc?export=download&id=1poEGgsgLLVaGCkH3-l-zOfdYiI0Z1EY2'),
        ]),
    Playlist(
        'Anos 80',
        'assets/anos80.jpeg', // Caminho da imagem
        []),
    Playlist(
        'Anos 70',
        'assets/anos70.jpeg', // Caminho da imagem
        []),
    Playlist(
        'Anos 60',
        'assets/anos90.webp', // Caminho da imagem
        []),

    // Adicione mais playlists aqui
  ];
}
