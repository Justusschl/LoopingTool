import 'package:flutter/material.dart';

class PlaybackSpeedSelector extends StatelessWidget {
  final double speed;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const PlaybackSpeedSelector({
    super.key,
    required this.speed,
    required this.onDecrement,
    required this.onIncrement,
  });

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
        IconButton(
          icon: Icon(Icons.fast_rewind, color: Colors.white, size: 18),
          onPressed: onDecrement,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
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
