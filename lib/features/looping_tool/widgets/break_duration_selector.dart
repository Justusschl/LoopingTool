import 'package:flutter/material.dart';

/// A widget that provides controls for adjusting the break duration between segment loops.
/// 
/// This widget displays:
/// - A "Break" label
/// - A decrement button (-)
/// - The current break duration in seconds
/// - An increment button (+)
/// 
/// The break duration controls are used to set how long the pause should be
/// between consecutive loops of a segment. The duration is displayed in seconds
/// with an 's' suffix (e.g., "5s").
class BreakDurationSelector extends StatelessWidget {
  /// The current break duration in seconds
  final int breakSeconds;

  /// Callback function triggered when the increment button is pressed
  final VoidCallback onIncrement;

  /// Callback function triggered when the decrement button is pressed
  final VoidCallback onDecrement;

  const BreakDurationSelector({
    super.key,
    required this.breakSeconds,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Break label
        const Text(
          'Break',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        // Decrement button
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Current break duration
        Text(
          '${breakSeconds}s',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        // Increment button
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
