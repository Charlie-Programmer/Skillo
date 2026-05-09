import 'package:flutter/material.dart';
import 'user_store.dart';
import 'course_categories.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'view_courses.dart';
import 'view_suggestions.dart';
import 'notification.dart';
import 'view_course_analytics.dart';
import 'enroll_course.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String? currentUserEmail;

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "Guest";
  List<String> selectedCategories = [];

  final TextEditingController _searchController = TextEditingController();
  String searchText = "";

  Key _animationKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

bool isSaved(Map course) {
  return course["isSaved"] == true;
}

Future<void> toggleSave(Box box, dynamic key) async {
  final course = box.get(key);

  if (course == null) return;

  final updated = Map<String, dynamic>.from(course);
  final current = updated["isSaved"] == true;

  updated["isSaved"] = !current;

  await box.put(key, updated);
}

  /// ✅ FIXED: now always loads user-selected categories
  void loadUser() async {
    final user = await UserStore.getCurrentUser();

    setState(() {
      fullName = user?["fullName"] ?? "Guest";
      currentUserEmail = user?["email"];
      selectedCategories = List<String>.from(user?["categories"] ?? []);
    });

    if (!mounted) return;

    setState(() {
      fullName = user?["fullName"] ?? "Guest";
      selectedCategories =
          List<String>.from(user?["categories"] ?? []);
    });
  }

  Future<void> updateUserCategories() async {
    final user = await UserStore.getCurrentUser();

    if (user != null) {
      user["categories"] = selectedCategories;
      await UserStore.updateCurrentUser(user);
    }
  }

  /// ✅ SAFE RATING
  double getRating(Map course) {
    final rating = course["rating"];
    if (rating is int) return rating.toDouble();
    if (rating is double) return rating;
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  /// ✅ SAFE ENROLLED
  int getEnrolled(Map course) {

  final enrolledUsers =
      course["enrolledUsers"];

  if (enrolledUsers is List) {
    return enrolledUsers.length;
  }

  return 0;
}


  @override
  Widget build(BuildContext context) {
    final coursesBox = Hive.box('coursesBox');

    final allCourses = coursesBox.values.toList();

    final availableCategories = allCourses
        .map((e) =>
            (e as Map)["categoryType"] ?? e["category"] ?? "Uncategorized")
        .toSet()
        .toList();

    /// ✅ FIXED: show ALL selected categories (no filtering removal)
    final filteredSelectedCategories = selectedCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                TweenAnimationBuilder<double>(
                  key: _animationKey,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: "Welcome "),
                                TextSpan(
                                  text: fullName,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 24, 105, 172),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationPage(),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.notifications_none,
                              color: Color.fromARGB(255, 24, 105, 172),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// SEARCH
                      TextField(
                          controller: _searchController,
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

                      /// CONTINUE WATCHING
                      _sectionTitle("Continue Watching"),
                      const SizedBox(height: 10),
                      _emptyCard("No courses yet", Icons.play_circle_outline),

                      const SizedBox(height: 20),

                      /// CATEGORIES
                      _sectionTitle(
                        "Categories",
                        onSeeAll: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CourseCategoriesPage(),
                            ),
                          );
                          loadUser(); // refresh after returning
                        },
                      ),
                      const SizedBox(height: 10),

                      filteredSelectedCategories.isEmpty
                          ? _emptyCard(
                              "No categories selected",
                              Icons.category_outlined,
                            )
                          : SizedBox(
                              height: 45,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredSelectedCategories.length,
                                itemBuilder: (context, index) {
                                  final category =
                                      filteredSelectedCategories[index];

                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        selectedCategories.remove(category);
                                      });
                                      await updateUserCategories();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 24, 105, 172),
                                        borderRadius:
                                            BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 20),

                  /// ⭐ Suggestions for You (FILTERED BY USER CATEGORIES)
                 _sectionTitle(
                      "Suggestions for You",
                      onSeeAll: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewSuggestionsPage(),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 10),

                  ValueListenableBuilder(
                    valueListenable: coursesBox.listenable(),
                    builder: (context, Box box, _) {
                      final courses = box.values.toList();

                  final publishedCourses = courses
                      .where((c) =>
                          (c as Map)["isPublished"] == true &&
                          c["title"]
                              .toString()
                              .toLowerCase()
                              .contains(searchText))
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList();

                      /// ✅ FILTER: only courses matching user selected categories
                      final suggestedCourses = publishedCourses.where((course) {
                        final categoryType =
                            course["categoryType"] ?? course["category"] ?? "Uncategorized";

                     return selectedCategories.contains(categoryType) &&
                    course["title"].toString().toLowerCase().contains(searchText);
                      }).toList();

                      if (suggestedCourses.isEmpty) {
                        return _emptyCard(
                          "No suggestions available for your categories",
                          Icons.lightbulb_outline,
                        );
                      }

                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestedCourses.length,
                          itemBuilder: (context, index) {
                            final course = suggestedCourses[index];

                            final coursesMap = box.toMap();

                            final key = coursesMap.keys.firstWhere(
                              (k) => box.get(k)["title"] == course["title"],
                            );

                            final categoryType =
                                course["categoryType"] ?? course["category"] ?? "Uncategorized";

                            final rating = getRating(course);
                            final enrolled = getEnrolled(course);

                            return GestureDetector(
                                  onTap: () async {

                                    final currentUser = await UserStore.getCurrentUser();

                                    final currentEmail = currentUser?["email"];

                                    final ownerEmail = course["ownerEmail"];

                                    // OWNER
                                    if (currentEmail == ownerEmail) {

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ViewAnalyticsPage(
                                            course: course,
                                          ),
                                        ),
                                      );

                                    } else {

                                      // NOT OWNER
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EnrollCoursePage(
                                            course: course,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 190,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.grey.shade300),
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
                                                  course["image"].toString().isNotEmpty)
                                              ? Image.file(
                                                  File(course["image"]),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                              : const Center(
                                                  child: Icon(Icons.image, size: 40, color: Colors.grey),
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

                                                await toggleSave(coursesBox, key);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// DETAILS (UNCHANGED UI)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course["title"] ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color.fromARGB(255, 24, 105, 172),
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 24, 105, 172)
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            categoryType,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color.fromARGB(255, 24, 105, 172),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    size: 14, color: Colors.orange),
                                                const SizedBox(width: 4),
                                                Text(
                                                  rating.toStringAsFixed(1),
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.people,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "$enrolled",
                                                  style: const TextStyle(fontSize: 11),
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
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                      const SizedBox(height: 20),

                        /// COURSES
                        _sectionTitle(
                          "Courses",
                          onSeeAll: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewCoursesPage(),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 10),

                      ValueListenableBuilder(
                        valueListenable: coursesBox.listenable(),
                        builder: (context, Box box, _) {
                          final courses = box.values.toList();

                      final publishedCourses = courses
                          .where((c) =>
                              (c as Map)["isPublished"] == true &&
                              c["title"]
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchText))
                          .map((e) => Map<String, dynamic>.from(e))
                          .toList();

                          if (publishedCourses.isEmpty) {
                            return _emptyCard(
                              "No courses available",
                              Icons.school_outlined,
                            );
                          }

                          return SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: publishedCourses.length,
                              itemBuilder: (context, index) {
                              final coursesMap = box.toMap();
                              final keys = coursesMap.keys.toList();
                              final values = coursesMap.values.toList();

                              final course = publishedCourses[index];

                              final key = coursesMap.keys.firstWhere(
                                (k) => box.get(k)["title"] == course["title"],
                              );

                                final categoryType =
                                    course["categoryType"] ??
                                        course["category"] ??
                                        "Uncategorized";

                                final rating = getRating(course);
                                final enrolled = getEnrolled(course);

                                return InkWell(
                                 onTap: () async {

  final currentUser = await UserStore.getCurrentUser();

  final currentEmail = currentUser?["email"];

  final ownerEmail = course["ownerEmail"];

  // OWNER
  if (currentEmail == ownerEmail) {

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ViewAnalyticsPage(
        course: course,
      ),
    ),
  );

  } else {

    // NOT OWNER
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnrollCoursePage(
          course: course,
        ),
      ),
    );
  }
},
                                  child: Container(
                                  width: 190,
                                  margin:
                                      const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// IMAGE
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.only(
                                          topLeft: Radius.circular(14),
                                          topRight: Radius.circular(14),
                                        ),
                                        child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: Stack(
                                            children: [

                                              (course["image"] != null &&
                                                      course["image"].toString().isNotEmpty)
                                                  ? Image.file(
                                                      File(course["image"]),
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    )
                                                  : const Center(
                                                      child: Icon(Icons.image, size: 40, color: Colors.grey),
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
                                                    await toggleSave(coursesBox, key);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      /// DETAILS
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              course["title"] ?? "",
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
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
                                                      vertical: 2),
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
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Color.fromARGB(
                                                      255, 24, 105, 172),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            /// ⭐ FINAL DISPLAY (0.0 / 0)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star,
                                                        size: 14,
                                                        color: Colors.orange),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      rating.toStringAsFixed(1),
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.people,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "$enrolled",
                                                      style: const TextStyle(
                                                          fontSize: 11),
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
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onSeeAll}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color.fromARGB(255, 24, 105, 172),
        ),
      ),

      /// ✅ Only show if onSeeAll is provided
      if (onSeeAll != null)
        InkWell(
          onTap: onSeeAll,
          child: const Text(
            "See All",
            style: TextStyle(color: Colors.grey),
          ),
        ),
    ],
  );
}

  Widget _emptyCard(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}