import 'package:flutter/foundation.dart';
import 'package:looping_tool_mvp/data/models/marker.dart';
import 'package:looping_tool_mvp/data/models/segment.dart';
import 'package:file_selector/file_selector.dart';
import 'package:looping_tool_mvp/core/services/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

/// The central ViewModel for the Looping Tool application.
/// 
/// This ViewModel manages all state for the application, including:
/// - Audio file management and playback
/// - Marker creation and management
/// - Segment selection and validation
/// - Playback settings (speed, loop count, break duration)
/// - Error handling
/// - UI state (prelude, countdown)
class LoopingToolViewModel extends ChangeNotifier {
  // Audio File Management
  /// The path to the currently loaded audio file
  String? audioFilePath;
  
  /// The waveform data for the current audio file
  /// Used for visual representation of the audio
  List<double> waveform = [];

  // Playback Settings
  /// The current playback speed multiplier (1.0 = normal speed)
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  /// Number of times the selected segment should loop
  int loopCount = 1;

  /// Duration of break between loops in seconds
  int breakDuration = 0;

  // Marker and Segment Management
  /// List of all markers in the audio file
  /// Each marker represents a specific point in time with a label
  List<Marker> markers = [];

  /// The currently selected segment, defined by start and end markers
  Segment? selectedSegment;

  /// The current playback position in the audio file
  Duration? startPosition;
  Duration? endPosition;

  // Error Handling
  /// The current error message, if any
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // UI State
  /// Whether the prelude feature is enabled
  bool _preludeEnabled = false;
  bool get preludeEnabled => _preludeEnabled;

  /// Whether the countdown feature is enabled
  bool _countdownEnabled = false;
  bool get countdownEnabled => _countdownEnabled;

  /// Reference to the audio service for playback control
  late AudioService audioService;

  late AudioPlayer _audioPlayer;

  LoopingToolViewModel() {
    _audioPlayer = AudioPlayer();
    audioService = AudioService();
  }

  /// Sets a new audio file and resets all related state
  /// 
  /// This method:
  /// - Updates the audio file path
  /// - Clears the waveform
  /// - Resets markers
  /// - Clears selected segment
  /// - Resets playback positions
  /// - Clears any error messages
  /// - Generates new waveform data
  Future<void> setAudioFile(String path) async {
    try {
      audioFilePath = path;
      waveform = [];
      markers.clear();
      selectedSegment = null;
      startPosition = null;
      endPosition = null;
      _errorMessage = null;
      
      // Set the audio file in the player
      await _audioPlayer.setFilePath(path);
      await audioService.loadFile(path);
      
      // Generate waveform
      await generateWaveform(path);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting audio file: $e');
      _errorMessage = 'Error loading audio file';
      notifyListeners();
    }
  }

  /// Opens a file picker to select an audio file
  /// Returns the selected file path or null if cancelled
  Future<String?> pickAudioFile() async {
    try {
      final typeGroup = XTypeGroup(
        label: 'Audio',
        extensions: ['mp3', 'wav', 'ogg', 'm4a'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      
      if (file != null) {
        await setAudioFile(file.path);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error loading audio file: $e');
      _errorMessage = 'Error loading audio file';
      notifyListeners();
    }
    return null;
  }

  /// Updates the playback speed and notifies the audio service
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    audioService.setPlaybackSpeed(speed);
    notifyListeners();
  }

  /// Updates the number of times the segment should loop
  void setLoopCount(int count) {
    loopCount = count;
    notifyListeners();
  }

  /// Updates the break duration between loops
  void setBreakDuration(int seconds) {
    breakDuration = seconds;
    notifyListeners();
  }

  /// Adds a new marker at the specified timestamp
  /// 
  /// Validates that:
  /// - No marker exists within 100ms of the specified position
  /// - The label is not empty
  /// 
  /// Sets an error message if validation fails
  void addMarker(String label, Duration timestamp) {
    final existingMarker = markers.firstWhere(
      (m) => (m.timestamp - timestamp).inMilliseconds.abs() < 100,
      orElse: () => Marker(label: '', timestamp: Duration.zero),
    );

    if (existingMarker.label.isNotEmpty) {
      _errorMessage = 'Marker already exists near this position';
      notifyListeners();
      return;
    }

    markers.add(Marker(label: label, timestamp: timestamp));
    _errorMessage = null;
    notifyListeners();
  }

  /// Selects a segment based on start and end marker labels
  /// 
  /// Validates that:
  /// - Both markers exist
  /// - End marker is after start marker
  /// - Segment is at least 100ms long
  /// 
  /// Sets an error message if validation fails
  void selectSegmentByLabels(String startLabel, String endLabel) {
    _errorMessage = null;
    
    final start = markers.firstWhere(
      (m) => m.label == startLabel,
      orElse: () => Marker(label: '', timestamp: Duration.zero),
    );
    
    final end = markers.firstWhere(
      (m) => m.label == endLabel,
      orElse: () => Marker(label: '', timestamp: Duration.zero),
    );

    if (start.label.isEmpty || end.label.isEmpty) {
      _errorMessage = 'Invalid segment: Start or end marker not found';
      selectedSegment = null;
      notifyListeners();
      return;
    }

    if (end.timestamp <= start.timestamp) {
      _errorMessage = 'Invalid segment: End time must be after start time';
      selectedSegment = null;
      notifyListeners();
      return;
    }

    if ((end.timestamp - start.timestamp).inMilliseconds < 100) {
      _errorMessage = 'Invalid segment: Segment must be at least 100ms long';
      selectedSegment = null;
      notifyListeners();
      return;
    }

    selectedSegment = Segment(start: start, end: end);
    notifyListeners();
  }

  /// Updates the start position of playback
  void setStartPosition(Duration? pos) {
    startPosition = pos;
    notifyListeners();
  }

  /// Updates the end position of playback
  void setEndPosition(Duration? pos) {
    endPosition = pos;
    notifyListeners();
  }

  /// Clears any current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Removes a marker and updates related state
  /// 
  /// If the removed marker was part of the selected segment,
  /// the segment selection is cleared
  void removeMarker(Marker marker) {
    markers.remove(marker);
    // If the removed marker was part of the selected segment, clear the selection
    if (selectedSegment != null &&
        (selectedSegment!.start == marker || selectedSegment!.end == marker)) {
      selectedSegment = null;
    }
    notifyListeners();
  }

  /// Toggles the prelude feature
  void setPreludeEnabled(bool value) {
    _preludeEnabled = value;
    notifyListeners();
  }

  /// Toggles the countdown feature
  void setCountdownEnabled(bool value) {
    _countdownEnabled = value;
    notifyListeners();
  }

  /// Generates a simple waveform visualization for the current audio file
  /// 
  /// Currently generates a basic pattern for demonstration purposes
  /// TODO: Implement actual waveform generation from audio data
  Future<void> generateWaveform(String filePath) async {
    try {
      // Create a temporary player to get audio duration
      final tempPlayer = AudioPlayer();
      await tempPlayer.setFilePath(filePath);
      final duration = tempPlayer.duration;
      await tempPlayer.dispose();

      if (duration == null) {
        throw Exception('Could not get audio duration');
      }

      // Generate a more realistic waveform pattern
      final numPoints = 100;
      final waveform = List<double>.generate(numPoints, (index) {
        // Create a more natural-looking waveform pattern
        final baseHeight = 0.3;
        final variation = 0.5;
        final frequency = 2.0;
        return baseHeight + variation * (0.5 + 0.5 * (index % 3 == 0 ? 1.0 : 0.3));
      });

      this.waveform = waveform;
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating waveform: $e');
      _errorMessage = 'Error generating waveform';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

//┌─────────────────────────────────────────────────────────────────┐
//│                        MainScreen (UI Layer)                     │
//│                                                                 │
//│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
//│  │   Header    │  │  Timeline   │  │  Segment    │             │
//│  │   Widget    │  │   Widget    │  │  Selector   │             │
//│  └─────────────┘  └─────────────┘  └─────────────┘             │
//│                                                                 │
//└───────────────────────────┬─────────────────────────────────────┘
//                            │
//                            ▼
//┌─────────────────────────────────────────────────────────────────┐
//│                    LoopingToolViewModel                          │
//│  (State Management & Business Logic)                            │
//│                                                                 │
//│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐  │
//│  │  Audio File     │    │  Marker &       │    │  Playback   │  │
//│  │  Management     │    │  Segment        │    │  Settings   │  │
//│  └────────┬────────┘    └────────┬────────┘    └──────┬──────┘  │
//│           │                      │                     │         │
//└───────────┼──────────────────────┼─────────────────────┼─────────┘
//            │                      │                     │
//            ▼                      ▼                     ▼
//┌─────────────────────────────────────────────────────────────────┐
//│                        AudioService                             │
//│  (Audio Playback & Looping Logic)                               │
//│                                                                 │
//│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐  │
//│  │  Main Player    │    │  Loop Player    │    │  Position   │  │
//│  │  (Active)       │    │  (Legacy)       │    │  Tracking   │  │
//│  └─────────────────┘    └─────────────────┘    └─────────────┘  │
//└─────────────────────────────────────────────────────────────────┘