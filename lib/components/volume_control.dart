import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../states/player_controller.dart';
import 'elements.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final PlaybackController playerController;
  double mutedVolume = 0;

  @override
  void initState() {
    super.initState();
    playerController = context.get<PlaybackController>();
    _prefs.then((SharedPreferences prefs) {
      final value = prefs.getDouble('volume');
      if (value != null) {
        playerController.setVolume(value);
        playerController.volume.update((_) => value);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SignalBuilder(
                signal: playerController.normalize,
                builder: (context, normalize, _) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Transform.scale(
                      scale: 0.8,
                      child: Tooltip(
                        message: "sound normalize",
                        waitDuration: const Duration(milliseconds: 900),
                        child: Switch(
                          value: normalize,
                          thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Icon(Icons.close);
                            }
                            return const Icon(Icons.equalizer);
                          }),
                          onChanged: (value) {
                            playerController.normalizeVolume(value);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SignalBuilder(
                    signal: playerController.volume,
                    builder: (context, volume, _) {
                      return Row(
                        children: [
                          SliderTheme(
                            data: Theme.of(context).sliderTheme.copyWith(
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 10),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 20),
                                ),
                            child: Slider(
                              value: volume,
                              max: 1,
                              onChanged: (value) {
                                playerController.setVolume(value);
                              },
                            ),
                          ),
                          CircleButton(
                            size: 30,
                            tooltip: "volume mute",
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
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SignalBuilder(
                signal: playerController.progress,
                builder: (context, value, _) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.linear,
                    width: value.isNaN
                        ? 0
                        : MediaQuery.of(context).size.width * value,
                    height: 4,
                    color: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
