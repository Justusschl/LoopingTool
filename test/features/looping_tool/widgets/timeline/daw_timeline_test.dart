/// Tests for the DAWTimeline widget.
/// 
/// These tests verify the visual and interactive aspects of the timeline, including:
/// - Widget rendering and layout
/// - User interaction handling
/// - State management through the ViewModel
/// - Visual feedback and updates
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looping_tool_mvp/features/looping_tool/widgets/timeline/daw_timeline.dart';
import 'package:looping_tool_mvp/features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  late LoopingToolViewModel viewModel;

  /// Set up a fresh ViewModel instance before each test
  setUp(() {
    viewModel = LoopingToolViewModel();
  });

  /// Creates a test environment for the DAWTimeline widget
  /// 
  /// Wraps the widget in necessary providers and scaffolding
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<LoopingToolViewModel>.value(
        value: viewModel,
        child: Scaffold(
          body: DAWTimeline(
            audioPosition: 0.0,
            totalSeconds: 60.0,
            isPlaying: false,
            waveform: [],
            onPositionChanged: (position) {},
          ),
        ),
      ),
    );
  }

  group('DAWTimeline Widget Tests', () {
    /// Verify that the widget renders without crashing
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(DAWTimeline), findsOneWidget);
    });

    /// Test that the timeline has correct dimensions
    testWidgets('displays timeline with correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final timelineFinder = find.byType(DAWTimeline);
      expect(timelineFinder, findsOneWidget);
      
      final RenderBox timelineBox = tester.renderObject(timelineFinder);
      expect(timelineBox.size.width, greaterThan(0));
      expect(timelineBox.size.height, greaterThan(0));
    });

    /// Test that the timeline responds to user interaction
    testWidgets('responds to tap events', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Tap in the middle of the timeline
      await tester.tapAt(const Offset(100, 50));
      await tester.pump();
      
      // Verify that the viewModel was updated
      expect(viewModel.markers.length, 1);
    });
  });
} 