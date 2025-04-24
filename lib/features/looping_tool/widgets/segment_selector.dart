import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';

class SegmentSelector extends StatelessWidget {
  final AudioService audioService;

  const SegmentSelector({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);

    if (vm.markers.length < 2) {
      return const Text("Add at least 2 markers to define a segment.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Segment to Loop"),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<String>(
              hint: const Text("Start"),
              value: vm.selectedSegment?.start.label,
              items: vm.markers
                  .map((m) => DropdownMenuItem(
                        value: m.label,
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (label) {
                if (label != null && vm.selectedSegment?.end.label != label) {
                  vm.selectSegmentByLabels(label, vm.selectedSegment?.end.label ?? label);
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
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (label) {
                if (label != null && vm.selectedSegment?.start.label != label) {
                  vm.selectSegmentByLabels(vm.selectedSegment?.start.label ?? label, label);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final segment = vm.selectedSegment;
            if (segment != null) {
              audioService.seek(segment.start.timestamp);
              audioService.play();
            }
          },
          child: const Text("Loop Selected Segment"),
        ),
      ],
    );
  }
}

