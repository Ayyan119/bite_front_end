import 'dart:async';
import 'package:bite_front_end/features/profile/presentation/providers/profile_provider.dart';
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
      final response = await repository.login(email: email, password: password);
      ref.invalidate(profileNotifierProvider);
      return response;
    });
  }

  Future<void> register(RegisterRequestModel request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.register(request);
      ref.invalidate(profileNotifierProvider);
      return response;
    });
  }

  Future<void> devToken({required String email, String? userId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.devToken(email: email, userId: userId);
      ref.invalidate(profileNotifierProvider);
      return response;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    ref.invalidate(profileNotifierProvider);
    state = const AsyncValue.data(null);
  }

  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(state.valueOrNull);
    }
  }
}
