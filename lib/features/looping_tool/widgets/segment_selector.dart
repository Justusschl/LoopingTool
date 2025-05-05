import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';

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
        const Text("Select Segment to Loop"),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final timestamp = audioService.position;
            final label = String.fromCharCode(65 + vm.markers.length);
            vm.addMarker(label, timestamp);
          },
          child: const Text("Set Marker"),
        ),
        const SizedBox(height: 12),
        if (vm.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Wrap(
          spacing: 8,
          children: vm.markers.map((m) {
            return Chip(
              label: Text("${m.label}: ${_formatDuration(m.timestamp)}"),
              onDeleted: () {
                vm.removeMarker(m);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (vm.markers.length < 2)
          const Text("Add at least 2 markers to define a segment."),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
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
