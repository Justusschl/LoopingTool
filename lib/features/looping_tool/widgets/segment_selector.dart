import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';

class SegmentSelector extends StatefulWidget {
  final AudioService audioService;

  const SegmentSelector({super.key, required this.audioService});

  @override
  State<SegmentSelector> createState() => _SegmentSelectorState();
}

class _SegmentSelectorState extends State<SegmentSelector> {
  double _loopSliderValue = 0.0;
  Duration? _loopDuration;
  Duration? _loopStart;

  @override
  void initState() {
    super.initState();
    widget.audioService.addListener(_updateLoopSlider);
  }

  @override
  void dispose() {
    widget.audioService.removeListener(_updateLoopSlider);
    super.dispose();
  }

  void _updateLoopSlider() {
    final vm = context.read<LoopingToolViewModel>();
    final segment = vm.selectedSegment;
    if (segment == null) return;

    final position = widget.audioService.loopPlayerPosition;
    final start = segment.start.timestamp;
    final end = segment.end.timestamp;
    final duration = end - start;
    final relativePos = position - start;

    if (relativePos >= Duration.zero && relativePos <= duration) {
      setState(() {
        _loopSliderValue = relativePos.inMilliseconds.toDouble();
        _loopDuration = duration;
        _loopStart = start;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoopingToolViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {
            final timestamp = widget.audioService.position; // use main player
            final label = String.fromCharCode(65 + vm.markers.length);
            vm.addMarker(label, timestamp);
          },
          child: const Text("Set Marker"),
        ),
        const SizedBox(height: 8),
        if (vm.markers.isNotEmpty)
          Wrap(
            spacing: 8,
            children: vm.markers
                .map((m) => Chip(label: Text("${m.label}: ${_formatDuration(m.timestamp)}")))
                .toList(),
          ),
        const SizedBox(height: 8),
        if (vm.markers.length < 2)
          const Text("Add at least 2 markers to define a segment."),
        if (vm.markers.length >= 2) ...[
          Row(
            children: [
              DropdownButton<String>(
                hint: const Text("Start"),
                value: vm.selectedSegment?.start.label,
                items: vm.markers
                    .map((m) => DropdownMenuItem(
                          value: m.label,
                          child: Text(m.label),
                        ))
                    .toList(),
                onChanged: (label) {
                  if (label != null && vm.selectedSegment?.end.label != label) {
                    vm.selectSegmentByLabels(
                        label, vm.selectedSegment?.end.label ?? label);
                  }
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                hint: const Text("End"),
                value: vm.selectedSegment?.end.label,
                items: vm.markers
                    .map((m) => DropdownMenuItem(
                          value: m.label,
                          child: Text(m.label),
                        ))
                    .toList(),
                onChanged: (label) {
                  if (label != null && vm.selectedSegment?.start.label != label) {
                    vm.selectSegmentByLabels(
                        vm.selectedSegment?.start.label ?? label, label);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final segment = vm.selectedSegment;
              if (segment != null) {
                widget.audioService.loopSegment(
                  segment.start.timestamp,
                  segment.end.timestamp,
                  vm.loopCount,
                  vm.breakDuration,
                );
              }
            },
            child: const Text("Loop Selected Segment"),
          ),
          const SizedBox(height: 24),
          if (_loopDuration != null && _loopStart != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Loop Segment Timeline"),
                Slider(
                  value: _loopSliderValue,
                  min: 0.0,
                  max: _loopDuration!.inMilliseconds.toDouble(),
                  onChanged: (_) {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(Duration.zero)),
                      Text(_formatDuration(_loopDuration!)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
