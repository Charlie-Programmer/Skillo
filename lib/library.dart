import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'user_store.dart';
import 'course_analytics.dart';
import 'enroll_course.dart';
import 'course_enrolled.dart';

class LibraryScreen extends StatefulWidget {
  final int initialTab;

  const LibraryScreen({super.key, this.initialTab = 0});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late int selectedTab;

  final tabs = ["Saved Courses", "In Progress", "Completed"];

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
  }

  Widget _savedCoursesTab() {
    final box = Hive.box('coursesBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        final entries = box.toMap().entries.toList();

        final savedCourses = entries
            .where((entry) => entry.value["isSaved"] == true)
            .toList();

        if (savedCourses.isEmpty) {
          return const Center(
            child: Text(
              "No saved courses yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: savedCourses.length,
          itemBuilder: (context, index) {
            final entry = savedCourses[index];
            final key = entry.key;
            final course = Map.from(entry.value);

            return InkWell(
              onTap: () {
                final currentEmail = UserStore.currentUserEmail;
                final courseOwner = course["ownerEmail"];

                if (courseOwner == currentEmail) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourseAnalyticsPage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnrollCoursePage(course: course),
                    ),
                  );
                }
              },
              child: Card(
                color: const Color.fromARGB(255, 255, 255, 255),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: course["image"] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(course["image"]),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image),
                  title: Text(
                    course["title"] ?? "No Title",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 24, 105, 172),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    (course["categoryType"] ??
                            course["category"] ??
                            "Uncategorized")
                        .toString(),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      final updatedCourse = Map.from(course);
                      updatedCourse["isSaved"] = false;
                      box.put(key, updatedCourse);
                    },
                    child: const Icon(
                      Icons.bookmark,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _inProgressTab() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        Hive.box('coursesBox').listenable(),
        Hive.box('progressBox').listenable(),
      ]),
      builder: (context, _) {
        final box = Hive.box('coursesBox');
        final progressBox = Hive.box('progressBox');
        final currentEmail = UserStore.currentUserEmail;

        final enrolledCourses = box.values.where((c) {
          final enrolledUsers = (c as Map)["enrolledUsers"];
          if (enrolledUsers is! List) return false;
          if (!enrolledUsers.map((e) => e.toString()).contains(currentEmail)) return false;

          // exclude fully completed courses
          final title = (c as Map)["title"] ?? "";
          final progressKey = "${currentEmail}_${title}_completed";
          final saved = progressBox.get(progressKey);
          final completedCount = (saved is List) ? saved.length : 0;

          int totalLectures = 0;
          final weeks = c["weeks"] ?? [];
          for (final week in weeks) {
            if (week is Map) {
              final lectures = week["lectures"];
              if (lectures is List) totalLectures += lectures.length;
            }
          }

          return totalLectures == 0 || completedCount < totalLectures;
        }).map((e) => Map<String, dynamic>.from(e)).toList();

        if (enrolledCourses.isEmpty) {
          return const Center(
            child: Text(
              "No courses in progress",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: enrolledCourses.length,
          itemBuilder: (context, index) {
            final course = enrolledCourses[index];
            final title = course["title"] ?? "";
            final image = course["image"] ?? "";

            final progressKey = "${currentEmail}_${title}_completed";
            final saved = progressBox.get(progressKey);
            final completedCount = (saved is List) ? saved.length : 0;

            int totalLectures = 0;
            final weeks = course["weeks"] ?? [];
            for (final week in weeks) {
              if (week is Map) {
                final lectures = week["lectures"];
                if (lectures is List) totalLectures += lectures.length;
              }
            }

            final progress = totalLectures > 0
                ? completedCount / totalLectures
                : 0.0;

            final coursesMap = box.toMap();
            final key = coursesMap.keys.firstWhere(
              (k) => box.get(k)["title"] == title,
            );

            return InkWell(
              onTap: () {
                final freshCourse =
                    Map<String, dynamic>.from(box.get(key) ?? course);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnrolledCoursePage(course: freshCourse),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image.isNotEmpty
                            ? Image.file(
                                File(image),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image,
                                    color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color.fromARGB(255, 24, 105, 172),
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color.fromARGB(255, 24, 105, 172),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$completedCount / $totalLectures lectures completed",
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _completedTab() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        Hive.box('coursesBox').listenable(),
        Hive.box('progressBox').listenable(),
      ]),
      builder: (context, _) {
        final box = Hive.box('coursesBox');
        final progressBox = Hive.box('progressBox');
        final currentEmail = UserStore.currentUserEmail;

        final completedCourses = box.values.where((c) {
          final enrolledUsers = (c as Map)["enrolledUsers"];
          if (enrolledUsers is! List) return false;
          if (!enrolledUsers.map((e) => e.toString()).contains(currentEmail)) return false;

          final title = (c as Map)["title"] ?? "";
          final progressKey = "${currentEmail}_${title}_completed";
          final saved = progressBox.get(progressKey);
          final completedCount = (saved is List) ? saved.length : 0;

          int totalLectures = 0;
          final weeks = c["weeks"] ?? [];
          for (final week in weeks) {
            if (week is Map) {
              final lectures = week["lectures"];
              if (lectures is List) totalLectures += lectures.length;
            }
          }

          return totalLectures > 0 && completedCount >= totalLectures;
        }).map((e) => Map<String, dynamic>.from(e)).toList();

        if (completedCourses.isEmpty) {
          return const Center(
            child: Text(
              "No completed courses yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: completedCourses.length,
          itemBuilder: (context, index) {
            final course = completedCourses[index];
            final title = course["title"] ?? "";
            final image = course["image"] ?? "";

            final coursesMap = box.toMap();
            final key = coursesMap.keys.firstWhere(
              (k) => box.get(k)["title"] == title,
            );

            return InkWell(
              onTap: () {
                final freshCourse =
                    Map<String, dynamic>.from(box.get(key) ?? course);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnrolledCoursePage(course: freshCourse),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image.isNotEmpty
                            ? Image.file(
                                File(image),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image,
                                    color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color.fromARGB(255, 24, 105, 172),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 16, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  "Completed",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// TABS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTab == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(255, 24, 105, 172)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 24, 105, 172),
                            ),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              /// TAB CONTENT
              Expanded(
                child: IndexedStack(
                  index: selectedTab,
                  children: [
                    _savedCoursesTab(),
                    _inProgressTab(),
                    _completedTab(),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}