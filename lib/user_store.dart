import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStore {
  static List<Map<String, String>> users = [];

  static String? currentUserEmail;

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }


  static Future<void> loadUsers() async {
    final file = await _getFile();

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode([]));
      users = [];
      return;
    }

    final content = await file.readAsString();

    if (content.isEmpty) {
      users = [];
      return;
    }

    final List decoded = jsonDecode(content);

    users = decoded.map<Map<String, String>>((item) {
      return {
        "email": item["email"] ?? "",
        "password": item["password"] ?? "",
        "fullName": item["fullName"] ?? "",
        "hasSeenOnboarding": item["hasSeenOnboarding"] ?? "false",
        "profileImage": item["profileImage"] ?? "",
        "role": item["role"] ?? "Student",
      };
    }).toList();
  }

  // =========================
  // SAVE USERS
  // =========================
  static Future<void> _saveUsers() async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(users));
  }

  // =========================
  // ADD USER
  // =========================
  static Future<void> addUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await loadUsers();

    users.add({
      "email": email.trim(),
      "password": password,
      "fullName": fullName.trim(),
      "hasSeenOnboarding": "false",
      "profileImage": "",
      "role": "Student",
    });

    await _saveUsers();
  }

  // =========================
  // LOGIN
  // =========================
  static Future<bool> loginUser({
    required String email,
    required String password,
}) async {
  await loadUsers();

  for (var user in users) {
    if (user["email"] == email.trim() &&
        user["password"] == password) {

      // 👇 ADD THIS LINE
      currentUserEmail = email.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("currentUserEmail", currentUserEmail!);

      return true;
    }
  }

  return false;
}
  // =========================
  // UPDATE PASSWORD
  // =========================
  static Future<bool> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] == email.trim()) {
        user["password"] = newPassword;
        await _saveUsers();
        return true;
      }
    }

    return false;
  }

  // =========================
  // GET USER
  // =========================
  static Future<Map<String, String>?> getUser(String email) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] == email.trim()) {
        return user;
      }
    }

    return null;
  }

  // =========================
  // CLEAR USERS
  // =========================
  static Future<void> clearUsers() async {
    users.clear();
    await _saveUsers();
  }
  
  
    static Future<Map<String, String>?> getCurrentUser() async {
    if (currentUserEmail == null) return null;

    return await getUser(currentUserEmail!);
  }

    static Future<void> setOnboardingSeen(String email) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] == email.trim()) {
        user["hasSeenOnboarding"] = "true";
        break;
      }
    }

    await _saveUsers();
  }

  static Future<void> updateProfileImage({
  required String email,
  required String imagePath,
}) async {
  await loadUsers();

  for (var user in users) {
    if (user["email"] == email.trim()) {
      user["profileImage"] = imagePath;
      break;
    }
  }

  await _saveUsers();
}

 //user role update
  static Future<void> updateUserRole({
    required String email,
    required String role,
  }) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] == email.trim()) {
        user["role"] = role;
        break;
      }
    }

    await _saveUsers();
  }

  static Future<void> clearCurrentUser() async {
  currentUserEmail = null;

  // If you're using SharedPreferences:
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("currentUserEmail");
}

  static Future<void> restoreSession() async {
  final prefs = await SharedPreferences.getInstance();
  currentUserEmail = prefs.getString("currentUserEmail");
}

}

