import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';

class SegmentLoopSlider extends StatelessWidget {
  const SegmentLoopSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    final segment = vm.selectedSegment;
    if (segment == null) return const SizedBox.shrink();

    final start = segment.start.timestamp;
    final end = segment.end.timestamp;
    final loopDuration = end - start;
    final current = audioService.position;
    final loopPosition = (current - start).inMilliseconds.clamp(0, loopDuration.inMilliseconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: loopPosition.toDouble(),
          max: loopDuration.inMilliseconds.toDouble(),
          onChanged: (_) {}, // This slider is not seekable
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(start)),
              Text(_format(end)),
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
