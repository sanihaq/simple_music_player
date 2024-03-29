import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:simple_music_player/states/files_controller.dart';
import 'package:simple_music_player/states/others.dart';

import 'app.dart';
import 'states/player_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleAudio.init(
    dbusName: "com.github.sanihaq.simplePlayer",
    androidCompactActions: [0, 1],
    actions: [
      MediaControlAction.playPause,
      MediaControlAction.skipNext,
    ],
  );
  runApp(const AppContainer());
}

class AppContainer extends StatelessWidget {
  const AppContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Solid(
      providers: [
        SolidProvider<FilesController>(
          create: () => FilesController(),
          dispose: (controller) => controller.dispose(),
        ),
        SolidProvider<PlaybackController>(
          create: () => PlaybackController.instance,
          dispose: (controller) => controller.dispose(),
        ),
      ],
      signals: {OtherSignals.expandQueue: () => expandQueue},
      child: MaterialApp(
        title: 'Simple Music Player',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: const App(),
      ),
    );
  }
}
