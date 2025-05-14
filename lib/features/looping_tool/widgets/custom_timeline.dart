import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import 'dart:math';
import 'package:looping_tool_mvp/data/models/marker.dart';


class CustomTimeline extends StatelessWidget {
  final double positionSeconds; // current position in seconds
  final double totalSeconds; // total duration in seconds
  final double windowSeconds; // how many seconds to show in the viewport
  final double zoomLevel;

  const CustomTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30.0,
    required this.zoomLevel,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    if (totalSeconds == 0 || vm.waveform.isEmpty) {
      return SizedBox(
        height: 180,
        child: CustomPaint(
          painter: TimelinePainter(
            positionSeconds: positionSeconds,
            totalSeconds: totalSeconds,
            windowSeconds: windowSeconds,
            waveform: vm.waveform,
            zoomLevel: zoomLevel,
            pan: 0.0,
            markers: vm.markers,
          ),
          size: Size.infinite,
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: TimelinePainter(
          positionSeconds: positionSeconds,
          totalSeconds: totalSeconds,
          windowSeconds: windowSeconds,
          waveform: vm.waveform,
          zoomLevel: zoomLevel,
          pan: 0.0,
          markers: vm.markers,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double positionSeconds;
  final double totalSeconds;
  final double windowSeconds;
  final List<double> waveform;
  final double zoomLevel;
  final double pan;
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
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final secondsPerPixel = windowSeconds / size.width;

    // Dash pattern: big every 1s, small every 0.5s
    final bigDashHeight = size.height * 0.8;
    final smallDashHeight = size.height * 0.4;
    final dashInterval = 0.5; // seconds between dashes

    // Find the time range visible in the window
    final minTime = positionSeconds - windowSeconds / 2;
    final maxTime = positionSeconds + windowSeconds / 2;

    // Start at the first dash >= minTime
    double firstDashTime = (minTime / dashInterval).ceil() * dashInterval;

    for (double t = firstDashTime; t <= maxTime; t += dashInterval) {
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
      ..color = Colors.blueAccent
      ..strokeWidth = 3.0;
    final textStyle = TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold);
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
      // Draw marker label offset to the right and below the timeline
      final textSpan = TextSpan(text: marker.label, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: 40);
      // Offset label 8px to the right and 18px below the bottom
      textPainter.paint(canvas, Offset(x + 8, size.height - textPainter.height + 18));
    }

    // Draw playhead in the center
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel || oldDelegate.pan != pan || oldDelegate.positionSeconds != positionSeconds || oldDelegate.markers != markers;
  }
}

class AnimatedTimeline extends StatefulWidget {
  final double positionSeconds; // The current audio position (from your audio player)
  final double totalSeconds;
  final double windowSeconds;
  final bool isPlaying;

  const AnimatedTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30.0,
    required this.isPlaying,
  });

  @override
  State<AnimatedTimeline> createState() => _AnimatedTimelineState();
}

class _AnimatedTimelineState extends State<AnimatedTimeline> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _displayedPosition = 0.0;
  double _lastAudioPosition = 0.0;
  late DateTime _lastUpdateTime;
  final bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _displayedPosition = widget.positionSeconds;
    _lastAudioPosition = widget.positionSeconds;
    _lastUpdateTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_isInteracting || !widget.isPlaying) return; // Don't update while user is interacting

    final now = DateTime.now();
    final dt = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;

    setState(() {
      // Advance the displayed position by the time elapsed since last frame
      _displayedPosition += dt;

      // If the audio position has jumped (seek), reset immediately
      if ((widget.positionSeconds - _lastAudioPosition).abs() > 1.0) {
        _displayedPosition = widget.positionSeconds;
      }

      // Clamp to the current audio position if we've gone too far
      if (_displayedPosition > widget.positionSeconds) {
        _displayedPosition = widget.positionSeconds;
      }

      _lastAudioPosition = widget.positionSeconds;
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the position jumps (e.g., seek), update immediately
    if ((widget.positionSeconds - _displayedPosition).abs() > 1.0) {
      _displayedPosition = widget.positionSeconds;
      _lastAudioPosition = widget.positionSeconds;
      _lastUpdateTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTimeline(
      positionSeconds: _displayedPosition,
      totalSeconds: widget.totalSeconds,
      windowSeconds: widget.windowSeconds,
      zoomLevel: 1.0,
    );
  }
}

class AnimatedCustomTimeline extends StatefulWidget {
  final double positionSeconds;
  final double totalSeconds;
  final double windowSeconds;
  final bool isPlaying;

  const AnimatedCustomTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30.0,
    required this.isPlaying,
  });

  @override
  State<AnimatedCustomTimeline> createState() => _AnimatedCustomTimelineState();
}

class _AnimatedCustomTimelineState extends State<AnimatedCustomTimeline> with SingleTickerProviderStateMixin {
  double _zoomLevel = 1.0;
  double _lastZoomLevel = 1.0;
  double _displayedPosition = 0.0;
  double _lastDisplayedPosition = 0.0;
  bool _isInteracting = false;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _displayedPosition = widget.positionSeconds;
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!_isInteracting) {
      setState(() {
        _displayedPosition = widget.positionSeconds;
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCustomTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInteracting && (widget.positionSeconds - _displayedPosition).abs() > 0.01) {
      setState(() {
        _displayedPosition = widget.positionSeconds;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);

    // Calculate pan so that playhead stays centered on _displayedPosition
    final windowSeconds = 30.0;
    final size = MediaQuery.of(context).size;
    final secondsPerPixel = windowSeconds / size.width;
    final pan = (widget.positionSeconds - _displayedPosition) / secondsPerPixel;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _isInteracting = true;
          _lastDisplayedPosition = _displayedPosition;
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _displayedPosition = _lastDisplayedPosition - details.primaryDelta! * secondsPerPixel;
          });
        },
        onHorizontalDragEnd: (_) {
          _isInteracting = false;
          // Seek audio to new position
          final audioService = Provider.of<AudioService>(context, listen: false);
          audioService.seek(Duration(seconds: _displayedPosition.round()));
        },
        onScaleStart: (details) {
          _isInteracting = true;
          _lastDisplayedPosition = _displayedPosition;
          _lastZoomLevel = _zoomLevel;
        },
        onScaleUpdate: (details) {
          setState(() {
            _zoomLevel = (_lastZoomLevel * details.scale).clamp(0.5, 10.0);
          });
        },
        onScaleEnd: (details) {
          _isInteracting = false;
        },
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: TimelinePainter(
              positionSeconds: _displayedPosition,
              totalSeconds: widget.totalSeconds,
              windowSeconds: windowSeconds,
              waveform: vm.waveform,
              zoomLevel: _zoomLevel,
              pan: pan,
              markers: vm.markers,
            ),
          ),
        ),
      ),
    );
  }
}
