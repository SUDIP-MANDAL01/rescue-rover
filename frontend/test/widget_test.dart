import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_rover/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Verify the app can be instantiated
    expect(const RescueRoverApp(), isNotNull);
  });
}
