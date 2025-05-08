import 'package:flutter/foundation.dart';
import 'package:looping_tool_mvp/data/models/marker.dart';
import 'package:looping_tool_mvp/data/models/segment.dart';
import 'package:file_picker/file_picker.dart';
import 'package:looping_tool_mvp/core/services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class LoopingToolViewModel extends ChangeNotifier {
  String? audioFilePath;
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;
  int loopCount = 1;
  int breakDuration = 0;

  List<Marker> markers = [];
  Segment? selectedSegment;
  Duration? startPosition;
  Duration? endPosition;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _preludeEnabled = false;
  bool get preludeEnabled => _preludeEnabled;

  late AudioService audioService;

  List<double> waveform = [];

  Future<void> setAudioFile(String path) async {
    audioFilePath = path;
    waveform = [];
    markers.clear();
    selectedSegment = null;
    startPosition = null;
    endPosition = null;
    _errorMessage = null;
    
    await generateWaveform(path);
    
    notifyListeners();
  }

  Future<String?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await setAudioFile(path);
      return path;
    }
    return null;
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    audioService.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void setLoopCount(int count) {
    loopCount = count;
    notifyListeners();
  }

  void setBreakDuration(int seconds) {
    breakDuration = seconds;
    notifyListeners();
  }

  void addMarker(String label, Duration timestamp) {
    // Check if marker already exists at this position
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

    print('Selecting segment: $startLabel (${start.timestamp}) to $endLabel (${end.timestamp})');

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
    print('Selected segment: ${start.label} (${start.timestamp}) to ${end.label} (${end.timestamp})');
    notifyListeners();
  }

  void setStartPosition(Duration? pos) {
    startPosition = pos;
    notifyListeners();
  }

  void setEndPosition(Duration? pos) {
    endPosition = pos;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void removeMarker(Marker marker) {
    markers.remove(marker);
    // If the removed marker was part of the selected segment, clear the selection
    if (selectedSegment != null &&
        (selectedSegment!.start == marker || selectedSegment!.end == marker)) {
      selectedSegment = null;
    }
    notifyListeners();
  }

  void setPreludeEnabled(bool value) {
    _preludeEnabled = value;
    notifyListeners();
  }

  Future<void> generateWaveform(String filePath) async {
    final player = AudioPlayer();
    await player.setFilePath(filePath);
    final duration = await player.duration;
    
    // Generate a simple waveform (you can adjust the number of points)
    final waveform = List<double>.generate(100, (index) => 
      (index % 3 == 0) ? 0.8 : 0.3  // This creates a simple pattern
    );
    
    this.waveform = waveform;
    notifyListeners();
  }
}