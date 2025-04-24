import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/looping_tool_viewmodel.dart';

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
        DropdownButton<int>(
          value: vm.loopCount,
          items: List.generate(10, (i) => i + 1)
              .map((count) => DropdownMenuItem(
                    value: count,
                    child: Text("$count"),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) vm.setLoopCount(value);
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
