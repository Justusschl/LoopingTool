import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import 'dart:math';


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
        height: 90,
        child: CustomPaint(
          painter: TimelinePainter(
            positionSeconds: positionSeconds,
            totalSeconds: totalSeconds,
            windowSeconds: windowSeconds,
            waveform: vm.waveform,
            zoomLevel: zoomLevel,
          ),
          size: Size.infinite,
        ),
      );
    }
    return SizedBox(
      height: 90,
      child: CustomPaint(
        painter: TimelinePainter(
          positionSeconds: positionSeconds,
          totalSeconds: totalSeconds,
          windowSeconds: windowSeconds,
          waveform: vm.waveform,
          zoomLevel: zoomLevel,
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

  TimelinePainter({
    required this.positionSeconds,
    required this.totalSeconds,
    required this.windowSeconds,
    required this.waveform,
    required this.zoomLevel,
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
      double x = centerX + (t - positionSeconds) / secondsPerPixel;
      if (x < 0 || x > size.width) continue;

      bool isBig = (t / 1.0).roundToDouble() == t; // every 1s is big
      double dashHeight = isBig ? bigDashHeight : smallDashHeight;

      canvas.drawLine(
        Offset(x, (size.height - dashHeight) / 2),
        Offset(x, (size.height + dashHeight) / 2),
        paint,
      );
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
    return oldDelegate.positionSeconds != positionSeconds ||
           oldDelegate.waveform != waveform;
  }
}

class AnimatedTimeline extends StatefulWidget {
  final double positionSeconds; // The current audio position (from your audio player)
  final double totalSeconds;
  final double windowSeconds;

  const AnimatedTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30.0,
  });

  @override
  State<AnimatedTimeline> createState() => _AnimatedTimelineState();
}

class _AnimatedTimelineState extends State<AnimatedTimeline> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _displayedPosition = 0.0;
  double _lastAudioPosition = 0.0;
  late DateTime _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _displayedPosition = widget.positionSeconds;
    _lastAudioPosition = widget.positionSeconds;
    _lastUpdateTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
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
  late final Ticker _ticker;
  double _displayedPosition = 0.0;
  double _lastAudioPosition = 0.0;
  late DateTime _lastAudioUpdateTime;
  double _zoomLevel = 1.0;
  double _lastZoomLevel = 1.0;
  double _minZoom = 0.1;  // Allow zooming out more
  double _maxZoom = 20.0; // Allow zooming in more
  double _zoomSensitivity = 2.0;  // More responsive zoom
  double _baseWindowSeconds = 30.0;  // Base window size
  double _focalTime = 0.0;
  Offset? _lastFocalPoint;

  @override
  void initState() {
    super.initState();
    _displayedPosition = widget.positionSeconds;
    _lastAudioPosition = widget.positionSeconds;
    _lastAudioUpdateTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    final dt = now.difference(_lastAudioUpdateTime).inMilliseconds / 1000.0;
    setState(() {
      if (widget.isPlaying) {
        // Use linear interpolation for smoother movement
        _displayedPosition = _lastAudioPosition + dt;
        // Add a small buffer to prevent jitter
        if ((_displayedPosition - widget.positionSeconds).abs() > 0.1) {
          _displayedPosition = widget.positionSeconds;
          _lastAudioPosition = widget.positionSeconds;
          _lastAudioUpdateTime = now;
        }
      } else {
        _displayedPosition = _lastAudioPosition;
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedCustomTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the position jumps (e.g., seek), update immediately
    if ((widget.positionSeconds - _lastAudioPosition).abs() > 0.1 || widget.isPlaying != oldWidget.isPlaying) {
      _lastAudioPosition = widget.positionSeconds;
      _lastAudioUpdateTime = DateTime.now();
      _displayedPosition = widget.positionSeconds;
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
    
    return RepaintBoundary(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _handleDrag(details.primaryDelta ?? 0, context);
        },
        onScaleStart: (details) {
          _lastZoomLevel = _zoomLevel;
          _lastFocalPoint = details.focalPoint;
          // Calculate the time at the focal point
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final localFocal = box.globalToLocal(details.focalPoint);
            final secondsPerPixel = (_baseWindowSeconds / _zoomLevel) / box.size.width;
            _focalTime = _displayedPosition + (localFocal.dx - box.size.width / 2) * secondsPerPixel;
          }
        },
        onScaleUpdate: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final localFocal = box.globalToLocal(details.focalPoint);
          final newZoom = (_lastZoomLevel * details.scale).clamp(0.2, 10.0);
          final secondsPerPixel = (_baseWindowSeconds / newZoom) / box.size.width;
          // Adjust center so focal time stays under finger
          final newCenter = _focalTime - (localFocal.dx - box.size.width / 2) * secondsPerPixel;
          setState(() {
            _zoomLevel = newZoom;
            _displayedPosition = newCenter.clamp(0.0, widget.totalSeconds);
          });
        },
        child: SizedBox(
          height: 90,
          child: Stack(
            children: [
              CustomPaint(
                painter: TimelinePainter(
                  positionSeconds: _displayedPosition,
                  totalSeconds: widget.totalSeconds,
                  windowSeconds: _baseWindowSeconds / _zoomLevel,
                  waveform: vm.waveform,
                  zoomLevel: _zoomLevel,
                ),
                size: Size.infinite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDrag(double delta, BuildContext context) {
    // The width of the timeline represents windowSeconds
    // So delta in pixels maps to seconds as:
    // deltaSeconds = -delta / width * windowSeconds
    // (negative because dragging right means going back in time)
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;
    final deltaSeconds = -delta / width * widget.windowSeconds;

    // Calculate new position, clamp to [0, totalSeconds]
    double newPosition = (_displayedPosition + deltaSeconds).clamp(0.0, widget.totalSeconds.toDouble());

    // Seek the audio player
    // You may need to get AudioService from Provider here:
    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.seek(Duration(seconds: newPosition.round()));
  }
}