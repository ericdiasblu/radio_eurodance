import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:radio_eurodance/audio/provider/audio_provider.dart';
import 'package:radio_eurodance/router/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja pronto antes de iniciar

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
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF023E8A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFC1FF72),
          secondary: const Color(0xFF0A84FF),
          background: Colors.black,
          surface: const Color(0xFF1E1E1E),
          error: const Color(0xFFFF3B30),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white70,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFC1FF72),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}
