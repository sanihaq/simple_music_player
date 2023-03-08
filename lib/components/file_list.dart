import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_music_player/components/player.dart';

import '../consts.dart';
import '../controller.dart';
import '../utils.dart';

class FilesList extends StatefulWidget {
  const FilesList({super.key});

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  late final PlayerController playerController;
  final List<Mp3File> files = [];
  bool isDisabled = false;
  bool isLoading = false;

  Future<int> loadFiles({required bool recursive}) async {
    setState(() {
      isDisabled = true;
    });
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    setState(() {
      isLoading = true;
    });

    int newlyAdded = 0;

    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      final paths = await findMP3Files(dir, recursive);
      final newFiles = await Future.wait(
          paths.map((e) async => await mp3FileFromPath(e)).toList());
      for (var e in newFiles) {
        if (!files.any((el) => el.path == e.path)) {
          files.add(e);
          newlyAdded++;
        }
      }
    }
    setState(() {
      isDisabled = false;
      isLoading = false;
    });

    return newlyAdded;
  }

  @override
  void initState() {
    super.initState();
    playerController = context.get<PlayerController>();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  SnackBar showNewlyAddedMsg(int newlyAdded) {
    return showMsg(newlyAdded == 0
        ? "No new file found!"
        : "$newlyAdded new file${newlyAdded > 1 ? "s" : ""} added");
  }

  SnackBar showMsg(String msg) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: kBottomCollapsedSize),
      duration: const Duration(seconds: 2),
      content: Text(msg),
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Player"),
        actions: [
          IconButton(
            onPressed: isDisabled
                ? null
                : () async {
                    final newFiles = await loadFiles(recursive: false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(showNewlyAddedMsg(newFiles));
                    }
                  },
            icon: const Icon(Icons.add),
            tooltip: "load files",
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
      body: files.isEmpty && !playerController.isPlaying
          ? Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () async {
                                  final newFiles =
                                      await loadFiles(recursive: false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        showNewlyAddedMsg(newFiles));
                                  }
                                },
                          child: const Text("load only files"),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () async {
                                  final newFiles =
                                      await loadFiles(recursive: true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        showNewlyAddedMsg(newFiles));
                                  }
                                },
                          child: const Text("load files and folders"),
                        ),
                      ],
                    ),
            )
          : Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: kBottomCollapsedSize + 2),
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
                              file.data.title ?? file.path.split("/").last),
                          subtitle: Text(file.data.artist ?? "unknown"),
                          onTap: () async {
                            playerController.addFile(file);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Player(),
              ],
            ),
    );
  }
}
