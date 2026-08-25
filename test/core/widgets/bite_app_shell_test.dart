import 'package:bite_front_end/core/widgets/bite_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BiteAppShell renders mobile bottom navigation bar and tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int selectedIndex = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return BiteAppShell(
                selectedIndex: selectedIndex,
                onTabSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: const [
                  Text('Dashboard Screen'),
                  Text('Meals Screen'),
                  Text('Chat Screen'),
                  Text('Profile Screen'),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Dashboard Screen'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Meals'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile Screen'), findsOneWidget);
  });

  testWidgets('BiteAppShell renders NavigationRail on wide desktop viewports', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int selectedIndex = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return BiteAppShell(
                selectedIndex: selectedIndex,
                onTabSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: const [
                  Text('Dashboard Screen'),
                  Text('Meals Screen'),
                  Text('Chat Screen'),
                  Text('Profile Screen'),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Dashboard Screen'), findsOneWidget);
  });
}
