import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../states/files_controller.dart';
import '../utils/utils.dart';

class FilesLoader extends StatelessWidget {
  const FilesLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final filesController = context.get<FilesController>();
    final isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    return SignalBuilder(
      signal: filesController.isLoading,
      builder: (context, isLoading, _) {
        return Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SignalBuilder(
                  signal: filesController.isSelecting,
                  builder: (context, isDisabled, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () => loadAndAddFiles(
                                  context, filesController, false),
                          child: const Text("load files"),
                        ),
                        if (!isMobile)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              onPressed: isDisabled
                                  ? null
                                  : () => loadAndAddFiles(
                                      context, filesController, false),
                              child: const Text("load files and folders"),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}
