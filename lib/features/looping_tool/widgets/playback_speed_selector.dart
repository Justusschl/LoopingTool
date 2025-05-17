import 'package:flutter/material.dart';

/// A widget that provides controls for adjusting the playback speed of audio segments.
/// 
/// This widget displays:
/// - A rewind button to decrease speed
/// - The current playback speed in a bordered container
/// - A fast-forward button to increase speed
/// 
/// The playback speed controls are used in segment cards to set how fast
/// a segment should play. The speed is displayed in a format like "0.7X" or "1.2X",
/// with special handling for 1.0X to display as "1X".
class PlaybackSpeedSelector extends StatelessWidget {
  /// The current playback speed multiplier (e.g., 0.7 for 70% speed)
  final double speed;

  /// Callback function triggered when the rewind button is pressed
  final VoidCallback onDecrement;

  /// Callback function triggered when the fast-forward button is pressed
  final VoidCallback onIncrement;

  const PlaybackSpeedSelector({
    super.key,
    required this.speed,
    required this.onDecrement,
    required this.onIncrement,
  });

  /// Formats the speed value for display
  /// 
  /// Returns a string in the format "NX" where:
  /// - N is the speed multiplier (e.g., "0.7" or "1.2")
  /// - Special case: "1.0" is displayed as "1"
  /// - Leading zeros are removed (e.g., "0.7" becomes ".7")
  String get displaySpeed {
    if (speed == 1.0) return '1X';
    String s = speed.toStringAsFixed(1);
    if (s.startsWith('0')) s = s.substring(1); // ".7" instead of "0.7"
    return '${s}X';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Speed decrease button
        IconButton(
          icon: Icon(Icons.fast_rewind, color: Colors.white, size: 18),
          onPressed: onDecrement,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        // Speed display container
        Container(
          height: 28,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            displaySpeed,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        // Speed increase button
        IconButton(
          icon: Icon(Icons.fast_forward, color: Colors.white, size: 18),
          onPressed: onIncrement,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
      ],
    );
  }
}
