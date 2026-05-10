import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'user_store.dart';
import 'nav_bar.dart';
import 'course_certificate.dart';

class MyCertificatePage extends StatelessWidget {
  const MyCertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Back button
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

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "My Certificates",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 24, 105, 172),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    Hive.box('coursesBox').listenable(),
                    Hive.box('progressBox').listenable(),
                  ]),
                  builder: (context, _) {
                    final box = Hive.box('coursesBox');
                    final progressBox = Hive.box('progressBox');

                    return FutureBuilder(
                      future: UserStore.getCurrentUser(),
                      builder: (context, snapshot) {
                        final currentEmail =
                            snapshot.data?["email"] ?? "";
                        final fullName =
                            snapshot.data?["fullName"] ?? "Student";

                        final completedCourses = box.values.where((c) {
                          final enrolledUsers = (c as Map)["enrolledUsers"];
                          if (enrolledUsers is! List) return false;
                          if (!enrolledUsers
                              .map((e) => e.toString())
                              .contains(currentEmail)) return false;

                          final title = c["title"] ?? "";
                          final progressKey =
                              "${currentEmail}_${title}_completed";
                          final saved = progressBox.get(progressKey);
                          final completedCount =
                              (saved is List) ? saved.length : 0;

                          int totalLectures = 0;
                          final weeks = c["weeks"] ?? [];
                          for (final week in weeks) {
                            if (week is Map) {
                              final lectures = week["lectures"];
                              if (lectures is List)
                                totalLectures += lectures.length;
                            }
                          }

                          return totalLectures > 0 &&
                              completedCount >= totalLectures;
                        }).map((e) => Map<String, dynamic>.from(e)).toList();

                        if (completedCourses.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD6E4F0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.workspace_premium,
                                  size: 60,
                                  color: Color.fromARGB(255, 24, 105, 172),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "No Certificates Yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 24, 105, 172),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "You haven't earned any certificates yet.\nComplete courses to receive certificates.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainNavigation(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 24, 105, 172),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    "BROWSE COURSES",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          itemCount: completedCourses.length,
                          itemBuilder: (context, index) {
                            final course = completedCourses[index];
                            final title = course["title"] ?? "";
                            final image = course["image"] ?? "";
                            final category = course["categoryType"] ??
                                course["category"] ??
                                "Uncategorized";

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // IMAGE
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: image.isNotEmpty
                                          ? Image.file(
                                              File(image),
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image,
                                                  color: Colors.grey),
                                            ),
                                    ),

                                    const SizedBox(width: 12),

                                    // DETAILS
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 24, 105, 172),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Row(
                                            children: [
                                              Icon(Icons.check_circle,
                                                  size: 14,
                                                  color: Colors.green),
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
                                          const SizedBox(height: 8),

                                          // VIEW CERTIFICATE BUTTON
                                          SizedBox(
                                            width: double.infinity,
                                            height: 32,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CertificatePage(
                                                      studentName: fullName,
                                                      courseTitle: title,
                                                      category: category,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.workspace_premium,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                "View Certificate",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 24, 105, 172),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}