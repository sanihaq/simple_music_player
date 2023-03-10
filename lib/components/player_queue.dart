import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../states/others.dart';
import '../utils/consts.dart';
import '../states/player_controller.dart';
import '../utils/utils.dart';

class PlayerQueue extends StatelessWidget {
  const PlayerQueue({super.key});

  Widget buildQueueItem(BuildContext context, Mp3File file) {
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title ?? "unknown",
                  style: Theme.of(context).textTheme.bodyLarge,
                  softWrap: false,
                  maxLines: 1,
                ),
                Text(
                  data.artist ?? "unknown",
                  style: Theme.of(context).textTheme.bodySmall,
                  softWrap: false,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerController = context.get<PlaybackController>();
    final expanded = context.observe<bool>(OtherSignals.expandQueue);
    return GestureDetector(
      onTap: () => expandQueue.update((value) => !value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: double.infinity,
        height: expanded
            ? MediaQuery.of(context).size.height
            : kBottomCollapsedSize,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: expanded
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
              left: 16.0, bottom: expanded ? 110 : 76.0, top: 8.0),
          child: SignalBuilder(
            signal: playerController.queueList,
            builder: (context, files, _) {
              return files.isEmpty
                  ? const SizedBox()
                  : expanded
                      ? FutureBuilder(
                          future:
                              Future.delayed(const Duration(milliseconds: 100)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) return const SizedBox();
                            return ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: files.length,
                              itemBuilder: (context, i) {
                                final file = files.toList()[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Stack(
                                    children: [
                                      buildQueueItem(context, file),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: IconButton(
                                              onPressed: () => playerController
                                                  .remove(file.id),
                                              tooltip: "remove from queue",
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          })
                      : buildQueueItem(context, files.first);
            },
          ),
        ),
      ),
    );
  }
}
