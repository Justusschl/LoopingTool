import 'marker.dart';

/// Represents a continuous section of audio between two markers.
/// 
/// A segment defines a portion of the audio file that can be:
/// - Played as a loop
/// - Repeated multiple times
/// - Used as a reference for practice
/// 
/// Each segment is defined by:
/// - A start marker (beginning of the segment)
/// - An end marker (end of the segment)
/// 
/// The segment's duration is automatically calculated from its markers.
class Segment {
  /// The marker that defines the start of this segment
  final Marker start;

  /// The marker that defines the end of this segment
  final Marker end;

  /// Creates a new segment between two markers
  /// 
  /// Parameters:
  /// - [start]: The marker indicating the beginning of the segment
  /// - [end]: The marker indicating the end of the segment
  /// 
  /// Note: The end marker's timestamp must be after the start marker's timestamp
  Segment({
    required this.start,
    required this.end,
  });

  /// Calculates the duration of this segment
  /// 
  /// Returns the time difference between the end and start markers
  Duration get duration => end.timestamp - start.timestamp;
}
