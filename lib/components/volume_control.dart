import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../states/player_controller.dart';
import 'elements.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double mutedVolume = 0;
  late final PlaybackController playerController;

  @override
  void initState() {
    super.initState();
    playerController = context.get<PlaybackController>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Volume "),
                SignalBuilder(
                  signal: playerController.volume,
                  builder: (context, volume, _) {
                    return Row(
                      children: [
                        CircleButton(
                          size: 25,
                          onPressed: () {
                            if (playerController.isMuted) {
                              playerController.setVolume(mutedVolume);
                            } else {
                              mutedVolume = volume;
                              playerController.setVolume(0);
                            }
                          },
                          child: Icon(
                            playerController.isMuted
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                          ),
                        ),
                        Slider(
                          value: volume,
                          max: 1,
                          onChanged: (value) {
                            playerController.setVolume(value);
                          },
                        ),
                      ],
                    );
                  },
                ),
                const Text("Normalize "),
                SignalBuilder(
                  signal: playerController.normalize,
                  builder: (context, normalize, _) {
                    return Checkbox(
                      value: normalize,
                      onChanged: (value) {
                        playerController.normalizeVolume(value!);
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SignalBuilder(
                    signal: playerController.progress,
                    builder: (context, value, _) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 900),
                        width: value == 0 || value.isNaN
                            ? 0
                            : MediaQuery.of(context).size.width * value,
                        color: Colors.blue,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
