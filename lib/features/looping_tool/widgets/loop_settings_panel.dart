import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import 'loop_count_selector.dart';

class LoopSettingsPanel extends StatelessWidget {
  const LoopSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Playback Speed"),
        Slider(
          value: vm.playbackSpeed,
          min: 0.8,
          max: 1.1,
          divisions: 6,
          label: "${(vm.playbackSpeed * 100).round()}%",
          onChanged: (value) => vm.setPlaybackSpeed(value),
        ),
        const SizedBox(height: 10),
        const Text("Loop Count"),
        LoopCountSelector(
          loopCount: vm.loopCount,
          onIncrement: () {
            if (vm.loopCount < 99) vm.setLoopCount(vm.loopCount + 1);
          },
          onDecrement: () {
            if (vm.loopCount > 1) vm.setLoopCount(vm.loopCount - 1);
          },
        ),
        const SizedBox(height: 10),
        const Text("Break Between Loops (seconds)"),
        Slider(
          value: vm.breakDuration.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: "${vm.breakDuration}s",
          onChanged: (value) => vm.setBreakDuration(value.toInt()),
        ),
      ],
    );
  }
}
