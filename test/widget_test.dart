import 'package:flutter_test/flutter_test.dart';
import 'package:palestine_election_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Election tracker app renders', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ElectionTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('PLC Election Tracker'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
