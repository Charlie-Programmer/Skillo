import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
}

