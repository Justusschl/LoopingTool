import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import 'package:looping_tool_mvp/data/models/marker.dart';

/// A widget that provides a customizable timeline visualization for audio playback.
/// 
/// This widget implements the core timeline visualization with:
/// - Time markers and grid lines
/// - Playhead visualization
/// - Marker labels and positions
/// - Waveform visualization
/// 
/// The timeline is designed to be used as a base component for more complex
/// timeline implementations, providing the core painting and layout logic.
class CustomTimeline extends StatelessWidget {
  /// Current playback position in seconds
  final double positionSeconds;

  /// Total duration of the audio in seconds
  final double totalSeconds;

  /// Number of seconds visible in the current viewport
  final double windowSeconds;

  /// Current zoom level of the timeline
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

/// A custom painter that handles the drawing of the timeline visualization.
/// 
/// This painter is responsible for:
/// - Drawing time markers and grid lines
/// - Rendering the playhead
/// - Displaying markers and their labels
/// - Visualizing the waveform
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
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final secondsPerPixel = windowSeconds / size.width;

    // Draw time markers
    final bigDashHeight = size.height * 0.8;
    final smallDashHeight = size.height * 0.4;
    final dashInterval = 0.5; // seconds between dashes

    // Calculate visible time range
    final minTime = positionSeconds - windowSeconds / 2;
    final maxTime = positionSeconds + windowSeconds / 2;

    // Draw time markers
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
        ..color = Colors.red
        ..strokeWidth = 2,
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

/// A widget that provides smooth animation for timeline position updates.
/// 
/// This widget handles:
/// - Smooth transitions during playback
/// - Position updates during seeking
/// - Animation timing and synchronization
class AnimatedTimeline extends StatefulWidget {
  /// Current playback position in seconds
  final double positionSeconds;

  /// Total duration of the audio in seconds
  final double totalSeconds;

  /// Number of seconds visible in the current viewport
  final double windowSeconds;

  /// Whether audio is currently playing
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
  /// Ticker for smooth animation updates
  late final Ticker _ticker;

  /// Current displayed position for smooth animation
  double _displayedPosition = 0.0;

  /// Last known audio position for seeking detection
  double _lastAudioPosition = 0.0;

  /// Last update timestamp for animation timing
  late DateTime _lastUpdateTime;

  /// Whether the user is currently interacting with the timeline
  final bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _displayedPosition = widget.positionSeconds;
    _lastAudioPosition = widget.positionSeconds;
    _lastUpdateTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

  /// Updates the displayed position during playback
  void _onTick(Duration elapsed) {
    if (_isInteracting || !widget.isPlaying) return;

    final now = DateTime.now();
    final dt = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;

    setState(() {
      _displayedPosition += dt;

      // Handle seeking
      if ((widget.positionSeconds - _lastAudioPosition).abs() > 1.0) {
        _displayedPosition = widget.positionSeconds;
      }

      // Prevent overshooting
      if (_displayedPosition > widget.positionSeconds) {
        _displayedPosition = widget.positionSeconds;
      }

      _lastAudioPosition = widget.positionSeconds;
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle seeking
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
