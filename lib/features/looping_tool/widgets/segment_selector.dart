import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/looping_tool_viewmodel.dart';
import '../../../core/services/audio_service.dart';
import 'loop_count_selector.dart';
import 'playback_speed_selector.dart';

class SegmentSelector extends StatefulWidget {
  final AudioService audioService;

  const SegmentSelector({super.key, required this.audioService});

  @override
  State<SegmentSelector> createState() => _SegmentSelectorState();
}

class _SegmentSelectorState extends State<SegmentSelector> {
  late final AudioService audioService;
  int? expandedIndex; // Track which segment is expanded

  @override
  void initState() {
    super.initState();
    audioService = widget.audioService;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoopingToolViewModel>();
    final markers = vm.markers;

    if (markers.length == 0) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No markers have been added yet!',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      );
    }
    if (markers.length == 1) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Add another marker to build segment',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      );
    }

    // Build segments: (A-B), (B-C), ...
    final segments = <Map<String, dynamic>>[];
    for (int i = 0; i < markers.length - 1; i++) {
      segments.add({
        'start': markers[i],
        'end': markers[i + 1],
        'label': '${markers[i].label}-${markers[i + 1].label}',
      });
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: segments.length,
          itemBuilder: (context, idx) {
            final seg = segments[idx];
            final start = seg['start'];
            final end = seg['end'];
            final segmentLabel = seg['label'];
            final segmentStart = _formatDuration(start.timestamp);
            final segmentEnd = _formatDuration(end.timestamp);
            final isExpanded = expandedIndex == idx;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.grey[850] : Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isExpanded ? Colors.red : Colors.white24, width: isExpanded ? 2 : 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? null : idx;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            segmentLabel,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$segmentStart  -  $segmentEnd',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          SizedBox(width: 8),
                          if (isExpanded)
                            IconButton(
                              icon: Icon(Icons.play_arrow, color: Colors.white, size: 22),
                              tooltip: 'Play segment',
                              onPressed: () {
                                widget.audioService.loopSegment(
                                  start.timestamp,
                                  end.timestamp,
                                  vm.loopCount,
                                  vm.breakDuration,
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          Spacer(),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (value) {
                              if (value == 'delete') {
                                // Remove both markers and segment
                                vm.removeMarker(start);
                                vm.removeMarker(end);
                                setState(() {
                                  expandedIndex = null;
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete segment'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 28,
                              child: LoopCountSelector(
                                loopCount: vm.loopCount,
                                onIncrement: () {
                                  if (vm.loopCount < 99) vm.setLoopCount(vm.loopCount + 1);
                                },
                                onDecrement: () {
                                  if (vm.loopCount > 1) vm.setLoopCount(vm.loopCount - 1);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 28,
                              child: PlaybackSpeedSelector(
                                speed: vm.playbackSpeed,
                                onDecrement: () {
                                  final newSpeed = (vm.playbackSpeed - 0.1).clamp(0.7, 1.2);
                                  vm.setPlaybackSpeed(newSpeed);
                                },
                                onIncrement: () {
                                  final newSpeed = (vm.playbackSpeed + 0.1).clamp(0.7, 1.2);
                                  vm.setPlaybackSpeed(newSpeed);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$milliseconds';
  }
}
