import 'package:flutter_solidart/flutter_solidart.dart';

import '../utils/utils.dart';

class FilesController {
  FilesController({
    List<Mp3File> initialFiles = const [],
  }) : _files = createSignal(initialFiles);

  final Signal<List<Mp3File>> _files;
  ReadableSignal<List<Mp3File>> get files => _files.readable;

  final Signal<bool> isSelecting = createSignal(false);
  final Signal<bool> isLoading = createSignal(false);

  void addFile(Mp3File file) {
    _files.update((value) => [...value, file]);
  }

  void addFiles(List<Mp3File> files) {
    _files.update((value) => [...value, ...files]);
  }

  void clearFiles() {
    _files.update((value) => []);
  }

  void dispose() {
    _files.dispose();
    isSelecting.dispose();
    isLoading.dispose();
  }
}
