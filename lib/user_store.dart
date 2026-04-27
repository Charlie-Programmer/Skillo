class UserStore {

  static final List<Map<String, String>> users = [];

  // Add new user
  static void addUser({
    required String email,
    required String password,
    required String fullName,
  }) {
    users.add({
      "email": email.trim(),
      "password": password,
      "fullName": fullName.trim(),
    });
  }

  // Update user password
static bool updatePassword({
  required String email,
  required String newPassword,
}) {
  for (var user in users) {
    if (user["email"] == email.trim()) {
      user["password"] = newPassword;
      return true;
    }
  }
  return false;
}

  // Check login credentials
  static bool loginUser({
    required String email,
    required String password,
  }) {
    return users.any((user) =>
        user["email"] == email.trim() &&
        user["password"] == password);
  }

  // Optional: get user info after login
  static Map<String, String>? getUser(String email) {
    try {
      return users.firstWhere((user) => user["email"] == email.trim());
    } catch (e) {
      return null;
    }
  }

  // Optional: clear all users (for testing)
  static void clearUsers() {
    users.clear();
  }
}