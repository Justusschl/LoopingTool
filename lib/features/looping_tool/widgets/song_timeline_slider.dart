import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

/// A widget that displays a timeline slider for audio playback with marker visualization.
/// 
/// This widget provides:
/// - A slider for controlling audio playback position
/// - Visual representation of markers along the timeline
/// - Empty state when no audio is loaded
/// - Consistent height and layout across all states
/// 
/// The timeline slider integrates with:
/// - AudioService for playback control and position tracking
/// - LoopingToolViewModel for marker data
/// 
/// Features:
/// - Real-time position updates during playback
/// - Interactive seeking through the audio
/// - Visual markers showing segment boundaries
/// - Responsive layout that maintains consistent height
class SongTimelineSlider extends StatelessWidget {
  const SongTimelineSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioService>(context);
    final vm = Provider.of<LoopingToolViewModel>(context);
    final duration = audioService.duration;
    final position = audioService.position;
    final markers = vm.markers;

    // Set a constant height for the slider area
    const sliderHeight = 32.0;

    if (duration == null || duration == Duration.zero) {
      // No audio loaded: show an empty timeline bar with the same height as the slider
      return SizedBox(
        height: sliderHeight,
        child: Center(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
      );
    }

    // Audio loaded: show the real slider, but keep the height the same
    return SizedBox(
      height: sliderHeight,
      child: Stack(
        children: [
          // The slider
          Slider(
            value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
            max: duration.inMilliseconds.toDouble(),
            onChanged: (value) => audioService.seek(Duration(milliseconds: value.round())),
          ),
          // Markers overlay
          if (duration.inMilliseconds > 0)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackWidth = constraints.maxWidth;
                    const markerWidth = 3.0;
                    return Stack(
                      children: markers.map((marker) {
                        // Calculate marker position based on timestamp ratio
                        final markerRatio = marker.timestamp.inMilliseconds / duration.inMilliseconds;
                        final left = (markerRatio * trackWidth) - (markerWidth / 2) + 7;
                        return Positioned(
                          left: left,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: markerWidth,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(markerWidth / 2),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Formats a Duration into a MM:SS string
  /// 
  /// Returns a string in the format "MM:SS" where:
  /// - MM: minutes (padded with leading zero)
  /// - SS: seconds (padded with leading zero)
  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
