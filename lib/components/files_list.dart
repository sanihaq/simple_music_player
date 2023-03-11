import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../states/files_controller.dart';
import '../states/player_controller.dart';
import '../utils/consts.dart';

class FilesList extends StatelessWidget {
  const FilesList({super.key});

  @override
  Widget build(BuildContext context) {
    final filesController = context.get<FilesController>();
    final playerController = context.get<PlaybackController>();
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
                  title: Text(
                    file.data.title ?? file.path.split("/").last,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    file.data.artist ?? "unknown",
                    softWrap: false,
                    maxLines: 1,
                  ),
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
