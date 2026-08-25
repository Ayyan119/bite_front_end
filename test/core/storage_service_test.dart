import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
  });

  test('saveToken and getToken persist access token', () async {
    expect(storageService.getToken(), isNull);

    final saved = await storageService.saveToken('test_jwt_token_123');
    expect(saved, isTrue);
    expect(storageService.getToken(), equals('test_jwt_token_123'));
  });

  test('clearToken removes saved access token', () async {
    await storageService.saveToken('test_jwt_token_123');
    expect(storageService.getToken(), equals('test_jwt_token_123'));

    await storageService.clearToken();
    expect(storageService.getToken(), isNull);
  });

  test('saveUserData and getUserData persist user details', () async {
    await storageService.saveUserData(
      userId: 'uuid-1234',
      email: 'alex@bite.app',
      displayName: 'Alex Morgan',
    );

    final userData = storageService.getUserData();
    expect(userData['userId'], equals('uuid-1234'));
    expect(userData['email'], equals('alex@bite.app'));
    expect(userData['displayName'], equals('Alex Morgan'));
  });

  test('clearAll wipes all saved preferences', () async {
    await storageService.saveToken('test_jwt_token_123');
    await storageService.saveUserData(
      userId: 'uuid-1234',
      email: 'alex@bite.app',
    );

    await storageService.clearAll();
    expect(storageService.getToken(), isNull);
    expect(storageService.getUserData()['userId'], isNull);
  });
}
