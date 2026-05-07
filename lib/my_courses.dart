import 'package:flutter/material.dart';
import 'create_course.dart';
import 'edit_course.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'user_store.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  List courses = [];

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  void loadCourses() {
    final box = Hive.box('coursesBox');
    final email = UserStore.currentUserEmail;

    if (email == null) {
      setState(() {
        courses = [];
      });
      return;
    }

    final allCourses = box.values.toList();

    setState(() {
      courses = allCourses.where((course) {
        return course["email"] == email;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ADD COURSE BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 24, 105, 172),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCoursePage(),
            ),
          );

          loadCourses();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 24, 105, 172),
                  ),
                ),
              ),

              const Text(
                "My Courses",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: courses.isEmpty
                    ? SizedBox.expand(
                        child: Center(
                          child: _buildEmptyState(context),
                        ),
                      )
                    : _buildCourseList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFFD6E4F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              size: 60,
              color: Color.fromARGB(255, 24, 105, 172),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "No Courses Created",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 24, 105, 172),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "You haven’t created any courses yet.\nStart sharing your knowledge by creating one.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCoursePage(),
                  ),
                );

                loadCourses();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 105, 172),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "CREATE COURSE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COURSE LIST
  Widget _buildCourseList() {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];

        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditCoursePage(course: course),
              ),
            );

            loadCourses();
          },

          child: Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // IMAGE
                  course["image"] != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(course["image"]),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image),
                        ),

                  const SizedBox(width: 12),

                  // TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // TITLE
                        Text(
                          course["title"] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 24, 105, 172),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // DESCRIPTION
                        Text(
                          course["description"] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // STATS
                        Text(
                          "⭐ ${course["rating"] ?? 0}   👨‍🎓 ${course["enrolled"] ?? 0} students",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
  }
}