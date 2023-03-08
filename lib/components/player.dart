import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_music_player/components/queue_llst.dart';

import '../states/player_controller.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool _expanded = false;
  double mutedVolume = 0;
  late final PlaybackController playerController;

  @override
  void initState() {
    super.initState();
    playerController = context.get<PlaybackController>();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: PlayerQueue(
            setExpanded: (v) => setState(() => _expanded = v),
          ),
        ),
      ],
    );
  }
}
