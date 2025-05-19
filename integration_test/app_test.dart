/// Integration tests for the Looping Tool application.
/// 
/// These tests verify the application's functionality from a user's perspective,
/// testing complete user flows and interactions. They ensure that:
/// - The app launches correctly
/// - User interactions work as expected
/// - Features integrate properly
/// - The UI updates correctly
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:looping_tool_mvp/main.dart' as app;
import 'package:looping_tool_mvp/features/looping_tool/widgets/timeline/daw_timeline.dart';

void main() {
  /// Initialize integration test bindings
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    /// Test that the app launches and shows the main screen
    testWidgets('App launches and shows main screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the main screen is displayed
      expect(find.byType(Scaffold), findsOneWidget);
    });

    /// Test the marker creation and removal workflow
    testWidgets('Can add and remove markers', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the timeline
      final timelineFinder = find.byType(DAWTimeline);
      expect(timelineFinder, findsOneWidget);

      // Tap to add a marker
      await tester.tapAt(const Offset(100, 50));
      await tester.pumpAndSettle();

      // Verify marker was added by checking the CustomPaint
      expect(find.byType(CustomPaint), findsOneWidget);

      // Remove the marker by tapping it
      await tester.tapAt(const Offset(100, 50));
      await tester.pumpAndSettle();
    });

    /// Test the segment creation and playback workflow
    testWidgets('Can create and play segments', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add two markers to create a segment
      await tester.tapAt(const Offset(100, 50));
      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      // Find and tap play button
      final playButtonFinder = find.byIcon(Icons.play_arrow);
      expect(playButtonFinder, findsOneWidget);
      await tester.tap(playButtonFinder);
      await tester.pumpAndSettle();

      // Verify playback started
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });
} 