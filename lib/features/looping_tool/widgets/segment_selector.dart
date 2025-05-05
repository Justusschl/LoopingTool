import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';
import 'loop_count_selector.dart';
import 'playback_speed_selector.dart';

class SegmentSelector extends StatefulWidget {
  final AudioService audioService;

  const SegmentSelector({super.key, required this.audioService});

  @override
  State<SegmentSelector> createState() => _SegmentSelectorState();
}

class _SegmentSelectorState extends State<SegmentSelector> {
  late final AudioService audioService;

  @override
  void initState() {
    super.initState();
    audioService = widget.audioService;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoopingToolViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            DropdownButton<String>(
              hint: const Text("Start"),
              value: vm.selectedSegment?.start.label,
              items: vm.markers
                  .map((m) => DropdownMenuItem(
                        value: m.label,
                        child: Text("${m.label} (${_formatDuration(m.timestamp)})"),
                      ))
                  .toList(),
              onChanged: (label) {
                if (label != null) {
                  final endLabel = vm.selectedSegment?.end.label;
                  if (endLabel != null && endLabel != label) {
                    vm.selectSegmentByLabels(label, endLabel);
                  } else {
                    // If no end selected yet, use the next marker
                    final currentIndex = vm.markers.indexWhere((m) => m.label == label);
                    if (currentIndex < vm.markers.length - 1) {
                      vm.selectSegmentByLabels(label, vm.markers[currentIndex + 1].label);
                    }
                  }
                }
              },
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              hint: const Text("End"),
              value: vm.selectedSegment?.end.label,
              items: vm.markers
                  .map((m) => DropdownMenuItem(
                        value: m.label,
                        child: Text("${m.label} (${_formatDuration(m.timestamp)})"),
                      ))
                  .toList(),
              onChanged: (label) {
                if (label != null) {
                  final startLabel = vm.selectedSegment?.start.label;
                  if (startLabel != null && startLabel != label) {
                    vm.selectSegmentByLabels(startLabel, label);
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (vm.selectedSegment != null) ...[
          Text(
            "Selected Segment: ${_formatDuration(vm.selectedSegment!.duration)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                textStyle: TextStyle(fontSize: 13),
                minimumSize: Size(0, 32),
              ),
              onPressed: () {
                final segment = vm.selectedSegment;
                if (segment != null) {
                  widget.audioService.loopSegment(
                    segment.start.timestamp,
                    segment.end.timestamp,
                    vm.loopCount,
                    vm.breakDuration,
                  );
                }
              },
              child: const Text("Loop Selected Segment"),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 28,
                child: LoopCountSelector(
                  loopCount: vm.loopCount,
                  onIncrement: () {
                    if (vm.loopCount < 99) vm.setLoopCount(vm.loopCount + 1);
                  },
                  onDecrement: () {
                    if (vm.loopCount > 1) vm.setLoopCount(vm.loopCount - 1);
                  },
                ),
              ),
              SizedBox(
                height: 28,
                child: PlaybackSpeedSelector(
                  speed: vm.playbackSpeed,
                  onDecrement: () => vm.setPlaybackSpeed(
                    (vm.playbackSpeed - 0.1).clamp(0.7, 1.2),
                  ),
                  onIncrement: () => vm.setPlaybackSpeed(
                    (vm.playbackSpeed + 0.1).clamp(0.7, 1.2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$milliseconds';
  }
}
