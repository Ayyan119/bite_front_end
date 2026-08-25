import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/repositories/auth_repository.dart';

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthResponseModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthResponseModel?> {
  @override
  FutureOr<AuthResponseModel?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.restoreSession();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.login(email: email, password: password);
    });
  }

  Future<void> register(RegisterRequestModel request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.register(request);
    });
  }

  Future<void> devToken({required String email, String? userId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.devToken(email: email, userId: userId);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}
