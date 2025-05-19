import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your real widgets and viewmodel here
import '../viewmodels/looping_tool_viewmodel.dart';
import '../widgets/looping_tool_header.dart';
import '../widgets/segment_selector.dart';
import '../widgets/song_timeline_slider.dart';
import '../widgets/break_duration_selector.dart';
import '../../../core/services/audio_service.dart';
import '../widgets/timeline/daw_timeline.dart';

/// The main screen of the Looping Tool application.
/// 
/// This screen serves as the primary interface for the application, providing:
/// - Audio file selection and playback controls
/// - Timeline visualization with waveform
/// - Marker management
/// - Segment selection and configuration
/// - Break duration controls
/// - Countdown toggle
/// 
/// The screen is organized in a vertical layout with:
/// 1. Header (navigation and file info)
/// 2. Timeline visualization
/// 3. Marker addition button
/// 4. Segment management area
/// 5. Break duration and countdown controls
/// 6. Playback controls
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Tracks whether a new segment is being added
  bool addingSegment = false;

  @override
  Widget build(BuildContext context) {
    // Get access to the view model and audio service
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section with navigation and file info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LoopingToolHeader(),
            ),
            // Timeline visualization with waveform
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
            // Marker addition button
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 4),
                child: IconButton(
                  icon: const Icon(Icons.add_box_outlined, color: Colors.white, size: 28),
                  onPressed: () {
                    final timestamp = audioService.position;
                    final label = String.fromCharCode(65 + vm.markers.length); // 'A', 'B', etc.
                    vm.addMarker(label, timestamp);
                  },
                ),
              ),
            ),
            // Segment management area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Builder(
                  builder: (context) {
                    final markerCount = vm.markers.length;
                    // Show different UI based on number of markers
                    if (markerCount == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('No markers have been added yet!', style: TextStyle(color: Colors.white)),
                        ),
                      );
                    } else if (markerCount == 1) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Add another marker to build segment', style: TextStyle(color: Colors.white)),
                        ),
                      );
                    } else {
                      return SegmentSelector(audioService: Provider.of(context, listen: false));
                    }
                  },
                ),
              ),
            ),
            // Break duration and countdown controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  BreakDurationSelector(
                    breakSeconds: vm.breakDuration,
                    onIncrement: () => vm.setBreakDuration(vm.breakDuration + 1),
                    onDecrement: () => vm.setBreakDuration(vm.breakDuration > 1 ? vm.breakDuration - 1 : 1),
                  ),
                  const Spacer(),
                  const Text('Countdown', style: TextStyle(color: Colors.white, fontSize: 12)),
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
            // Timeline slider for fine position control
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: SongTimelineSlider(),
            ), 
            // Playback controls (previous, play/pause, next)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 24), onPressed: () {}),
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 24), onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
