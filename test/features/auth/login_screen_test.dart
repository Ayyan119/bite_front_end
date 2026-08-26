import 'package:bite_front_end/features/auth/data/models/auth_response_model.dart';
import 'package:bite_front_end/features/auth/data/repositories/auth_repository.dart';
import 'package:bite_front_end/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResponseModel?> restoreSession() async => null;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    return const AuthResponseModel(
      accessToken: 'token',
      tokenType: 'bearer',
      expiresIn: 86400,
      userId: '1',
      email: 'test@example.com',
    );
  }

  @override
  Future<AuthResponseModel> register(dynamic request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponseModel> devToken({
    required String email,
    String? userId,
  }) async {
    return const AuthResponseModel(
      accessToken: 'dev_token',
      tokenType: 'bearer',
      expiresIn: 86400,
      userId: '1',
      email: 'dev@example.com',
    );
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('LoginScreen renders form fields and buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('WELCOME BACK'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
