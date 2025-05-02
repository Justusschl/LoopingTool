import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CustomTimeline extends StatelessWidget {
  final double positionSeconds; // current position in seconds
  final int totalSeconds; // total duration in seconds
  final int windowSeconds; // how many seconds to show in the viewport

  const CustomTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: TimelinePainter(
          positionSeconds: positionSeconds,
          totalSeconds: totalSeconds,
          windowSeconds: windowSeconds,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double positionSeconds;
  final int totalSeconds;
  final int windowSeconds;

  TimelinePainter({
    required this.positionSeconds,
    required this.totalSeconds,
    required this.windowSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;

    final Paint playheadPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;

    // The playhead is always in the center
    final double playheadX = size.width / 2;

    // Calculate the visual window (can be negative)
    double visualWindowStart = positionSeconds - windowSeconds / 2;
    double visualWindowEnd = positionSeconds + windowSeconds / 2;

    int numTicks = 40; // More ticks for smoother movement
    double tickInterval = windowSeconds / (numTicks - 1);
    double tickSpacing = size.width / (numTicks - 1);

    // Calculate the fractional offset for smooth scrolling
    double fractional = (visualWindowStart / tickInterval) - (visualWindowStart ~/ tickInterval);
    double pixelOffset = -fractional * tickSpacing;

    const double bigTickHeight = 18;
    const double smallTickHeight = 10;

    for (int i = 0; i < numTicks; i++) {
      double t = (visualWindowStart ~/ tickInterval + i) * tickInterval;
      double x = pixelOffset + i * tickSpacing;

      // Alternate tick heights
      double tickHeight = (i % 2 == 0) ? bigTickHeight : smallTickHeight;

      // Only draw ticks within the visible window
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(
          Offset(x, size.height - tickHeight),
          Offset(x, size.height),
          tickPaint,
        );
      }
    }

    // Draw playhead in the center
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      playheadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return positionSeconds != oldDelegate.positionSeconds ||
        totalSeconds != oldDelegate.totalSeconds ||
        windowSeconds != oldDelegate.windowSeconds;
  }
}

class AnimatedTimeline extends StatefulWidget {
  final double positionSeconds; // The current audio position (from your audio player)
  final int totalSeconds;
  final int windowSeconds;

  const AnimatedTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30,
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
    );
  }
}