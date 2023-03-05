import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:simple_music_player/utils.dart';

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
        );

  final Signal<List<Mp3File>> _files;

  ReadableSignal<List<Mp3File>> get files => _files.readable;

  final SimpleAudio _player;

  SimpleAudio get player => _player;

  PlaybackState playbackState = PlaybackState.done;
  bool get isPlaying => playbackState == PlaybackState.play;

  bool get isMuted => volume == 0;
  double trueVolume = 1;
  double volume = 1;
  bool normalize = false;

  double position = 0;
  double duration = 0;

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

  void play(String path) async {
    await player.stop();
    await player.open(path);
  }

  void dispose() {
    _files.dispose();
  }
}
