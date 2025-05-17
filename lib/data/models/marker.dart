/// Represents a point in time within an audio file.
/// 
/// A marker is used to identify specific positions in the audio timeline.
/// Each marker has:
/// - A timestamp indicating when it occurs in the audio
/// - A label (typically a letter like 'A', 'B', etc.) for identification
/// 
/// Markers are used to:
/// - Define the start and end points of segments
/// - Provide visual reference points in the timeline
/// - Enable quick navigation to specific points in the audio
class Marker {
  /// The exact position in the audio file where this marker is placed
  final Duration timestamp;

  /// A unique identifier for this marker
  /// Typically a single letter (A, B, C, etc.) for easy reference
  final String label;

  /// Creates a new marker at the specified position with the given label
  /// 
  /// Parameters:
  /// - [timestamp]: The position in the audio file
  /// - [label]: The identifier for this marker
  Marker({
    required this.timestamp,
    required this.label,
  });
}
