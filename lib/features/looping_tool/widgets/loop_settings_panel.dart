import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import 'loop_count_selector.dart';
import 'break_duration_selector.dart';
import 'playback_speed_selector.dart';

/// A widget that provides a panel for configuring loop-related settings.
/// 
/// This panel combines multiple controls for segment playback configuration:
/// - Loop count selection (how many times to repeat)
/// - Playback speed adjustment (0.7x to 1.2x)
/// - Break duration setting (pause between loops)
/// 
/// The panel integrates with the LoopingToolViewModel to manage global
/// settings and maintains local state for break duration.
class LoopSettingsPanel extends StatefulWidget {
  const LoopSettingsPanel({super.key});

  @override
  State<LoopSettingsPanel> createState() => _LoopSettingsPanelState();
}

class _LoopSettingsPanelState extends State<LoopSettingsPanel> {
  /// The duration of the break between loops in seconds
  /// Initialized to 5 seconds
  int breakSeconds = 5;

  /// The current playback speed multiplier
  /// Initialized to 1.0 (normal speed)
  double playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with loop count and playback speed controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Loop count selector with bounds checking
            LoopCountSelector(
              loopCount: vm.loopCount,
              onIncrement: () {
                if (vm.loopCount < 99) vm.setLoopCount(vm.loopCount + 1);
              },
              onDecrement: () {
                if (vm.loopCount > 1) vm.setLoopCount(vm.loopCount - 1);
              },
            ),
            // Playback speed selector with bounds checking
            PlaybackSpeedSelector(
              speed: vm.playbackSpeed,
              onDecrement: () {
                final newSpeed = (vm.playbackSpeed - 0.1).clamp(0.7, 1.2);
                vm.setPlaybackSpeed(newSpeed);
              },
              onIncrement: () {
                final newSpeed = (vm.playbackSpeed + 0.1).clamp(0.7, 1.2);
                vm.setPlaybackSpeed(newSpeed);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Break duration selector with local state management
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
