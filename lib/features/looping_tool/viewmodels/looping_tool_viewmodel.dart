import 'package:flutter/foundation.dart';
import 'package:looping_tool_mvp/data/models/marker.dart';
import 'package:looping_tool_mvp/data/models/segment.dart';
import 'package:file_picker/file_picker.dart';

class LoopingToolViewModel extends ChangeNotifier {
  String? audioFilePath;
  double playbackSpeed = 1.0;
  int loopCount = 1;
  int breakDuration = 0;

  List<Marker> markers = [];
  Segment? selectedSegment;
  Duration? startPosition;
  Duration? endPosition;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setAudioFile(String path) {
    audioFilePath = path;
    markers.clear();
    selectedSegment = null;
    startPosition = null;
    endPosition = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setAudioFile(path);
      return path;
    }
    return null;
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed;
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
}