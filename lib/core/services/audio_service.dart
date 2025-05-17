import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Service responsible for all audio playback and looping functionality.
/// 
/// This service manages:
/// - Audio file playback
/// - Loop segment playback (implemented using position monitoring and seeking)
/// - Playback position tracking
/// - Playback speed control
/// - Break duration between loops
class AudioService extends ChangeNotifier {
  // Audio Players
  /// Main audio player used for all playback and looping
  /// Handles looping through position monitoring and manual seeking
  final _mainPlayer = AudioPlayer();

  /// Legacy player from previous implementation
  /// Note: This player is maintained for compatibility but is not used
  /// in the current looping implementation
  final _loopPlayer = AudioPlayer();

  // Looping State
  /// Whether a loop segment is currently being played
  bool _isLooping = false;

  /// Start position of the current loop segment
  Duration? _loopStart;

  /// End position of the current loop segment
  Duration? _loopEnd;

  /// Number of loops remaining to be played
  int _remainingLoops = 0;

  /// Duration of pause between loops in seconds
  int _breakSeconds = 0;

  /// Flag to prevent multiple triggers during break periods
  bool _waitingForNextLoop = false;

  // Public State
  /// Total duration of the loaded audio file
  Duration? get duration => _mainPlayer.duration;

  /// Current playback position
  Duration _position = Duration.zero;
  Duration get position => _position;

  /// Whether audio is currently playing
  bool get isPlaying => _mainPlayer.playing;

  /// Current playback speed multiplier (1.0 = normal speed)
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  /// Constructor sets up position tracking and event listeners
  AudioService() {
    // Track main player position and handle looping
    _mainPlayer.positionStream.listen((pos) {
      _position = pos;
      // Handle loop end when position reaches loop end
      if (_isLooping && _loopStart != null && _loopEnd != null && !_waitingForNextLoop) {
        if (pos >= _loopEnd!) {
          _handleLoopEnd();
        }
      }
      notifyListeners();
    });

    // Notify when audio duration changes (e.g., new file loaded)
    _mainPlayer.durationStream.listen((dur) {
      notifyListeners();
    });

    // Legacy: Listeners for unused loop player
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

  /// Loads an audio file into both players
  /// 
  /// Sets up the file for playback in both main and legacy players
  /// with full volume
  Future<void> loadFile(String path) async {
    await _mainPlayer.setFilePath(path);
    await _mainPlayer.setVolume(1.0);
    await _loopPlayer.setFilePath(path);
    await _loopPlayer.setVolume(1.0);
    notifyListeners();
  }

  /// Basic playback controls
  void play() => _mainPlayer.play();
  void pause() => _mainPlayer.pause();
  void seek(Duration pos) => _mainPlayer.seek(pos);

  /// Legacy: Handles completion of a loop in the old loop player
  /// 
  /// Note: This is kept for compatibility but is not used in the new
  /// looping implementation
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

  /// Starts looping a segment of audio
  /// 
  /// Parameters:
  /// - [start]: Start position of the loop
  /// - [end]: End position of the loop
  /// - [loopCount]: Number of times to loop the segment
  /// - [breakSeconds]: Duration of pause between loops
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

  /// Stops any ongoing looping and resets all loop-related state
  Future<void> stopLooping() async {
    print('Stopping manual loop');
    _isLooping = false;
    _loopStart = null;
    _loopEnd = null;
    _remainingLoops = 0;
    await _mainPlayer.pause();
  }

  /// Handles the end of a loop segment
  /// 
  /// This method:
  /// 1. Pauses at the loop end
  /// 2. If more loops remain:
  ///    - Waits for the break duration
  ///    - Seeks back to start
  ///    - Resumes playback
  /// 3. If no loops remain:
  ///    - Pauses at end
  ///    - Resets all loop state
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

  /// Updates the playback speed for both players
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _mainPlayer.setSpeed(speed);
    notifyListeners();
  }

  /// Cleanup: Disposes of both audio players
  @override
  void dispose() {
    _mainPlayer.dispose();
    _loopPlayer.dispose();
    super.dispose();
  }
}

