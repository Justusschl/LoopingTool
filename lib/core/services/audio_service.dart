import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  // Main audio player for all playback and looping
  final _mainPlayer = AudioPlayer();

  // Legacy: Not used for looping anymore, but kept for compatibility/disposal
  final _loopPlayer = AudioPlayer();

  // Looping state variables
  bool _isLooping = false;           // Whether looping is currently active
  Duration? _loopStart;              // Start position of the loop segment
  Duration? _loopEnd;                // End position of the loop segment
  int _remainingLoops = 0;           // How many loops are left to play
  int _breakSeconds = 0;             // Break (pause) duration between loops, in seconds
  bool _waitingForNextLoop = false;  // Prevents multiple triggers during break

  // Exposed playback state
  Duration? get duration => _mainPlayer.duration;
  Duration _position = Duration.zero;
  bool get isPlaying => _mainPlayer.playing;
  Duration get position => _position;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  AudioService() {
    // Listen to the main player's position to handle looping logic
    _mainPlayer.positionStream.listen((pos) {
      _position = pos;
      // Only handle looping if active, loop points are set, and not waiting for next loop
      if (_isLooping && _loopStart != null && _loopEnd != null && !_waitingForNextLoop) {
        if (pos >= _loopEnd!) {
          _handleLoopEnd();
        }
      }
      notifyListeners();
    });

    // Listen for duration changes (e.g., when a new file is loaded)
    _mainPlayer.durationStream.listen((dur) {
      notifyListeners();
    });

    // Legacy: Listeners for the unused loop player (safe to remove if not needed elsewhere)
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

  /// Loads an audio file into both players (main and legacy loop player)
  Future<void> loadFile(String path) async {
    await _mainPlayer.setFilePath(path);
    await _mainPlayer.setVolume(1.0);
    await _loopPlayer.setFilePath(path);
    await _loopPlayer.setVolume(1.0);
    notifyListeners();
  }

  /// Basic playback controls for the main player
  void play() => _mainPlayer.play();
  void pause() => _mainPlayer.pause();
  void seek(Duration pos) => _mainPlayer.seek(pos);

  /// Legacy: Handles completion for the old loop player (not used in new logic)
  Future<void> _handleLoopCompletion() async {
    if (!_isLooping || _loopStart == null || _loopEnd == null) return;
    print('Loop completed segment: $_loopStart to $_loopEnd, remaining loops: $_remainingLoops');
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

  /// Starts looping a segment from [start] to [end], [loopCount] times, with [breakSeconds] pause between loops
  Future<void> loopSegment(Duration start, Duration end, int loopCount, int breakSeconds) async {
    print('Starting manual loop: $start to $end, count: $loopCount, break: $breakSeconds');
    await _mainPlayer.pause();
    _loopStart = start;
    _loopEnd = end;
    _remainingLoops = loopCount - 1; // First play counts as the first loop
    _isLooping = true;
    _breakSeconds = breakSeconds;
    await setPlaybackSpeed(playbackSpeed); // Set speed before playing
    await _mainPlayer.seek(start);
    await _mainPlayer.play();
  }

  /// Stops any ongoing looping and resets state
  Future<void> stopLooping() async {
    print('Stopping manual loop');
    _isLooping = false;
    _loopStart = null;
    _loopEnd = null;
    _remainingLoops = 0;
    await _mainPlayer.pause();
  }

  /// Handles the end of a loop segment:
  /// - Pauses at loop end
  /// - If more loops remain, waits for the break, then seeks to start and plays again
  /// - If no loops remain, pauses and resets state
  void _handleLoopEnd() async {
    if (_waitingForNextLoop) return; // Prevents multiple triggers during break
    _waitingForNextLoop = true;

    await _mainPlayer.pause();
    if (_remainingLoops > 0) {
      _remainingLoops--;
      if (_breakSeconds > 0) {
        print('Pausing for $_breakSeconds seconds between loops');
        Future.delayed(Duration(seconds: _breakSeconds), () async {
          // Only continue if still looping and loop points are valid
          if (_isLooping && _loopStart != null && _loopEnd != null) {
            _waitingForNextLoop = false;
            await _mainPlayer.seek(_loopStart!);
            await _mainPlayer.play();
            print('Looped! Remaining: $_remainingLoops');
          }
        });
      } else {
        if (_isLooping && _loopStart != null && _loopEnd != null) {
          _waitingForNextLoop = false;
          await _mainPlayer.seek(_loopStart!);
          await _mainPlayer.play();
          print('Looped! Remaining: $_remainingLoops');
        }
      }
    } else {
      // Last loop: pause at end, reset all state
      await _mainPlayer.seek(_loopEnd!);
      await _mainPlayer.pause();
      _isLooping = false;
      _loopStart = null;
      _loopEnd = null;
      _remainingLoops = 0;
      _waitingForNextLoop = false;
      print('Looping finished and paused at end');
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _mainPlayer.setSpeed(speed);
    notifyListeners();
  }

  @override
  void dispose() {
    _mainPlayer.dispose();
    _loopPlayer.dispose();
    super.dispose();
  }
}

