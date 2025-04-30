import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  final _mainPlayer = AudioPlayer();
  final _loopPlayer = AudioPlayer();
  bool _isLooping = false;
  Duration? _loopStart;
  Duration? _loopEnd;
  int _remainingLoops = 0;

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

    _loopPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleLoopCompletion();
      }
    });

    _loopPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _handleLoopCompletion();
      }
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

  Future<void> _handleLoopCompletion() async {
    if (!_isLooping || _loopStart == null || _loopEnd == null) return;
    
    try {
      if (_remainingLoops > 0) {
        _remainingLoops--;
        await _loopPlayer.seek(_loopStart!);
        await _loopPlayer.play();
        print('Loop continued. Remaining loops: $_remainingLoops');
      } else {
        print('Loop completed');
        _isLooping = false;
        _loopStart = null;
        _loopEnd = null;
        await _loopPlayer.stop();
      }
    } catch (e) {
      print('Error in loop completion handler: $e');
      _isLooping = false;
      _loopStart = null;
      _loopEnd = null;
    }
  }

  Future<void> loopSegment(Duration start, Duration end, int loopCount, int breakSeconds) async {
    print('Starting loop segment: $start to $end, count: $loopCount');
    
    try {
      // Stop any existing playback
      await _loopPlayer.stop();
      _isLooping = false;
      _loopStart = start;
      _loopEnd = end;
      _remainingLoops = loopCount - 1; // Subtract 1 because we play the first loop immediately

      // Configure the player
      await _loopPlayer.setLoopMode(LoopMode.off); // We handle looping manually
      await _loopPlayer.setClip(start: start, end: end);
      
      // Start playback
      await _loopPlayer.seek(start);
      await _loopPlayer.play();
      
      _isLooping = true;
      print('Loop playback started successfully');
    } catch (e) {
      print('Error starting loop: $e');
      _isLooping = false;
      _loopStart = null;
      _loopEnd = null;
      _remainingLoops = 0;
    }
  }

  Future<void> stopLooping() async {
    print('Stopping loop playback');
    _isLooping = false;
    _loopStart = null;
    _loopEnd = null;
    _remainingLoops = 0;
    await _loopPlayer.stop();
  }

  @override
  void dispose() {
    _mainPlayer.dispose();
    _loopPlayer.dispose();
    super.dispose();
  }
}

