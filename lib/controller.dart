// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:simple_music_player/consts.dart';
import 'package:simple_music_player/utils.dart';

class PlayerController {
  PlayerController({
    Mp3File? currentFile,
    List<Mp3File> initialFiles = const [],
  })  : _files = createSignal(initialFiles),
        _currentFile = createSignal(currentFile),
        _player = SimpleAudio(
          onSkipNext: (_) => debugPrint("Next"),
          onSkipPrevious: (_) => debugPrint("Prev"),
          onNetworkStreamError: (player) {
            debugPrint("Network Stream Error");
            player.stop();
          },
          onDecodeError: (player) {
            debugPrint("Decode Error");
            player.stop();
          },
        ) {
    _player.setVolume(kInitialVolume);
    _player.playbackStateStream.listen((event) {
      playbackState.update((value) => event);
      if (event == PlaybackState.done) next();
    });
    player.progressStateStream.listen((event) {
      final value = event.position.toDouble() / event.duration.toDouble();
      if (progress.value != value) progress.update((_) => value);
    });
  }

  final Signal<List<Mp3File>> _files;

  final Signal<Mp3File?> _currentFile;

  ReadableSignal<List<Mp3File>> get files => _files.readable;

  ReadableSignal<Mp3File?> get currentFile => _currentFile.readable;

  final SimpleAudio _player;

  SimpleAudio get player => _player;

  Signal<PlaybackState> playbackState = createSignal(PlaybackState.done);
  bool get isPlaying => playbackState.value == PlaybackState.play;

  Signal<double> volume = createSignal(kInitialVolume);
  bool get isMuted => volume.value == 0;

  Signal<bool> normalize = createSignal(false);

  Signal<double> progress = createSignal(0);

  normalizeVolume(bool value) {
    _player.normalizeVolume(value);
    normalize.update((_) => value);
  }

  void setVolume(double value) {
    _player.setVolume(value);
    volume.update((_) => value);
  }

  Future<void> play(Mp3File file) async {
    await _player.stop();
    await _player.open(file.path);
    _currentFile.update((_) => file);
  }

  Future<void> next() async {
    if (files.value.isEmpty) {
      _currentFile.update((_) => null);
      return;
    }
    final file = files.value.first;
    await play(file);
    remove(file.id);
  }

  Future<void> stop() async {
    if (playbackState.value != PlaybackState.done) {
      _player.pause();
      // await _player.stop(); // possible library error
    }
  }

  String convertSecondsToReadableString(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;

    return "$m:${s > 9 ? s : "0$s"}";
  }

  void addFile(Mp3File file) {
    if (_currentFile.value == null) {
      play(file);
    } else {
      _files.update((value) => [...value, file.copyWith(id: UniqueKey())]);
    }
  }

  void remove(UniqueKey id) {
    _files.update(
      (value) => value.where((file) => file.id != id).toList(),
    );
  }

  void dispose() {
    playbackState.dispose();
    volume.dispose();
    normalize.dispose();
    _files.dispose();
  }
}
