import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'custom_timeline.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

/// A widget that provides an interactive timeline visualization for audio playback.
/// 
/// This widget implements a Digital Audio Workstation (DAW) style timeline that includes:
/// - Waveform visualization
/// - Playhead tracking
/// - Marker visualization
/// - Zoom and pan controls
/// - Real-time position updates during playback
/// 
/// The timeline supports:
/// - Pinch-to-zoom gesture for adjusting the time window
/// - Pan gesture for moving through the timeline
/// - Automatic following of playback position
/// - Marker visualization with labels
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
  
  /// Minimum zoom level allowed
  static const double _minZoom = 0.5;

  /// Maximum zoom level allowed
  static const double _maxZoom = 3.0;

  /// Base time window shown at zoom level 1.0
  static const double _baseWindowSeconds = 30.0;

  /// Waveform data for visualization
  late List<double> _waveform;

  @override
  void initState() {
    super.initState();
    _waveform = generateRandomWaveform(1000);
    _centerPosition = widget.audioPosition;
    _ticker = Ticker(_onTick)..start();
  }

  /// Updates the timeline position during playback
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
    final windowSeconds = _baseWindowSeconds / _zoom;
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
            _zoom = (_zoom * details.scale).clamp(_minZoom, _maxZoom);
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
        height: 180,
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
