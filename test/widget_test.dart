import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bite_front_end/app.dart';

void main() {
  testWidgets('App renders welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BiteApp(),
      ),
    );

    expect(find.text('Welcome to Bite'), findsOneWidget);
  });
}
