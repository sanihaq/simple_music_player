import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../utils/consts.dart';
import '../states/player_controller.dart';
import '../utils/utils.dart';

class PlayerQueue extends StatefulWidget {
  const PlayerQueue({super.key, required this.setExpanded});
  final void Function(bool) setExpanded;

  @override
  State<PlayerQueue> createState() => _PlayerQueueState();
}

class _PlayerQueueState extends State<PlayerQueue> {
  bool _expanded = false;
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

  Widget getQueueItem(Mp3File file) {
    const imageSize = 46.0;
    final data = file.data;
    return Row(
      children: [
        if (data.artBytes != null)
          SizedBox(
            width: imageSize,
            child: Image.memory(data.artBytes!),
          )
        else
          const SizedBox(
            width: imageSize,
            height: imageSize,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title ?? "unknown"),
              Text(data.artist ?? "unknown"),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
        widget.setExpanded(_expanded);
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
        child: Padding(
          padding: EdgeInsets.only(
              left: 16.0, bottom: _expanded ? 110 : 78.0, top: 8.0),
          child: SignalBuilder(
            signal: playerController.queueList,
            builder: (context, files, _) {
              return files.isEmpty
                  ? const SizedBox()
                  : _expanded
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: files.length,
                              itemBuilder: (context, i) {
                                final file = files.toList()[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: getQueueItem(file),
                                );
                              },
                            ),
                          ],
                        )
                      : getQueueItem(files.first);
            },
          ),
        ),
      ),
    );
  }
}
