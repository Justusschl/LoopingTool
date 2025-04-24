import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import '../widgets/song_timeline_slider.dart';
import '../widgets/segment_selector.dart';
import '../widgets/loop_settings_panel.dart';

class LoopingToolScreen extends StatelessWidget {
  const LoopingToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Looping Tool MVP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await vm.pickAudioFile();
                if (result != null) {
                  await audioService.loadFile(result);
                  vm.setAudioFile(result);
                }
              },
              child: const Text('Upload Audio File'),
            ),
            const SizedBox(height: 20),
            if (vm.audioFilePath != null) ...[
              Text('Loaded: ${vm.audioFilePath!.split('/').last}'),
              const SizedBox(height: 10),

              // Play/Pause Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => audioService.play(),
                    child: const Text('Play'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => audioService.pause(),
                    child: const Text('Pause'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Timeline slider with marker selection
              const SongTimelineSlider(),
              const SizedBox(height: 30),

              // Loop settings (speed, count, break)
              const LoopSettingsPanel(),
              const SizedBox(height: 30),

              // Loop trigger UI
              SegmentSelector(audioService: audioService),
            ],
          ],
        ),
      ),
    );
  }
}
