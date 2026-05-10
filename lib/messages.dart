import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_store.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                "Messages",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('coursesBox').listenable(),
                builder: (context, Box box, _) {
                  return FutureBuilder(
                    future: UserStore.getCurrentUser(),
                    builder: (context, snapshot) {
                      final currentUser = snapshot.data;
                      final currentEmail = currentUser?["email"] ?? "";

                      final allCourses = box.values
                          .map((e) => Map<String, dynamic>.from(e))
                          .toList();

                      final ownedCourses = allCourses
                          .where((c) => c["ownerEmail"] == currentEmail)
                          .toList();

                      final isInstructor = ownedCourses.isNotEmpty;

                      // =========================
                      // INSTRUCTOR VIEW
                      // =========================
                      if (isInstructor) {
                        final Map<String, Map<String, dynamic>> students = {};
                        final Map<String, List<String>> studentCourses = {};

                        for (final course in ownedCourses) {
                          final enrolledUsers = course["enrolledUsers"];

                          if (enrolledUsers is List) {
                            for (final email in enrolledUsers) {
                              final emailStr = email.toString();

                              final user = UserStore.users.firstWhere(
                                (u) => u["email"] == emailStr,
                                orElse: () => {},
                              );

                              students[emailStr] = {
                                "name": user["fullName"] ??
                                    emailStr.split("@")[0],
                                "image": user["profileImage"] ?? "",
                              };

                              studentCourses[emailStr] ??= [];
                              studentCourses[emailStr]!
                                  .add(course["title"] ?? "");
                            }
                          }
                        }

                        if (students.isEmpty) {
                          return _emptyState("No students enrolled yet");
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final email = students.keys.elementAt(index);
                            final name = students[email]?["name"] ?? "User";
                            final image = students[email]?["image"] ?? "";
                            final courses = studentCourses[email] ?? [];

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(255, 24, 105, 172),
                                  backgroundImage: image.isNotEmpty
                                      ? FileImage(File(image))
                                      : null,
                                  child: image.isEmpty
                                      ? Text(
                                          name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 105, 172),
                                  ),
                                ),
                                subtitle: Text(
                                  "Enrolled in: ${courses.join(", ")}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.green,
                                ),
                              ),
                            );
                          },
                        );
                      }

                      // =========================
                      // STUDENT VIEW
                      // =========================
                      final enrolledCourses = allCourses.where((c) {
                        final enrolledUsers = c["enrolledUsers"];
                        if (enrolledUsers is! List) return false;

                        return enrolledUsers
                            .map((e) => e.toString())
                            .contains(currentEmail);
                      }).toList();

                      if (enrolledCourses.isEmpty) {
                        return _emptyState(
                          "Enroll in a course to message your instructor",
                        );
                      }

                      final Map<String, Map<String, dynamic>> instructors = {};

                      for (final course in enrolledCourses) {
                        final ownerEmail = course["ownerEmail"]?.toString() ?? "";

                        if (ownerEmail.isNotEmpty) {
                          final user = UserStore.users.firstWhere(
                            (u) => u["email"] == ownerEmail,
                            orElse: () => {},
                          );

                          final name =
                              user["fullName"] ?? ownerEmail.split("@")[0];
                          final image = user["profileImage"] ?? "";

                          instructors[ownerEmail] ??= {
                            "email": ownerEmail,
                            "name": name,
                            "image": image,
                            "courses": [],
                          };

                          (instructors[ownerEmail]!["courses"] as List)
                              .add(course["title"] ?? "");
                        }
                      }

                      if (instructors.isEmpty) {
                        return _emptyState("No instructors found");
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: instructors.length,
                        itemBuilder: (context, index) {
                          final instructor =
                              instructors.values.elementAt(index);

                          final name = instructor["name"] ?? "Instructor";
                          final image = instructor["image"] ?? "";
                          final courses =
                              List<String>.from(instructor["courses"]);

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 24, 105, 172),
                                backgroundImage: image.isNotEmpty
                                    ? FileImage(File(image))
                                    : null,
                                child: image.isEmpty
                                    ? Text(
                                        name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 24, 105, 172),
                                ),
                              ),
                              subtitle: Text(
                                "Course: ${courses.join(", ")}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Color.fromARGB(255, 24, 105, 172),
            ),
            const SizedBox(height: 16),
            const Text(
              "No messages yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 94, 92, 92),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 94, 92, 92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}