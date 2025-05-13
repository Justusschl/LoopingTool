import 'package:flutter/material.dart';

class BreakDurationSelector extends StatelessWidget {
  final int breakSeconds;
  final VoidCallback onIncrement;
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
        Text(
          'Break',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        SizedBox(width: 8),
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
            child: Center(
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          '${breakSeconds}s',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        SizedBox(width: 8),
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
            child: Center(
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
