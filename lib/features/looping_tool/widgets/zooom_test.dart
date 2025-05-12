import 'package:flutter/material.dart';

class ZoomTest extends StatefulWidget {
  @override
  _ZoomTestState createState() => _ZoomTestState();
}

class _ZoomTestState extends State<ZoomTest> {
  double _zoomLevel = 1.0;
  double _lastZoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zoom Test')),
      body: GestureDetector(
        onScaleStart: (details) {
          _lastZoomLevel = _zoomLevel;
          print('Scale start: $_lastZoomLevel');
        },
        onScaleUpdate: (details) {
          setState(() {
            _zoomLevel = (_lastZoomLevel * details.scale).clamp(0.2, 10.0);
            print('Zoom: $_zoomLevel');
          });
        },
        child: Container(
          color: Colors.blue[100],
          child: Center(
            child: Text(
              'Zoom: ${_zoomLevel.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }
}
