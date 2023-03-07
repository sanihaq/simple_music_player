import 'dart:convert';

import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_music_player/consts.dart';
import 'package:simple_music_player/controller.dart';
import 'package:simple_music_player/utils.dart';
import 'package:simple_audio/simple_audio.dart';
import 'dart:io';

void main() {
  SimpleAudio.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Solid(
      providers: [
        SolidProvider<PlayerController>(
          create: () => PlayerController(),
          dispose: (controller) => controller.dispose(),
        ),
      ],
      child: const FilesList(),
    );
  }
}

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

  Future<void> loadFiles({required bool recursive}) async {
    setState(() {
      isDisabled = true;
    });
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    setState(() {
      isLoading = true;
    });

    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      final paths = await findMP3Files(dir, recursive);
      final newFiles = await Future.wait(
          paths.map((e) async => await mp3FileFromPath(e)).toList());
      for (var e in newFiles) {
        if (!files.any((el) => el.path == e.path)) files.add(e);
      }
    }
    setState(() {
      isDisabled = false;
      isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Player"),
        actions: [
          IconButton(
            onPressed: isDisabled
                ? null
                : () async => await loadFiles(recursive: false),
            icon: const Icon(Icons.add),
            tooltip: "load files only",
          )
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
                              : () async => await loadFiles(recursive: false),
                          child: const Text("load only files"),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () async => await loadFiles(recursive: true),
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

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool _expanded = false;
  double mutedVolume = 0;
  late final PlayerController playerController;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          width: double.infinity,
          height: _expanded
              ? MediaQuery.of(context).size.height
              : kBottomCollapsedSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _expanded
                ? null
                : const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: SignalBuilder(
            signal: playerController.files,
            builder: (context, files, _) {
              return ListView.builder(
                reverse: true,
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, i) {
                  final data = files.reversed.toList()[i].data;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        if (data.artBytes != null)
                          SizedBox(
                            width: 60,
                            child: Image.memory(data.artBytes!),
                          )
                        else
                          const SizedBox(
                            width: 60,
                            height: 60,
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.title ?? "unknown"),
                              Text(
                                data.album ?? "unknown",
                                overflow: TextOverflow.fade,
                              ),
                              Text(data.artist ?? "unknown"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     // if (_expanded)
          //     //   SignalBuilder(
          //     //     signal: playerController.files,
          //     //     builder: (context, files, _) {
          //     //       return ListView.builder(
          //     //         itemCount: files.length,
          //     //         itemBuilder: (context, i) {
          //     //           return ListTile(
          //     //             title: Text(files[i].path),
          //     //           );
          //     //         },
          //     //       );
          //     //     },
          //     //   ),
          //     Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: [
          //           Text(""),
          //           CircleButton(
          //             size: 40,
          //             onPressed: () {
          //               if (playerController.isPlaying) {
          //                 playerController.player.pause();
          //               } else {
          //                 playerController.player.play();
          //               }
          //             },
          //             child: SignalBuilder(
          //               signal: playerController.playbackState,
          //               builder: (context, _, __) {
          //                 return Icon(
          //                   playerController.isPlaying
          //                       ? Icons.pause_rounded
          //                       : Icons.play_arrow_rounded,
          //                   color: Colors.white,
          //                 );
          //               },
          //             ),
          //           ),
          //           const SizedBox(width: 8.0),
          //           CircleButton(
          //             size: 40,
          //             onPressed: playerController.stop,
          //             child: const Icon(Icons.stop, color: Colors.white),
          //           ),
          //         ],
          //       ),
          //     ),
          //     if (_expanded)
          //       Padding(
          //         padding: const EdgeInsets.only(left: 8.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             const Text("Volume "),
          //             SignalBuilder(
          //                 signal: playerController.volume,
          //                 builder: (context, volume, _) {
          //                   return Row(
          //                     children: [
          //                       CircleButton(
          //                         size: 25,
          //                         onPressed: () {
          //                           if (playerController.isMuted) {
          //                             playerController.setVolume(mutedVolume);
          //                           } else {
          //                             mutedVolume = volume;
          //                             playerController.setVolume(0);
          //                           }
          //                         },
          //                         child: Icon(
          //                           playerController.isMuted
          //                               ? Icons.volume_off
          //                               : Icons.volume_up,
          //                           color: Colors.white,
          //                         ),
          //                       ),
          //                       Slider(
          //                         value: volume,
          //                         max: 1,
          //                         onChanged: (value) {
          //                           playerController.setVolume(value);
          //                         },
          //                       ),
          //                     ],
          //                   );
          //                 }),
          //             const Text("Normalize "),
          //             SignalBuilder(
          //               signal: playerController.normalize,
          //               builder: (context, normalize, _) {
          //                 return Checkbox(
          //                   value: normalize,
          //                   onChanged: (value) {
          //                     playerController.normalizeVolume(value!);
          //                   },
          //                 );
          //               },
          //             ),
          //           ],
          //         ),
          //       ),
          //   ],
          // ),
          ),
    );
  }
}

class CircleButton extends StatelessWidget {
  const CircleButton(
      {required this.onPressed,
      required this.child,
      this.size = 35,
      this.color = Colors.blue,
      super.key});

  final void Function()? onPressed;
  final Widget child;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipOval(
        child: Material(
            color: color,
            child: InkWell(
                canRequestFocus: false, onTap: onPressed, child: child)),
      ),
    );
  }
}
