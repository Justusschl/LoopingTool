import 'package:flutter/material.dart';
import 'package:looping_tool_mvp/data/models/marker.dart';
import 'timeline_constants.dart';

/// A custom painter that handles the core rendering of the timeline visualization.
/// 
/// This painter is responsible for drawing all visual elements of the timeline:
/// - Time markers and grid lines at regular intervals
/// - Playhead showing current playback position
/// - Marker lines and labels at specific timestamps
/// - Waveform visualization (when implemented)
/// 
/// The painter uses the configuration from TimelineConstants to ensure
/// consistent styling and dimensions across the application.
/// 
/// Key features:
/// - Efficient rendering of time markers based on visible range
/// - Smart marker label placement to avoid overlaps
/// - Responsive to zoom and pan operations
/// - Optimized repainting through shouldRepaint
class TimelinePainter extends CustomPainter {
  /// Current playback position in seconds
  final double positionSeconds;

  /// Total duration of the audio in seconds
  final double totalSeconds;

  /// Number of seconds visible in the current viewport
  final double windowSeconds;

  /// Waveform data for visualization
  final List<double> waveform;

  /// Current zoom level of the timeline
  final double zoomLevel;

  /// Current pan offset in seconds
  final double pan;

  /// List of markers to display on the timeline
  final List<Marker> markers;

  TimelinePainter({
    required this.positionSeconds,
    required this.totalSeconds,
    required this.windowSeconds,
    required this.waveform,
    required this.zoomLevel,
    required this.pan,
    required this.markers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalSeconds == 0 || waveform.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = TimelineConstants.timelineColors.timeMarker
      ..strokeWidth = TimelineConstants.timelineColors.timeMarkerStrokeWidth;

    final centerX = size.width / 2;
    final secondsPerPixel = windowSeconds / size.width;

    // Draw time markers
    final bigDashHeight = size.height * TimelineConstants.bigDashHeightRatio;
    final smallDashHeight = size.height * TimelineConstants.smallDashHeightRatio;

    // Calculate visible time range
    final minTime = positionSeconds - windowSeconds / 2;
    final maxTime = positionSeconds + windowSeconds / 2;

    // Draw time markers
    double firstDashTime = (minTime / TimelineConstants.dashInterval).ceil() * TimelineConstants.dashInterval;
    for (double t = firstDashTime; t <= maxTime; t += TimelineConstants.dashInterval) {
      if (t < 0) continue;
      if (t > totalSeconds) continue;
      double x = centerX + (t - positionSeconds) / secondsPerPixel + pan;
      if (x < 0 || x > size.width) continue;

      bool isBig = (t / 1.0).roundToDouble() == t; // every 1s is big
      double dashHeight = isBig ? bigDashHeight : smallDashHeight;

      canvas.drawLine(
        Offset(x, (size.height - dashHeight) / 2),
        Offset(x, (size.height + dashHeight) / 2),
        paint,
      );
    }

    // Draw markers
    final markerPaint = Paint()
      ..color = TimelineConstants.timelineColors.marker
      ..strokeWidth = TimelineConstants.timelineColors.markerStrokeWidth;
    final textStyle = TextStyle(
      color: TimelineConstants.timelineColors.marker,
      fontSize: 12,
      fontWeight: FontWeight.bold
    );
    for (final marker in markers) {
      final markerSec = marker.timestamp.inMilliseconds / 1000.0;
      if (markerSec < minTime || markerSec > maxTime) continue;
      final x = centerX + (markerSec - positionSeconds) / secondsPerPixel + pan;
      if (x < 0 || x > size.width) continue;
      // Draw marker line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        markerPaint,
      );
      // Draw marker label
      final textSpan = TextSpan(text: marker.label, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: 40);
      textPainter.paint(canvas, Offset(x + 8, size.height - textPainter.height + 18));
    }

    // Draw playhead
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      Paint()
        ..color = TimelineConstants.timelineColors.playhead
        ..strokeWidth = TimelineConstants.timelineColors.playheadStrokeWidth,
    );
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel || 
           oldDelegate.pan != pan || 
           oldDelegate.positionSeconds != positionSeconds || 
           oldDelegate.markers != markers;
  }
}


