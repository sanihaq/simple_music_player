// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:simple_music_player/utils.dart';

const INITIAL_VOLUME = 0.5;

class PlayerController {
  PlayerController({
    List<Mp3File> initialFiles = const [],
  })  : _files = createSignal(initialFiles),
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
    _player.setVolume(INITIAL_VOLUME);
    _player.playbackStateStream.listen((event) {
      playbackState.update((value) => event);
    });
  }

  final Signal<List<Mp3File>> _files;

  ReadableSignal<List<Mp3File>> get files => _files.readable;

  final SimpleAudio _player;

  SimpleAudio get player => _player;

  Signal<PlaybackState> playbackState = createSignal(PlaybackState.done);
  bool get isPlaying => playbackState.value == PlaybackState.play;

  Signal<double> volume = createSignal(INITIAL_VOLUME);
  bool get isMuted => volume.value == 0;

  Signal<bool> normalize = createSignal(false);

  normalizeVolume(bool value) {
    _player.normalizeVolume(value);
    normalize.update((_) => value);
  }

  void setVolume(double value) {
    _player.setVolume(value);
    volume.update((_) => value);
  }

  Future<void> play(String path) async {
    await _player.stop();
    await _player.open(path);
  }

  Future<void> stop() async {
    if (playbackState.value != PlaybackState.done) {
      _player.pause();
      // await _player.stop(); possible library error
    }
  }

  String convertSecondsToReadableString(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;

    return "$m:${s > 9 ? s : "0$s"}";
  }

  void addFile(Mp3File file) {
    _files.update((value) => [...value, file]);
    play(file.path);
  }

  void remove(UniqueKey id) {
    _files.update(
      (value) => value.where((file) => file.id != id).toList(),
    );
  }

  void dispose() {
    // _player.stop();
    playbackState.dispose();
    volume.dispose();
    normalize.dispose();
    _files.dispose();
  }
}
