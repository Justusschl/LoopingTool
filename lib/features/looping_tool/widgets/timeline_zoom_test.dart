import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'custom_timeline.dart';
import 'dart:math';

class DAWTimeline extends StatefulWidget {
  final double audioPosition;
  final double totalSeconds;
  final bool isPlaying;
  final List<double> waveform;
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
  double _zoom = 1.0;
  double _pan = 0.0;
  bool _isInteracting = false;
  late final Ticker _ticker;
  double _centerPosition = 0.0;
  double _lastPanX = 0.0;
  
  // Add constants for better control
  static const double _minZoom = 0.5;
  static const double _maxZoom = 3;  // Reduced from 10.0
  static const double _baseWindowSeconds = 30.0;

  late List<double> _waveform;

  @override
  void initState() {
    super.initState();
    _waveform = generateRandomWaveform(1000); // or whatever length you want
    _centerPosition = widget.audioPosition;
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!_isInteracting && widget.isPlaying) {
      setState(() {
        _centerPosition = widget.audioPosition;
        // Reset pan when following audio
        _pan = 0.0;
      });
    }
  }

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
            positionSeconds: _centerPosition + _pan,
            totalSeconds: widget.totalSeconds,
            windowSeconds: windowSeconds,
            waveform: widget.waveform,
            zoomLevel: _zoom,
            pan: 0.0,
          ),
        ),
      ),
    );
  }
}

// Example: 1000 random samples between 0.2 and 1.0
List<double> generateRandomWaveform(int length) {
  final random = Random();
  return List.generate(length, (_) => 0.2 + random.nextDouble() * 0.8);
}
