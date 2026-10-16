import 'package:flutter_application_1/features/auth/data/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('is logged out by default', () async {
    SharedPreferences.setMockInitialValues({});
    final session = PrefsSessionRepository(await SharedPreferences.getInstance());
    expect(session.userName, isNull);
  });

  test('signIn is remembered across instances and signOut clears it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await PrefsSessionRepository(prefs).signIn('  Sam ');
    expect(PrefsSessionRepository(prefs).userName, 'Sam');

    await PrefsSessionRepository(prefs).signOut();
    expect(PrefsSessionRepository(prefs).userName, isNull);
  });
}
