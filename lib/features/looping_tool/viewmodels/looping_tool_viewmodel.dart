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

  void setAudioFile(String path) {
    audioFilePath = path;
    markers.clear();
    selectedSegment = null;
    startPosition = null;
    endPosition = null;
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
    markers.add(Marker(label: label, timestamp: timestamp));
    notifyListeners();
  }

  void selectSegmentByLabels(String startLabel, String endLabel) {
    final start = markers.firstWhere((m) => m.label == startLabel, orElse: () => Marker(label: '', timestamp: Duration.zero));
    final end = markers.firstWhere((m) => m.label == endLabel, orElse: () => Marker(label: '', timestamp: Duration.zero));

    if (start.label.isNotEmpty && end.label.isNotEmpty) {
      selectedSegment = Segment(start: start, end: end);
      notifyListeners();
    }
  }

  void setStartPosition(Duration? pos) {
    startPosition = pos;
    notifyListeners();
  }

  void setEndPosition(Duration? pos) {
    endPosition = pos;
    notifyListeners();
  }
}