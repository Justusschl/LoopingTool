/// Tests for the LoopingToolViewModel class.
/// 
/// These tests verify the business logic of the ViewModel, including:
/// - Initial state management
/// - Marker addition and removal
/// - Segment selection and validation
/// - State updates and notifications
import 'package:flutter_test/flutter_test.dart';
import 'package:looping_tool_mvp/features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'package:looping_tool_mvp/data/models/marker.dart';
import 'package:looping_tool_mvp/data/models/segment.dart';

void main() {
  late LoopingToolViewModel viewModel;

  /// Set up a fresh ViewModel instance before each test
  setUp(() {
    viewModel = LoopingToolViewModel();
  });

  group('LoopingToolViewModel Tests', () {
    /// Verify that the ViewModel starts with empty markers and no selected segment
    test('Initial state should have empty markers and no selected segment', () {
      expect(viewModel.markers, isEmpty);
      expect(viewModel.selectedSegment, isNull);
    });

    /// Test adding a marker and verify it's correctly stored
    test('Adding a marker should update markers list', () {
      viewModel.addMarker('Test Marker', const Duration(seconds: 1));

      expect(viewModel.markers.length, 1);
      expect(viewModel.markers.first.label, 'Test Marker');
    });

    /// Test creating a segment by selecting two markers
    test('Adding two markers should allow segment selection', () {
      viewModel.addMarker('Start', const Duration(seconds: 0));
      viewModel.addMarker('End', const Duration(seconds: 1));

      viewModel.selectSegmentByLabels('Start', 'End');

      expect(viewModel.selectedSegment, isNotNull);
      expect(viewModel.selectedSegment!.start.label, 'Start');
      expect(viewModel.selectedSegment!.end.label, 'End');
    });

    /// Test that removing markers properly cleans up the selected segment
    test('Removing a marker should clear selected segment', () {
      viewModel.addMarker('Start', const Duration(seconds: 0));
      viewModel.addMarker('End', const Duration(seconds: 1));
      viewModel.selectSegmentByLabels('Start', 'End');
      viewModel.markers.clear();

      expect(viewModel.markers, isEmpty);
      expect(viewModel.selectedSegment, isNull);
    });
  });
} 