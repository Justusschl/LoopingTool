import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

class SongTimelineSlider extends StatelessWidget {
  const SongTimelineSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        final duration = audioService.duration ?? Duration.zero;
        final position = audioService.position;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Slider(
              value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
              max: duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                audioService.seek(Duration(milliseconds: value.round()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final timestamp = audioService.position;
                final label = String.fromCharCode(65 + vm.markers.length); // A, B, C, ...
                vm.addMarker(label, timestamp);
              },
              child: const Text("Set Marker"),
            ),
            const SizedBox(height: 10),
            const Text("Markers:"),
            ...vm.markers.map((m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text("${m.label}: ${_formatDuration(m.timestamp)}"),
            )),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
