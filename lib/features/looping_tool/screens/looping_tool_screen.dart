import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/services/audio_service.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import '../widgets/song_timeline_slider.dart';
import '../widgets/loop_settings_panel.dart';
import '../widgets/segment_selector.dart';

class LoopingToolScreen extends StatelessWidget {
  const LoopingToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Looping Tool MVP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                if (result != null && result.files.single.path != null) {
                  await audioService.loadFile(result.files.single.path!);
                  vm.setAudioFile(result.files.single.path!);
                }
              },
              child: const Text('Upload Audio File'),
            ),
            const SizedBox(height: 20),

            if (vm.audioFilePath != null) ...[
              Text('Loaded: ${vm.audioFilePath!.split('/').last}'),
              const SizedBox(height: 20),

              // Play/Pause toggle button
              ElevatedButton(
                onPressed: () {
                  audioService.isPlaying ? audioService.pause() : audioService.play();
                },
                child: Text(audioService.isPlaying ? 'Pause' : 'Play'),
              ),

              const SizedBox(height: 30),
              const SongTimelineSlider(),

              const SizedBox(height: 20),
              const LoopSettingsPanel(),
              const SizedBox(height: 20),
              SegmentSelector(audioService: audioService),
            ],
          ],
        ),
      ),
    );
  }
}
