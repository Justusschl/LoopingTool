import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your real widgets and viewmodel here
import '../viewmodels/looping_tool_viewmodel.dart';
import '../widgets/looping_tool_header.dart';
import '../widgets/custom_timeline.dart';
import '../widgets/segment_selector.dart';
import '../widgets/song_timeline_slider.dart';
import '../widgets/break_duration_selector.dart';
import '../widgets/playback_speed_selector.dart';
import '../../../core/services/audio_service.dart';
// ... other imports

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool addingSegment = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: back, title, save, audio info, edit/play toggle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LoopingToolHeader(),
            ),
            // Timeline/Segment Selector (use your custom timeline as placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomTimeline(
                positionSeconds: audioService.position.inSeconds.toDouble(),
                totalSeconds: audioService.duration?.inSeconds ?? 0,
              ),
            ),
            // Add Segment Button and Instruction
            Center(
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.add_box_outlined, color: Colors.white, size: 32),
                    onPressed: () {
                      final timestamp = audioService.position;
                      final label = String.fromCharCode(65 + vm.markers.length); // 'A', 'B', etc.
                      vm.addMarker(label, timestamp);
                    },
                  ),
                  Text(
                    'Tap on + to add segment. Pinch to zoom.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Segment Card or Empty State
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: vm.selectedSegment != null
                    ? SegmentSelector(audioService: Provider.of(context, listen: false))
                    : addingSegment
                        ? SegmentSelector(audioService: Provider.of(context, listen: false))
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('No Segments have been added yet!', style: TextStyle(color: Colors.white)),
                                  SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        addingSegment = true;
                                      });
                                    },
                                    child: Text('Add Segment', style: TextStyle(color: Colors.white)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
            // Break & Prelude Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: BreakDurationSelector(
                      breakSeconds: vm.breakDuration,
                      onIncrement: () => vm.setBreakDuration(vm.breakDuration + 1),
                      onDecrement: () => vm.setBreakDuration(vm.breakDuration > 1 ? vm.breakDuration - 1 : 1),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Prelude', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: vm.preludeEnabled,
                    onChanged: (val) => vm.setPreludeEnabled(val),
                    activeColor: Colors.red,
                  ),
                ],
              ),
            ),
            // Main Timeline Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SongTimelineSlider(),
            ),
            // Playback Controls (replace with your actual controls if needed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: Icon(Icons.skip_previous, color: Colors.white, size: 32), onPressed: () {}),
                  SizedBox(width: 16),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 32,
                      ),
                      onPressed: () {
                        if (audioService.isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.play();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(icon: Icon(Icons.skip_next, color: Colors.white, size: 32), onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
