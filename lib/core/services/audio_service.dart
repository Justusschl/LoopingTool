import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  final _player = AudioPlayer();

  Duration? get duration => _player.duration;
  Duration _position = Duration.zero;
  bool get isPlaying => _player.playing;
  Duration get position => _position;

  AudioService() {
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      notifyListeners();
    });
  }

  Future<void> loadFile(String path) async {
    await _player.setFilePath(path);
    notifyListeners(); // for duration
  }

  void play() => _player.play();
  void pause() => _player.pause();
  void seek(Duration pos) => _player.seek(pos);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}