import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class EnrollCoursePage extends StatefulWidget {
  final Map course;

  const EnrollCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EnrollCoursePage> createState() => _EnrollCoursePageState();
}

class _EnrollCoursePageState extends State<EnrollCoursePage> {
  bool isEnrolled = false;

  @override
  void initState() {
    super.initState();
    checkEnrollment();
  }

  void checkEnrollment() {
    final enrolledList = widget.course["enrolledUsers"];

    if (enrolledList is List) {
      setState(() {
        isEnrolled = enrolledList.contains("me"); // replace with user id/email later
      });
    }
  }

  Future<void> enrollCourse() async {
    final box = Hive.box('coursesBox');

    final coursesMap = box.toMap();

    final key = coursesMap.keys.firstWhere(
      (k) => box.get(k)["title"] == widget.course["title"],
    );

    final course = Map<String, dynamic>.from(widget.course);

    List enrolledUsers = course["enrolledUsers"] ?? [];

    if (!enrolledUsers.contains("me")) {
      enrolledUsers.add("me"); // replace with current user email later
    }

    course["enrolledUsers"] = enrolledUsers;

    int enrolledCount = course["enrolled"] ?? 0;
    course["enrolled"] = enrolledCount + 1;

    await box.put(key, course);

    setState(() {
      isEnrolled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully Enrolled!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            /// BACK BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            /// COURSE IMAGE
            course["image"] != null && course["image"].toString().isNotEmpty
                ? Image.file(
                    File(course["image"]),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 60),
                  ),

            const SizedBox(height: 20),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                course["title"] ?? "",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// CATEGORY
            Text(
              "Category: ${course["categoryType"] ?? course["category"] ?? ""}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION (if available)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                course["description"] ?? "No description available.",
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            /// ENROLL BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isEnrolled ? null : enrollCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnrolled
                        ? Colors.grey
                        : const Color.fromARGB(255, 24, 105, 172),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEnrolled ? "Already Enrolled" : "Enroll Now",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}