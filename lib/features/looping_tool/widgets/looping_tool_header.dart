import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:marquee/marquee.dart';

/// The header widget for the Looping Tool application.
/// 
/// This widget provides:
/// - Navigation controls (back button)
/// - Session title
/// - Save functionality
/// - Audio file information display
/// - File upload/change controls
/// 
/// The header is organized in two rows:
/// 1. Top row: Navigation and session controls
/// 2. Bottom row: Audio file information and management
class LoopingToolHeader extends StatelessWidget {
  const LoopingToolHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoopingToolViewModel>(context);
    final audioService = Provider.of<AudioService>(context);

    /// Formats a Duration object into a MM:SS string
    /// 
    /// Returns '--:--' if duration is null
    String formatDuration(Duration? d) {
      if (d == null) return '--:--';
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    /// Formats file size in bytes to a human-readable string
    /// 
    /// Converts bytes to MB with one decimal place
    /// Returns empty string if bytes is null
    String formatFileSize(int? bytes) {
      if (bytes == null) return '';
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Navigation and session controls
        Row(
          children: [
            const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            const Expanded(
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
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bottom row: Audio file information and management
        Row(
          children: [
            if (vm.audioFilePath != null) ...[
              // Scrolling filename display
              SizedBox(
                width: 140, // Adjust width as needed for your layout
                height: 20,
                child: Marquee(
                  text: vm.audioFilePath!.split('/').last,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 40.0,
                  velocity: 30.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              const SizedBox(width: 12),
              // Audio duration display
              Text(
                formatDuration(audioService.duration),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 12),
              // File size display (currently hardcoded)
              const Text(
                '2.5 MB',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            const Spacer(),
            // File upload/change button
            TextButton(
              onPressed: () async {
                final typeGroup = XTypeGroup(
                  label: 'Audio',
                  extensions: ['mp3', 'wav', 'ogg', 'm4a'],
                );
                final file = await openFile(acceptedTypeGroups: [typeGroup]);
                if (file != null) {
                  await vm.setAudioFile(file.path);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                vm.audioFilePath == null ? 'Upload Song' : 'Change',
                style: const TextStyle(
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