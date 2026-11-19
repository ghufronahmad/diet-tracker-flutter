import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracker_app/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(const DietTrackerApp());
    expect(find.textContaining('Personal Diet & Workout Tracker'), findsOneWidget);
  });
}
