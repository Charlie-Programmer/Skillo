import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'user_store.dart';
import 'course_analytics.dart';
import 'enroll_course.dart';

class LibraryScreen extends StatefulWidget {
  final int initialTab;

  const LibraryScreen({super.key, this.initialTab = 0});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late int selectedTab;

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

  final tabs = ["Saved Courses", "In Progress", "Completed"];

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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

              /// TABS (SAFE SCROLLABLE)
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

              /// TAB CONTENT (FIXED WITH EXPANDED)
              Expanded(
                child: IndexedStack(
                  index: selectedTab,
                  children: [
                    _savedCoursesTab(),
                    _tabContent("In Progress"),
                    _tabContent("Completed"),
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


  Widget _tabContent(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}