import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_music_player/components/player_queue.dart';
import 'package:simple_music_player/states/others.dart';

import '/components/files_loader.dart';
import '/components/playback_control.dart';
import '/components/volume_control.dart';
import 'components/files_list.dart';

import 'states/files_controller.dart';
import 'utils/utils.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final filesController = context.get<FilesController>();
    return SignalBuilder(
      signal: filesController.files,
      builder: (context, files, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Simple Player"),
            actions: [
              SignalBuilder(
                signal: filesController.isSelecting,
                builder: (context, isDisabled, _) {
                  return IconButton(
                    onPressed: isDisabled
                        ? null
                        : () =>
                            loadAndAddFiles(context, filesController, false),
                    icon: const Icon(Icons.add),
                    tooltip: "load files",
                  );
                },
              ),
              const SizedBox(width: 4.0),
              IconButton(
                onPressed: files.isEmpty
                    ? null
                    : () async {
                        filesController.clearFiles();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(showMsg("files cleared"));
                        }
                      },
                icon: const Icon(Icons.close),
                tooltip: "clear files",
              ),
            ],
          ),
          body: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              if (files.isEmpty) const FilesLoader() else const FilesList(),
              const PlayerQueue(),
              const VolumeControl(),
              const PlaybackControl(),
            ],
          ),
        );
      },
    );
  }
}
