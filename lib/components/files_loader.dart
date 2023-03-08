import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import '../states/files_controller.dart';
import '../utils/utils.dart';

class FilesLoader extends StatefulWidget {
  const FilesLoader({super.key});

  @override
  State<FilesLoader> createState() => _FilesLoaderState();
}

class _FilesLoaderState extends State<FilesLoader> {
  late final FilesController filesController;

  @override
  void initState() {
    super.initState();
    filesController = context.get<FilesController>();
  }

  @override
  void dispose() {
    filesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          child: const Text("load only files"),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () => loadAndAddFiles(
                                  context, filesController, false),
                          child: const Text("load files and folders"),
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
