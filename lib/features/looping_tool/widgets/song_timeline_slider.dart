import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../widgets/custom_timeline.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

class SongTimelineSlider extends StatelessWidget {
  const SongTimelineSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioService>(context);
    final vm = Provider.of<LoopingToolViewModel>(context);
    final duration = audioService.duration;
    final position = audioService.position;
    final markers = vm.markers;

    if (duration == null || duration == Duration.zero) {
      // No audio loaded: show an empty timeline bar
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('00:00', style: TextStyle(color: Colors.white54)),
              Text('--:--', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ],
      );
    }

    // Audio loaded: show the real slider
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Default slider padding
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final trackWidth = constraints.maxWidth;
                      const markerWidth = 3.0;
                      return Stack(
                        children: markers.map((marker) {
                          final markerRatio = marker.timestamp.inMilliseconds / duration.inMilliseconds;
                          final left = (markerRatio * trackWidth) - (markerWidth / 2) + 7; // +4 to center the marker
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(position), style: const TextStyle(color: Colors.white)),
              Text(_format(duration), style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
