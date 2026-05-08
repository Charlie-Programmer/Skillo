import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStore {
  static List<Map<String, dynamic>> users = [];

  static String? currentUserEmail;

  // =========================
  // GET FILE
  // =========================
  static Future<File> _getFile() async {
    final dir =
        await getApplicationDocumentsDirectory();

    return File('${dir.path}/users.json');
  }

  // =========================
  // LOAD USERS
  // =========================
  static Future<void> loadUsers() async {
    final file = await _getFile();

    if (!await file.exists()) {
      await file.create(recursive: true);

      await file.writeAsString(
        jsonEncode([]),
      );

      users = [];

      return;
    }

    final content =
        await file.readAsString();

    if (content.isEmpty) {
      users = [];
      return;
    }

    final List decoded =
        jsonDecode(content);

    users =
        decoded
            .map<Map<String, dynamic>>(
              (item) => Map<String,
                  dynamic>.from(item),
            )
            .toList();
  }

  // =========================
  // SAVE USERS
  // =========================
  static Future<void> _saveUsers() async {
    final file = await _getFile();

    await file.writeAsString(
      jsonEncode(users),
    );
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
      "categories": <String>[],
    });

    await _saveUsers();
  }

  // =========================
  // LOGIN USER
  // =========================
  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] ==
              email.trim() &&
          user["password"] ==
              password) {
        currentUserEmail =
            email.trim();

        final prefs =
            await SharedPreferences.getInstance();

        await prefs.setString(
          "currentUserEmail",
          currentUserEmail!,
        );

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
      if (user["email"] ==
          email.trim()) {
        user["password"] =
            newPassword;

        await _saveUsers();

        return true;
      }
    }

    return false;
  }

  // =========================
  // GET USER
  // =========================
  static Future<
      Map<String, dynamic>?> getUser(
    String email,
  ) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] ==
          email.trim()) {
        return user;
      }
    }

    return null;
  }

  // =========================
  // GET CURRENT USER
  // =========================
  static Future<
      Map<String, dynamic>?>
  getCurrentUser() async {
    if (currentUserEmail == null) {
      return null;
    }

    return await getUser(
      currentUserEmail!,
    );
  }

  // =========================
  // UPDATE CURRENT USER
  // =========================
  static Future<void>
  updateCurrentUser(
    Map<String, dynamic> updatedUser,
  ) async {
    await loadUsers();

    if (currentUserEmail == null) {
      return;
    }

    final index = users.indexWhere(
      (u) =>
          u["email"] ==
          currentUserEmail,
    );

    if (index != -1) {
      users[index] = updatedUser;

      currentUserEmail =
          updatedUser["email"];

      final prefs =
          await SharedPreferences.getInstance();

      if (currentUserEmail != null) {
        await prefs.setString(
          "currentUserEmail",
          currentUserEmail!,
        );
      }

      await _saveUsers();
    }
  }

  // =========================
  // SET ONBOARDING
  // =========================
  static Future<void>
  setOnboardingSeen(
    String email,
  ) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] ==
          email.trim()) {
        user["hasSeenOnboarding"] =
            "true";

        break;
      }
    }

    await _saveUsers();
  }

  // =========================
  // UPDATE PROFILE IMAGE
  // =========================
  static Future<void>
  updateProfileImage({
    required String email,
    required String imagePath,
  }) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] ==
          email.trim()) {
        user["profileImage"] =
            imagePath;

        break;
      }
    }

    await _saveUsers();
  }

  // =========================
  // UPDATE USER ROLE
  // =========================
  static Future<void>
  updateUserRole({
    required String email,
    required String role,
  }) async {
    await loadUsers();

    for (var user in users) {
      if (user["email"] ==
          email.trim()) {
        user["role"] = role;

        break;
      }
    }

    await _saveUsers();
  }

  // =========================
  // CLEAR USERS
  // =========================
  static Future<void> clearUsers() async {
    users.clear();

    await _saveUsers();
  }

  // =========================
  // CLEAR CURRENT USER
  // =========================
  static Future<void>
  clearCurrentUser() async {
    currentUserEmail = null;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      "currentUserEmail",
    );
  }

  // =========================
  // RESTORE SESSION
  // =========================
  static Future<void>
  restoreSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    currentUserEmail = prefs.getString(
      "currentUserEmail",
    );
  }
}