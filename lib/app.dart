import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '/components/files_loader.dart';
import '/components/playback_control.dart';
import '/components/volume_control.dart';
import 'components/files_list.dart';

import 'states/files_controller.dart';
import 'utils/utils.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final FilesController filesController;
  @override
  void initState() {
    super.initState();
    filesController = context.get<FilesController>();
  }

  @override
  void dispose() {
    filesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        setState(() {
                          files.clear();
                        });
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
          body: files.isEmpty
              ? const FilesLoader()
              : Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: const [
                    FilesList(),
                    VolumeControl(),
                    PlaybackControl(),
                  ],
                ),
        );
      },
    );
  }
}
