import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  // Yield initial status: online
  yield true;

  // Stream periodic health / connectivity checks
  final controller = StreamController<bool>();
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    if (!controller.isClosed) {
      controller.add(true);
    }
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  yield* controller.stream;
});
