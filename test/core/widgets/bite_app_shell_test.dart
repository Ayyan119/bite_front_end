import 'package:bite_front_end/core/widgets/bite_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'BiteAppShell renders mobile floating navigation bar and active tab',
    (tester) async {
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

      // Tap Profile icon (index 3)
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Profile Screen'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    },
  );

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
