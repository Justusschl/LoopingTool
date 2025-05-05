import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import 'loop_count_selector.dart';
import 'break_duration_selector.dart';
import 'playback_speed_selector.dart';

class LoopSettingsPanel extends StatefulWidget {
  const LoopSettingsPanel({super.key});

  @override
  State<LoopSettingsPanel> createState() => _LoopSettingsPanelState();
}

class _LoopSettingsPanelState extends State<LoopSettingsPanel> {
  int breakSeconds = 5;
  double playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LoopCountSelector(
              loopCount: vm.loopCount,
              onIncrement: () {
                if (vm.loopCount < 99) vm.setLoopCount(vm.loopCount + 1);
              },
              onDecrement: () {
                if (vm.loopCount > 1) vm.setLoopCount(vm.loopCount - 1);
              },
            ),
            PlaybackSpeedSelector(
              speed: playbackSpeed,
              onDecrement: () {
                setState(() {
                  if (playbackSpeed > 0.7) {
                    playbackSpeed = (playbackSpeed - 0.1).clamp(0.7, 1.2);
                    playbackSpeed = double.parse(playbackSpeed.toStringAsFixed(1));
                  }
                });
              },
              onIncrement: () {
                setState(() {
                  if (playbackSpeed < 1.2) {
                    playbackSpeed = (playbackSpeed + 0.1).clamp(0.7, 1.2);
                    playbackSpeed = double.parse(playbackSpeed.toStringAsFixed(1));
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        BreakDurationSelector(
          breakSeconds: breakSeconds,
          onIncrement: () {
            setState(() {
              breakSeconds += 1;
            });
          },
          onDecrement: () {
            setState(() {
              if (breakSeconds > 1) breakSeconds -= 1;
            });
          },
        ),
      ],
    );
  }
}
