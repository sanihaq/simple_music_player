// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:simple_music_player/utils/consts.dart';
import 'package:simple_music_player/utils/utils.dart';

class PlaybackController {
  static PlaybackController? _instance;

  PlaybackController._()
      : _queueList = createSignal([]),
        _currentFile = createSignal(null) {
    _player = SimpleAudio(
      onSkipNext: (_) {
        if (PlaybackController.instance.queueList.value.isNotEmpty) {
          PlaybackController.instance.next();
        }
      },
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

  static PlaybackController get instance {
    return _instance ??= PlaybackController._();
  }

  late final SimpleAudio _player;

  final Signal<List<Mp3File>> _queueList;
  final Signal<Mp3File?> _currentFile;
  final Signal<bool> _isLoop = createSignal(false);
  final Signal<double> volume = createSignal(kInitialVolume);
  final Signal<bool> normalize = createSignal(false);
  final Signal<double> progress = createSignal(0);
  final Signal<PlaybackState> playbackState = createSignal(PlaybackState.done);

  SimpleAudio get player => _player;
  ReadableSignal<List<Mp3File>> get queueList => _queueList.readable;
  ReadableSignal<Mp3File?> get currentFile => _currentFile.readable;
  ReadableSignal<bool> get isLoop => _isLoop.readable;
  bool get isMuted => volume.value == 0;
  bool get isPlaying => playbackState.value == PlaybackState.play;

  normalizeVolume(bool value) {
    _player.normalizeVolume(value);
    normalize.update((_) => value);
  }

  void setVolume(double value) async {
    await _player.setVolume(value);
    volume.update((_) => value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
  }

  Future<void> play(Mp3File file) async {
    await _player.stop();
    await _player.open(file.path);
    await _player.setMetadata(file.data);
    _currentFile.update((_) => file);
  }

  Future<void> toggleLoop() async {
    _isLoop.update((value) => !value);
    await _player.loopPlayback(_isLoop.value);
  }

  Future<void> next() async {
    if (queueList.value.isEmpty) {
      _currentFile.update((_) => null);
      return;
    }
    final file = queueList.value.first;
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

  void addToQueue(Mp3File file) {
    if (_currentFile.value == null) {
      play(file);
    } else {
      _queueList.update((value) => [...value, file.copyWith(id: UniqueKey())]);
    }
  }

  void remove(UniqueKey id) {
    _queueList.update(
      (value) => value.where((file) => file.id != id).toList(),
    );
  }

  void dispose() {
    _queueList.dispose();
    _currentFile.dispose();
    _isLoop.dispose();
    volume.dispose();
    normalize.dispose();
    progress.dispose();
    playbackState.dispose();
  }
}
