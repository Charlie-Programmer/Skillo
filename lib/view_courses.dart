import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class ViewCoursesPage extends StatefulWidget {
  const ViewCoursesPage({super.key});

  @override
  State<ViewCoursesPage> createState() => _ViewCoursesPageState();
}

class _ViewCoursesPageState extends State<ViewCoursesPage> {
  String searchText = "";

  /// SAFE RATING
  double getRating(Map course) {
    final rating = course["rating"];

    if (rating is int) return rating.toDouble();
    if (rating is double) return rating;
    if (rating is String) return double.tryParse(rating) ?? 0.0;

    return 0.0;
  }

  /// SAFE ENROLLED
  int getEnrolled(Map course) {
    final enrolled = course["enrolled"];

    if (enrolled is int) return enrolled;
    if (enrolled is double) return enrolled.toInt();
    if (enrolled is String) return int.tryParse(enrolled) ?? 0;

    return 0;
  }

  bool isSaved(Map course) {
    return course["isSaved"] == true;
  }

  Future<void> toggleSave(Box box, dynamic key) async {
    final course = box.get(key);

    if (course == null) return;

    final updated = Map<String, dynamic>.from(course);

    updated["isSaved"] = !(updated["isSaved"] == true);

    await box.put(key, updated);
  }

  @override
  Widget build(BuildContext context) {
    final coursesBox = Hive.box('coursesBox');

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [

                  /// BACK BUTTON
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),

                  const SizedBox(width: 5),

                  /// TITLE
                  const Text(
                    "Course Categories",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
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

              const SizedBox(height: 20),

              /// COURSES GRID
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: coursesBox.listenable(),

                  builder: (context, Box box, _) {

                    final coursesMap = box.toMap();

                    final keys = coursesMap.keys.toList();

                    final values = coursesMap.values.toList();

                    final publishedCourses = [];

                    for (int i = 0; i < values.length; i++) {

                      final course = Map<String, dynamic>.from(values[i]);

                      if (course["isPublished"] == true) {

                        final title =
                            (course["title"] ?? "").toString().toLowerCase();

                        if (title.contains(searchText)) {

                          publishedCourses.add({
                            "key": keys[i],
                            "course": course,
                          });
                        }
                      }
                    }

                    if (publishedCourses.isEmpty) {
                      return const Center(
                        child: Text(
                          "No courses available",
                        ),
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),

                      itemCount: publishedCourses.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),

                      itemBuilder: (context, index) {

                        final item = publishedCourses[index];

                        final key = item["key"];

                        final course =
                            Map<String, dynamic>.from(item["course"]);

                        final categoryType =
                            course["categoryType"] ??
                                course["category"] ??
                                "Uncategorized";

                        final rating = getRating(course);

                        final enrolled = getEnrolled(course);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(14),

                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              /// IMAGE
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),

                                child: SizedBox(
                                  height: 120,
                                  width: double.infinity,

                                  child: Stack(
                                    children: [

                                      (course["image"] != null &&
                                              course["image"]
                                                  .toString()
                                                  .isNotEmpty)

                                          ? Image.file(
                                              File(course["image"]),

                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )

                                          : const Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),

                                      Positioned(
                                        top: 5,
                                        right: 5,

                                        child: IconButton(
                                          icon: Icon(
                                            isSaved(course)
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,

                                            color: Color.fromARGB(255, 24, 105, 172),
                                          ),

                                          onPressed: () async {
                                            await toggleSave(box, key);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// DETAILS
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      course["title"] ?? "",

                                      maxLines: 1,

                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color.fromARGB(
                                            255, 24, 105, 172),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),

                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                                255, 24, 105, 172)
                                            .withOpacity(0.1),

                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        categoryType,

                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                              255, 24, 105, 172),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [

                                        Row(
                                          children: [

                                            const Icon(
                                              Icons.star,
                                              size: 14,
                                              color: Colors.orange,
                                            ),

                                            const SizedBox(width: 4),

                                            Text(
                                              rating.toStringAsFixed(1),

                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          children: [

                                            const Icon(
                                              Icons.people,
                                              size: 14,
                                              color: Colors.grey,
                                            ),

                                            const SizedBox(width: 4),

                                            Text(
                                              "$enrolled",

                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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