import 'package:flutter/material.dart';

/// A widget that provides controls for adjusting the number of times a segment should loop.
/// 
/// This widget displays:
/// - A decrement button (-)
/// - The current loop count
/// - A repeat icon
/// - An increment button (+)
/// 
/// The loop count controls are used in segment cards to set how many times
/// a segment should repeat during playback. The controls maintain a consistent
/// size and appearance with other UI elements.
class LoopCountSelector extends StatelessWidget {
  /// The current number of times the segment will loop
  final int loopCount;

  /// Callback function triggered when the increment button is pressed
  final VoidCallback onIncrement;

  /// Callback function triggered when the decrement button is pressed
  final VoidCallback onDecrement;

  const LoopCountSelector({
    super.key,
    required this.loopCount,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Decrement button
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
            child: Center(
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
        ),
        SizedBox(width: 8),
        // Repeat icon
        Icon(Icons.repeat, color: Colors.white, size: 18),
        SizedBox(width: 4),
        // Current loop count
        Text(
          '$loopCount',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        SizedBox(width: 8),
        // Increment button
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
            child: Center(
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
