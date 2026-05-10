import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_store.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Box? _messagesBox;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openBoxes() async {
    final box = await Hive.openBox('messagesBox');
    if (!mounted) return;
    setState(() {
      _messagesBox = box;
      _isLoading = false;
    });
  }

  int _unreadCount(String currentEmail, String otherEmail) {
    final sorted = [currentEmail, otherEmail]..sort();
    final key = sorted.join("__");
    final raw = _messagesBox?.get(key, defaultValue: []);
    if (raw is! List) return 0;
    return raw.where((msg) {
      final m = Map<String, dynamic>.from(msg);
      return m["senderEmail"] == otherEmail && m["read"] != true;
    }).length;
  }

  String _lastMessage(String currentEmail, String otherEmail) {
    final sorted = [currentEmail, otherEmail]..sort();
    final key = sorted.join("__");
    final raw = _messagesBox?.get(key, defaultValue: []);
    if (raw is! List || raw.isEmpty) return "";
    final last = Map<String, dynamic>.from(raw.last);
    return last["text"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header + Search ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Messages",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 24, 105, 172),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 105, 172),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 105, 172),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contact List ─────────────────────────────────────────
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box('coursesBox').listenable(),
                  builder: (context, Box coursesBox, _) {
                    return ValueListenableBuilder(
                      valueListenable: _messagesBox!.listenable(),
                      builder: (context, Box messagesBox, _) {
                        return FutureBuilder(
                          future: UserStore.getCurrentUser(),
                          builder: (context, snapshot) {
                            final currentUser = snapshot.data;
                            final currentEmail = currentUser?["email"] ?? "";

                            final allCourses = coursesBox.values
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList();

                            final ownedCourses = allCourses
                                .where((c) => c["ownerEmail"] == currentEmail)
                                .toList();

                            final isInstructor = ownedCourses.isNotEmpty;

                            // ============================================
                            // INSTRUCTOR VIEW
                            // ============================================
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

                              // Apply search filter
                              final filteredStudents = students.keys.where((email) {
                                final name = (students[email]?["name"] ?? "")
                                    .toString()
                                    .toLowerCase();
                                return name.contains(_searchText) ||
                                    email.toLowerCase().contains(_searchText);
                              }).toList();

                              if (students.isEmpty) {
                                return _emptyState("No students enrolled yet");
                              }

                              if (filteredStudents.isEmpty) {
                                return _emptyState("No results for \"$_searchText\"");
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final email = filteredStudents[index];
                                  final name = students[email]?["name"] ?? "User";
                                  final image = students[email]?["image"] ?? "";
                                  final courses = studentCourses[email] ?? [];
                                  final unread = _unreadCount(currentEmail, email);
                                  final lastMsg = _lastMessage(currentEmail, email);

                                  return _contactTile(
                                    context: context,
                                    email: email,
                                    name: name,
                                    image: image,
                                    subtitle: lastMsg.isNotEmpty
                                        ? lastMsg
                                        : "Enrolled in: ${courses.join(", ")}",
                                    unreadCount: unread,
                                  );
                                },
                              );
                            }

                            // ============================================
                            // STUDENT VIEW
                            // ============================================
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
                              final ownerEmail =
                                  course["ownerEmail"]?.toString() ?? "";
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

                            // Apply search filter
                            final filteredInstructors =
                                instructors.values.where((inst) {
                              final name = (inst["name"] ?? "")
                                  .toString()
                                  .toLowerCase();
                              final email = (inst["email"] ?? "")
                                  .toString()
                                  .toLowerCase();
                              return name.contains(_searchText) ||
                                  email.contains(_searchText);
                            }).toList();

                            if (instructors.isEmpty) {
                              return _emptyState("No instructors found");
                            }

                            if (filteredInstructors.isEmpty) {
                              return _emptyState(
                                  "No results for \"$_searchText\"");
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredInstructors.length,
                              itemBuilder: (context, index) {
                                final instructor = filteredInstructors[index];
                                final name = instructor["name"] ?? "Instructor";
                                final image = instructor["image"] ?? "";
                                final email = instructor["email"] ?? "";
                                final courses =
                                    List<String>.from(instructor["courses"]);
                                final unread = _unreadCount(currentEmail, email);
                                final lastMsg = _lastMessage(currentEmail, email);

                                return _contactTile(
                                  context: context,
                                  email: email,
                                  name: name,
                                  image: image,
                                  subtitle: lastMsg.isNotEmpty
                                      ? lastMsg
                                      : "Course: ${courses.join(", ")}",
                                  unreadCount: unread,
                                );
                              },
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
      ),
    );
  }

  Widget _contactTile({
    required BuildContext context,
    required String email,
    required String name,
    required String image,
    required String subtitle,
    required int unreadCount,
  }) {
    final hasUnread = unreadCount > 0;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                recipientEmail: email,
                recipientName: name,
                recipientImage: image,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 24, 105, 172),
          backgroundImage: image.isNotEmpty ? FileImage(File(image)) : null,
          child: image.isEmpty
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
            color: const Color.fromARGB(255, 24, 105, 172),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: hasUnread ? Colors.black87 : Colors.grey,
            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: hasUnread
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 24, 105, 172),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),
                child: Text(
                  unreadCount > 99 ? "99+" : "$unreadCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : const Icon(Icons.circle, size: 10, color: Colors.green),
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