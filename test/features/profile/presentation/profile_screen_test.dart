import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/presentation/providers/profile_provider.dart';
import 'package:bite_front_end/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleProfile = UserProfileResponseModel(
    id: 'user_123',
    displayName: 'Alex Morgan',
    heightCm: 178.0,
    weightKg: 75.0,
    age: 28,
    gender: 'male',
    activityLevel: 'moderate',
    primaryGoal: 'muscle_gain',
    bmr: 1720.0,
    tdee: 2666.0,
    targetCalories: 2400.0,
    targetProteinG: 180.0,
    targetCarbsG: 250.0,
    targetFatG: 70.0,
    targetMicronutrients: {},
  );

  testWidgets('ProfileScreen renders user details, BMR/TDEE, and macros', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileNotifierProvider.overrideWith(
            () => FakeProfileNotifier(sampleProfile),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile & Goals'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('1720 kcal'), findsOneWidget);
    expect(find.text('2666 kcal'), findsOneWidget);
    expect(find.text('2400 kcal / day'), findsOneWidget);
    expect(find.text('180 g'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
    expect(find.text('70 g'), findsOneWidget);
    expect(find.text('Edit Physical Metrics & Goals'), findsOneWidget);
  });

  testWidgets('Tapping edit button opens bottom sheet modal', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileNotifierProvider.overrideWith(
            () => FakeProfileNotifier(sampleProfile),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final editButton = find.text('Edit Physical Metrics & Goals');
    expect(editButton, findsOneWidget);

    await tester.tap(editButton);
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile Metrics'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}

class FakeProfileNotifier extends ProfileNotifier {
  final UserProfileResponseModel mockProfile;

  FakeProfileNotifier(this.mockProfile);

  @override
  Future<UserProfileResponseModel> build() async {
    return mockProfile;
  }
}
