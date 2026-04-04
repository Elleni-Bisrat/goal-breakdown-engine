import 'package:flutter_test/flutter_test.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';

void main() {
  testWidgets('App renders splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const AppRoot());
    expect(find.text('ATOMIZE'), findsOneWidget);
  });
}
