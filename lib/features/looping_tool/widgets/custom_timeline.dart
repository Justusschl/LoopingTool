import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

class CustomTimeline extends StatelessWidget {
  final double positionSeconds; // current position in seconds
  final double totalSeconds; // total duration in seconds
  final double windowSeconds; // how many seconds to show in the viewport

  const CustomTimeline({
    super.key,
    required this.positionSeconds,
    required this.totalSeconds,
    this.windowSeconds = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: TimelinePainter(
          positionSeconds: positionSeconds,
          totalSeconds: totalSeconds,
          windowSeconds: windowSeconds,
          waveform: vm.waveform,
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

  TimelinePainter({
    required this.positionSeconds,
    required this.totalSeconds,
    required this.windowSeconds,
    required this.waveform,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    final playheadX = size.width / 2;
    final secondsPerPixel = windowSeconds / size.width;

    // Draw waveform
    for (int x = 0; x < size.width; x++) {
      final timeAtX = positionSeconds - windowSeconds / 2 + x * secondsPerPixel;
      
      // Get multiple samples for each x position
      final startSampleIndex = (timeAtX / totalSeconds * waveform.length).round();
      final endSampleIndex = ((timeAtX + secondsPerPixel) / totalSeconds * waveform.length).round();
      
      if (startSampleIndex >= 0 && startSampleIndex < waveform.length) {
        // Calculate max amplitude for this bin
        double maxAmplitude = 0.0;
        // Take every 4th sample to increase density
        for (int i = startSampleIndex; i < endSampleIndex && i < waveform.length; i += 4) {
          maxAmplitude = maxAmplitude > waveform[i].abs() ? maxAmplitude : waveform[i].abs();
        }
        
        final barHeight = maxAmplitude * size.height * 0.6;
        canvas.drawLine(
          Offset(x.toDouble(), size.height / 2 - barHeight / 2),
          Offset(x.toDouble(), size.height / 2 + barHeight / 2),
          paint,
        );
      }
    }

    // Draw playhead
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,  // Made playhead slightly thinner too
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
  List<double> waveform = [];
  String? audioFilePath;

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
        _displayedPosition = _lastAudioPosition + dt;
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
    
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _handleDrag(details.primaryDelta ?? 0, context);
      },
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            CustomPaint(
              painter: TimelinePainter(
                positionSeconds: _displayedPosition,
                totalSeconds: widget.totalSeconds,
                windowSeconds: widget.windowSeconds,
                waveform: vm.waveform,
              ),
              size: Size.infinite,
            ),
          ],
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