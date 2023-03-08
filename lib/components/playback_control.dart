import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_audio/simple_audio.dart';

import '../controller.dart';
import 'elements.dart';

class PlaybackControl extends StatefulWidget {
  const PlaybackControl({super.key});

  @override
  State<PlaybackControl> createState() => _PlaybackControlState();
}

class _PlaybackControlState extends State<PlaybackControl> {
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

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 50),
        padding: EdgeInsets.only(bottom: _expanded ? 50.0 : 6.0),
        child: Container(
          height: 60,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              SignalBuilder(
                signal: playerController.currentFile,
                builder: (context, file, __) {
                  if (file == null) return const SizedBox();
                  const imageSize = 55.0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (file.data.artBytes != null)
                        SizedBox(
                          width: imageSize,
                          child: Image.memory(file.data.artBytes!),
                        )
                      else
                        const SizedBox(
                          width: imageSize,
                          height: imageSize,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file.data.title ?? "unknown"),
                            const SizedBox(height: 2.0),
                            Text(file.data.artist ?? "unknown"),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SignalBuilder(
                    signal: playerController.playbackState,
                    builder: (context, state, __) {
                      return CircleButton(
                        size: 40,
                        onPressed: state == PlaybackState.done
                            ? null
                            : () {
                                if (playerController.isPlaying) {
                                  playerController.player.pause();
                                } else {
                                  playerController.player.play();
                                }
                              },
                        child: Icon(
                          playerController.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8.0),
                  SignalBuilder(
                    signal: playerController.isLoop,
                    builder: (context, loop, __) {
                      return CircleButton(
                        size: 40,
                        onPressed: () async {
                          await playerController.toggleLoop();
                        },
                        child: Icon(
                          loop ? Icons.repeat_one : Icons.repeat,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8.0),
                  SignalBuilder(
                    signal: playerController.files,
                    builder: (context, files, __) {
                      return CircleButton(
                        size: 40,
                        onPressed: files.isEmpty ? null : playerController.next,
                        child: const Icon(Icons.skip_next, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
