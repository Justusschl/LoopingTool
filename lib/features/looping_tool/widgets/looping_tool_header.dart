import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';
import 'package:file_picker/file_picker.dart';

class LoopingToolHeader extends StatelessWidget {
  const LoopingToolHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    // Helper to format duration
    String _formatDuration(Duration? d) {
      if (d == null) return '--:--';
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    // Helper to format file size (if you want to add this logic)
    String _formatFileSize(int? bytes) {
      if (bytes == null) return '';
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: back, title, save
        Row(
          children: [
            Icon(Icons.arrow_back, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Session 1',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: StadiumBorder(),
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Audio file info row and upload/change button
        Row(
          children: [
            if (vm.audioFilePath != null) ...[
              // Show info if audio loaded
              Text(
                vm.audioFilePath!.split('/').last,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDuration(audioService.duration),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 12),
              // You can add file size logic here if you want
              // For now, just show placeholder
              Text(
                '2.5 MB',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            Spacer(),
            TextButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                if (result != null && result.files.single.path != null) {
                  await audioService.loadFile(result.files.single.path!);
                  vm.setAudioFile(result.files.single.path!);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                vm.audioFilePath == null ? 'Upload Song' : 'Change',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}