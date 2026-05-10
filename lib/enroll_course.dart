import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'payment_method.dart';
import 'user_store.dart';
import 'course_enrolled.dart';

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

  Future<void> checkEnrollment() async {
  final currentUser = await UserStore.getCurrentUser();
  final currentEmail = currentUser?["email"];

  final enrolledList = widget.course["enrolledUsers"];

  if (enrolledList is List) {
    setState(() {
      isEnrolled = enrolledList
          .map((e) => e.toString())
          .contains(currentEmail);
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

  final currentUser = await UserStore.getCurrentUser();
  final currentEmail = currentUser?["email"];

List enrolledUsers =
    List.from(
      course["enrolledUsers"] ?? [],
    );

if (!enrolledUsers.contains(currentEmail)) {
  enrolledUsers.add(currentEmail);
}

course["enrolledUsers"] = enrolledUsers;

    await box.put(key, course);

    // ✅ ADD THIS
    final notifBox = Hive.box('notificationsBox');
    await notifBox.add({
      "user": currentEmail,
      "title": "Enrollment Successful!",
      "subtitle": "You have successfully enrolled in ${widget.course["title"]}.",
    });
    // ✅ END

    setState(() {
      isEnrolled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully Enrolled!")),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Color.fromARGB(255, 24, 105, 172)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    final enrolledUsers =
    List.from(
      course["enrolledUsers"] ?? [],
    );

    final enrolledCount = enrolledUsers.length;
    
    final price = course["price"] ?? "0";

    final List weeksList = course["weeks"] ?? [];

    // total weeks = list length
    final int weeksCount = weeksList.length;

    // total lectures = sum of all lectures in all weeks
    int lecturesCount = 0;

    for (final week in weeksList) {
      if (week is Map) {
        final lectures = week["lectures"];

        if (lectures is List) {
          lecturesCount += lectures.length;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 10),

                    /// BACK BUTTON (MATCHED STYLE)
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

            /// COURSE IMAGE (UNCHANGED)
            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: course["image"] != null &&
                      course["image"].toString().isNotEmpty
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
            ),

            const SizedBox(height: 15),

            /// TITLE + PRICE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course["title"] ?? "",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 24, 105, 172),
                      ),
                    ),
                  ),
                  Text(
                    "₱$price",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            /// ENROLLED USERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Color.fromARGB(255, 24, 105, 172)),
                  const SizedBox(width: 5),
                  Text(
                    "$enrolledCount students already enrolled",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// COURSE DETAILS HEADER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Course Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 24, 105, 172),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                course["description"] ?? "No description available.",
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Read More...",
                  style: TextStyle(
                    color: Color.fromARGB(255, 24, 105, 172),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ICON DETAILS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _detailRow(Icons.menu_book, "Lectures", "$lecturesCount Lectures"),
                  const SizedBox(height: 12),
                 _detailRow(Icons.schedule, "Learning Time", "$weeksCount Weeks"),
                  const SizedBox(height: 12),
                  _detailRow(Icons.verified, "Certification", "Online Certificate"),
                ],
              ),
            ),

            /// ENROLL BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isEnrolled
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodPage(
                              course: widget.course,
                            ),
                          ),
                        );

                        // If payment succeeds, then enroll
                       if (result == true) {
                          await enrollCourse();

                          if (!mounted) return;

                          final box = Hive.box('coursesBox');

                          final coursesMap = box.toMap();

                          final key = coursesMap.keys.firstWhere(
                            (k) => box.get(k)["title"] == widget.course["title"],
                          );

                          final updatedCourse =
                              Map<String, dynamic>.from(box.get(key));

                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
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
      ),
    ),
    );
  }
}