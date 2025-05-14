import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your real widgets and viewmodel here
import '../viewmodels/looping_tool_viewmodel.dart';
import '../widgets/looping_tool_header.dart';
import '../widgets/segment_selector.dart';
import '../widgets/song_timeline_slider.dart';
import '../widgets/break_duration_selector.dart';
import '../../../core/services/audio_service.dart';
import '../widgets/timeline_zoom_test.dart';

// ... other imports

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SizedBox(
                height: 120,
                child: DAWTimeline(
                  audioPosition: audioService.position.inSeconds.toDouble(),
                  totalSeconds: (audioService.duration?.inSeconds ?? 0).toDouble(),
                  isPlaying: audioService.isPlaying,
                  waveform: vm.waveform,
                  onPositionChanged: (newPosition) {
                    audioService.seek(Duration(seconds: newPosition.round()));
                  },
                ),
              ),
            ),
            // Add Segment Button (moved closer to timeline, text removed)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 4),
                child: IconButton(
                  icon: Icon(Icons.add_box_outlined, color: Colors.white, size: 28),
                  onPressed: () {
                    final timestamp = audioService.position;
                    final label = String.fromCharCode(65 + vm.markers.length); // 'A', 'B', etc.
                    vm.addMarker(label, timestamp);
                  },
                ),
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
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white),
                                    ),
                                    child: Text('Add Segment', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
            // Break & Countdown Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  BreakDurationSelector(
                    breakSeconds: vm.breakDuration,
                    onIncrement: () => vm.setBreakDuration(vm.breakDuration + 1),
                    onDecrement: () => vm.setBreakDuration(vm.breakDuration > 1 ? vm.breakDuration - 1 : 1),
                  ),
                  Spacer(),
                  Text('Countdown', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: vm.countdownEnabled,
                      onChanged: (val) => vm.setCountdownEnabled(val ?? false),
                      activeColor: Colors.red,
                      checkColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Slider Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: SongTimelineSlider(),
            ), 
            // Playback Controls Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: Icon(Icons.skip_previous, color: Colors.white, size: 24), onPressed: () {}),
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 32,
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
                  SizedBox(width: 8),
                  IconButton(icon: Icon(Icons.skip_next, color: Colors.white, size: 24), onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
