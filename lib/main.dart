import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:simple_music_player/states/files_controller.dart';
import 'package:simple_music_player/states/others.dart';

import 'app.dart';
import 'states/player_controller.dart';

void main() {
  SimpleAudio.init();
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
          create: () => PlaybackController(),
          dispose: (controller) => controller.dispose(),
        ),
      ],
      signals: {OtherSignals.expandQueue: () => expandQueue},
      child: MaterialApp(
        title: 'Simple Music Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const App(),
      ),
    );
  }
}
