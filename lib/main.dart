import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/audio/provider/audio_provider.dart';
import 'package:radio_eurodance/router/router.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioProvider()),
      ],
      child: const RadioEurodanceApp(),
    ),
  );
}

class RadioEurodanceApp extends StatelessWidget {
  const RadioEurodanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Fundo preto
        primaryColor: Color(0xFF023E8A), // azul
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFC1FF72), // Verde-limão
          secondary: Color(0xFF0A84FF), // Azul para botões secundários
          background: Colors.black, // Fundo principal
          surface: Color(0xFF1E1E1E), // Cinza escuro para cards e menus
          error: Color(0xFFFF3B30), // Vermelho para alertas
          onPrimary: Colors.black, // Texto sobre elementos primários
          onSecondary: Colors.white, // Texto sobre elementos secundários
          onBackground: Colors.white, // Texto sobre fundo preto
          onSurface: Colors.white70, // Texto sobre superfícies escuras
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFC1FF72), // Verde-limão
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}
