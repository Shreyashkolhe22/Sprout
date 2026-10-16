/// Stable storage key for a user name: case and surrounding spaces are
/// ignored, so "Sam" and " sam " share the same data.
String userStorageKey(String userName) =>
    Uri.encodeComponent(userName.trim().toLowerCase());
