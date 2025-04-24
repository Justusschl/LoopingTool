import 'marker.dart';

class Segment {
  final Marker start;
  final Marker end;

  Segment({
    required this.start,
    required this.end,
  });

  Duration get duration => end.timestamp - start.timestamp;
}
