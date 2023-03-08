import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../states/files_controller.dart';
import '../states/player_controller.dart';
import '../utils/consts.dart';

class FilesList extends StatefulWidget {
  const FilesList({super.key});

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  late final FilesController filesController;
  late final PlaybackController playerController;

  @override
  void initState() {
    super.initState();
    filesController = context.get<FilesController>();
    playerController = context.get<PlaybackController>();
  }

  @override
  void dispose() {
    filesController.dispose();
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: filesController.files,
      builder: (context, files, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: kBottomCollapsedSize + 2),
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (ctx, index) {
              final file = files[index];
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    child: Image.memory(file.data.artBytes!),
                  ),
                  title: Text(file.data.title ?? file.path.split("/").last),
                  subtitle: Text(file.data.artist ?? "unknown"),
                  onTap: () async {
                    playerController.addToQueue(file);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
