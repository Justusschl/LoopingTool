import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import '../widgets/song_timeline_slider.dart';
import '../widgets/loop_settings_panel.dart';
import '../widgets/segment_selector.dart';
import '../widgets/looping_tool_header.dart';

/// Main screen for the Looping Tool MVP
/// This screen allows users to upload an audio file, play/pause it, and set loop settings.
class LoopingToolExperimentScreen extends StatelessWidget {
  const LoopingToolExperimentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoopingToolHeader(),
              const SizedBox(height: 24),
              

              // Play/Pause toggle button
              ElevatedButton(
                onPressed: () {
                  audioService.isPlaying ? audioService.pause() : audioService.play();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white, // or your preferred color
                  foregroundColor: Colors.black, // icon color
                ),
                child: Icon(
                  audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
              ),

              const SizedBox(height: 30),

              // Timeline area: always visible
              const SongTimelineSlider(),

              const SizedBox(height: 20),
              // Loop Settings: always visible
              const LoopSettingsPanel(),
              const SizedBox(height: 20),
              // Segment Selector: always visible
              SegmentSelector(audioService: audioService),
            ],
          ),
        ),
      ),
    );
  }
}
