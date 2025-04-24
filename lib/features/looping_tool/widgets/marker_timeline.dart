import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

class MarkerTimeline extends StatelessWidget {
  final AudioService audioService;

  const MarkerTimeline({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final duration = audioService.duration ?? Duration.zero;

    return Column(
      children: [
        // Slider for timeline
        Consumer<AudioService>(
          builder: (context, audio, _) {
            final position = audio.position;
            return Slider(
              value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                final newPos = Duration(milliseconds: value.toInt());
                vm.setStartPosition(newPos); // Optionally save marker
                audio.seek(newPos); // Jump to selected point
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(audioService.position)),
            Text(_formatDuration(duration)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
