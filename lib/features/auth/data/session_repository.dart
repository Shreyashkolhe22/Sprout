import 'package:shared_preferences/shared_preferences.dart';

/// Remembers who is signed in on this device.
///
/// There is no server account: "signing in" just means telling the app what to
/// call you and which local habit list to open.
abstract interface class SessionRepository {
  /// The signed-in user's name, or null when logged out.
  String? get userName;

  Future<void> signIn(String userName);

  Future<void> signOut();
}

class PrefsSessionRepository implements SessionRepository {
  PrefsSessionRepository(this._prefs);

  static const _key = 'session_user_name';

  final SharedPreferences _prefs;

  @override
  String? get userName {
    final name = _prefs.getString(_key)?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  @override
  Future<void> signIn(String userName) => _prefs.setString(_key, userName.trim());

  @override
  Future<void> signOut() => _prefs.remove(_key);
}

/// Session that lives only as long as the app. Used by tests.
class InMemorySessionRepository implements SessionRepository {
  InMemorySessionRepository({this._userName});

  String? _userName;

  @override
  String? get userName => _userName;

  @override
  Future<void> signIn(String userName) async => _userName = userName.trim();

  @override
  Future<void> signOut() async => _userName = null;
}
