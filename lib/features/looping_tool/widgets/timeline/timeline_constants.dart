import 'package:flutter/material.dart';

/// Configuration constants for the timeline visualization system.
/// 
/// This file serves as the central configuration point for all timeline-related
/// components, providing:
/// - Visual dimensions and layout constants
/// - Interaction limits and constraints
/// - Color schemes and styling
/// - Stroke widths and visual properties
/// 
/// By centralizing these values, we ensure:
/// - Consistent appearance across components
/// - Easy theme customization
/// - Single source of truth for timeline configuration
class TimelineConstants {
  /// Default height of the timeline widget in logical pixels
  static const double timelineHeight = 180.0;

  /// Base time window shown at zoom level 1.0 (in seconds)
  /// This determines how much of the timeline is visible by default
  static const double baseWindowSeconds = 30.0;

  /// Minimum zoom level allowed for the timeline
  /// Prevents zooming out too far, maintaining usability
  static const double minZoom = 0.5;

  /// Maximum zoom level allowed for the timeline
  /// Prevents zooming in too far, maintaining performance
  static const double maxZoom = 3.0;

  /// Interval between time markers in seconds
  /// Determines the density of the time grid
  static const double dashInterval = 0.5;

  /// Height of big time markers as a ratio of total height
  /// Used for major time markers (e.g., every second)
  static const double bigDashHeightRatio = 0.8;

  /// Height of small time markers as a ratio of total height
  /// Used for minor time markers (e.g., half-second intervals)
  static const double smallDashHeightRatio = 0.4;

  /// Colors and visual styling for the timeline
  static const timelineColors = _TimelineColors();
}

/// Visual styling constants for the timeline components.
/// 
/// This class encapsulates all color and stroke width values used in
/// the timeline visualization, making it easy to:
/// - Maintain consistent visual appearance
/// - Update the color scheme
/// - Adjust stroke widths for different elements
class _TimelineColors {
  const _TimelineColors();

  /// Color of the time markers and grid lines
  final timeMarker = const Color(0xFFFFFFFF);  // Colors.white

  /// Color of the playhead (current position indicator)
  final playhead = const Color(0xFFFF0000);    // Colors.red

  /// Color of the markers and their labels
  final marker = const Color(0xFF40C4FF);      // Colors.blueAccent

  /// Stroke width for time markers and grid lines
  final timeMarkerStrokeWidth = 2.0;

  /// Stroke width for marker lines
  final markerStrokeWidth = 3.0;

  /// Stroke width for the playhead
  final playheadStrokeWidth = 2.0;
}
