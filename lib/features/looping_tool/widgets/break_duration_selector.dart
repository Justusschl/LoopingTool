import 'package:flutter/material.dart';

class BreakDurationSelector extends StatelessWidget {
  final int breakSeconds;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const BreakDurationSelector({
    Key? key,
    required this.breakSeconds,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Break',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        SizedBox(width: 16),
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Icon(Icons.remove, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 16),
        Text(
          '${breakSeconds}s',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        SizedBox(width: 16),
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
