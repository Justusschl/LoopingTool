import 'package:flutter/material.dart';

class LoopCountSelector extends StatelessWidget {
  final int loopCount;
  final VoidCallback onIncrement;
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minus button
        IconButton(
          onPressed: onDecrement,
          icon: Icon(Icons.remove, color: Colors.white, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
            padding: EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 8),
        // Loop icon and count
        Row(
          children: [
            Icon(Icons.repeat, color: Colors.white, size: 28),
            const SizedBox(width: 4),
            Text(
              '$loopCount',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Plus button
        IconButton(
          onPressed: onIncrement,
          icon: Icon(Icons.add, color: Colors.white, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
            padding: EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}
