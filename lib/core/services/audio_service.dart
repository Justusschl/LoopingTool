import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  final _mainPlayer = AudioPlayer();
  final _loopPlayer = AudioPlayer();

  Duration? get duration => _mainPlayer.duration;
  Duration _position = Duration.zero;
  bool get isPlaying => _mainPlayer.playing;
  Duration get position => _position;

  AudioService() {
    _mainPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _mainPlayer.durationStream.listen((dur) {
      notifyListeners();
    });
  }

  Future<void> loadFile(String path) async {
    await _mainPlayer.setFilePath(path);
    await _loopPlayer.setFilePath(path);
    notifyListeners();
  }

  void play() => _mainPlayer.play();
  void pause() => _mainPlayer.pause();
  void seek(Duration pos) => _mainPlayer.seek(pos);

  void loopSegment(Duration start, Duration end, int loopCount, int breakSeconds) async {
    _loopPlayer.setLoopMode(LoopMode.off);
    int played = 0;
    
    void playNextLoop() async {
      if (played >= loopCount) return;
      await _loopPlayer.setClip(start: start, end: end);
      await _loopPlayer.seek(start);
      await _loopPlayer.play();
      played++;
    }

    _loopPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (played < loopCount) {
          await Future.delayed(Duration(seconds: breakSeconds));
          playNextLoop();
        }
      }
    });

    playNextLoop();
  }

  Duration get loopPlayerPosition => _loopPlayer.position;

  @override
  void dispose() {
    _mainPlayer.dispose();
    _loopPlayer.dispose();
    super.dispose();
  }
}
