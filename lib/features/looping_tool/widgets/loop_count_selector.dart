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
      children: [
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
        Icon(Icons.repeat, color: Colors.white, size: 18),
        SizedBox(width: 4),
        Text(
          '$loopCount',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        SizedBox(width: 8),
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
