import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:looping_tool_mvp/features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'timeline_painter.dart';
import 'timeline_constants.dart';

/// The main interactive timeline component for audio playback visualization.
/// 
/// This widget implements a Digital Audio Workstation (DAW) style timeline that
/// provides a rich, interactive interface for audio navigation and visualization.
/// It combines gesture handling, playback tracking, and visual feedback to create
/// a professional-grade timeline experience.
/// 
/// Core Features:
/// - Real-time waveform visualization
/// - Interactive playhead tracking
/// - Marker visualization and management
/// - Intuitive zoom and pan controls
/// - Smooth playback position updates
/// 
/// Interaction Model:
/// - Pinch gestures for zooming the timeline view
/// - Pan gestures for navigating through the timeline
/// - Automatic playhead following during playback
/// - Marker visualization with labels
/// - Position seeking through direct interaction
class DAWTimeline extends StatefulWidget {
  /// Current playback position in seconds
  final double audioPosition;

  /// Total duration of the audio in seconds
  final double totalSeconds;

  /// Whether audio is currently playing
  final bool isPlaying;

  /// Waveform data for visualization
  final List<double> waveform;

  /// Callback when the user changes the position
  final Function(double) onPositionChanged;

  const DAWTimeline({
    super.key,
    required this.audioPosition,
    required this.totalSeconds,
    required this.isPlaying,
    required this.waveform,
    required this.onPositionChanged,
  });

  @override
  State<DAWTimeline> createState() => _DAWTimelineState();
}

class _DAWTimelineState extends State<DAWTimeline> with SingleTickerProviderStateMixin {
  /// Current zoom level of the timeline
  double _zoom = 1.0;

  /// Current pan offset in seconds
  double _pan = 0.0;

  /// Whether the user is currently interacting with the timeline
  bool _isInteracting = false;

  /// Ticker for smooth animation updates
  late final Ticker _ticker;

  /// Center position of the timeline view
  double _centerPosition = 0.0;

  /// Last recorded pan position for gesture calculations
  double _lastPanX = 0.0;

  @override
  void initState() {
    super.initState();
    _centerPosition = widget.audioPosition;
    _ticker = Ticker(_onTick)..start();
  }

  /// Updates the timeline position during playback
  /// 
  /// This method is called by the ticker to update the timeline position
  /// during playback. It ensures smooth following of the playhead when
  /// not being interacted with by the user.
  void _onTick(Duration elapsed) {
    if (!_isInteracting && widget.isPlaying) {
      setState(() {
        _centerPosition = widget.audioPosition;
        // Reset pan when following audio
        _pan = 0.0;
      });
    }
  }

  /// Updates the playback position with bounds checking
  /// 
  /// Ensures the new position is within valid bounds (0 to total duration)
  /// before notifying the parent widget of the position change.
  void _updatePosition(double newPosition) {
    // Clamp position to valid range
    final clampedPosition = newPosition.clamp(0.0, widget.totalSeconds);
    widget.onPositionChanged(clampedPosition);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final windowSeconds = TimelineConstants.baseWindowSeconds / _zoom;
    final vm = Provider.of<LoopingToolViewModel>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) {
        _isInteracting = true;
        _lastPanX = details.focalPoint.dx;
      },
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount == 2) {
            // Handle zoom with stricter limits
            _zoom = (_zoom * details.scale).clamp(
              TimelineConstants.minZoom,
              TimelineConstants.maxZoom
            );
          } else {
            // Handle pan with more stable calculation
            final deltaX = details.focalPoint.dx - _lastPanX;
            final secondsPerPixel = windowSeconds / screenWidth;
            _pan -= deltaX * secondsPerPixel;
            _lastPanX = details.focalPoint.dx;
          }
        });
      },
      onScaleEnd: (_) {
        _isInteracting = false;
        _updatePosition(_centerPosition + _pan);
      },
      child: SizedBox(
        width: screenWidth,
        height: TimelineConstants.timelineHeight,
        child: CustomPaint(
          size: Size.infinite,
          painter: TimelinePainter(
            positionSeconds: widget.audioPosition,
            totalSeconds: widget.totalSeconds,
            windowSeconds: windowSeconds,
            waveform: widget.waveform,
            zoomLevel: _zoom,
            pan: 0.0,
            markers: vm.markers,
          ),
        ),
      ),
    );
  }
}

/// Generates a random waveform for testing purposes
/// 
/// Returns a list of random values between 0.2 and 1.0
List<double> generateRandomWaveform(int length) {
  final random = Random();
  return List.generate(length, (_) => 0.2 + random.nextDouble() * 0.8);
}
