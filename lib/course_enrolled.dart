import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_store.dart';
import 'pdf_viewer_page.dart';

class EnrolledCoursePage extends StatefulWidget {
  final Map course;

  const EnrolledCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EnrolledCoursePage> createState() => _EnrolledCoursePageState();
}

class _EnrolledCoursePageState extends State<EnrolledCoursePage> {
  int selectedWeekIndex = 0;
  Set<String> completedLectures = {};
  double userRating = 0;

  bool _isWeekCompleted(int weekIndex) {
    final week = weeks[weekIndex];
    final lectures = week["lectures"] ?? [];

    for (int i = 0; i < lectures.length; i++) {
      final key = "w${weekIndex}_l$i";
      if (!completedLectures.contains(key)) return false;
    }

    return true;
  }

  bool get _isAllCompleted {
    int totalLectures = 0;
    for (int w = 0; w < weeks.length; w++) {
      final lectures = weeks[w]["lectures"] ?? [];
      for (int l = 0; l < lectures.length; l++) {
        totalLectures++;
        if (!completedLectures.contains("w${w}_l$l")) return false;
      }
    }
    return totalLectures > 0;
  }

  static const Color primaryColor = Color.fromARGB(255, 24, 105, 172);

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final user = await UserStore.getCurrentUser();
    final email = user?["email"] ?? "";
    final title = widget.course["title"] ?? "";

    final progressBox = Hive.box('progressBox');
    final ratingKey = "${email}_${title}_rating";
    final saved = progressBox.get(ratingKey);

    if (saved != null) {
      setState(() {
        userRating = (saved is double) ? saved : (saved as int).toDouble();
      });
    }
  }

  Future<void> _saveUserRating(double rating) async {
    final user = await UserStore.getCurrentUser();
    final email = user?["email"] ?? "";
    final title = widget.course["title"] ?? "";

    // Save to progressBox
    final progressBox = Hive.box('progressBox');
    final ratingKey = "${email}_${title}_rating";
    await progressBox.put(ratingKey, rating);

    // Update course rating in coursesBox
    final coursesBox = Hive.box('coursesBox');
    final coursesMap = coursesBox.toMap();
    final key = coursesMap.keys.firstWhere(
      (k) => coursesBox.get(k)["title"] == title,
      orElse: () => null,
    );

    if (key != null) {
      final course = Map<String, dynamic>.from(coursesBox.get(key));

      // Collect all ratings
      final allRatingKeys = progressBox.keys
          .where((k) => k.toString().endsWith("_${title}_rating"))
          .toList();

      double total = 0;
      for (final k in allRatingKeys) {
        final r = progressBox.get(k);
        if (r != null) total += (r is double) ? r : (r as int).toDouble();
      }

      final avgRating = total / allRatingKeys.length;
      course["rating"] = double.parse(avgRating.toStringAsFixed(1));

      await coursesBox.put(key, course);
    }

    setState(() {
      userRating = rating;
    });
  }

  void _showRatingDialog() {
  double tempRating = userRating;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white, // White dialog background
            title: const Center( // Center the title
              child: Text(
                "Rate this Course",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "How would you rate this course?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          tempRating = index + 1.0;
                        });
                      },
                      child: Icon(
                        index < tempRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  tempRating > 0
                      ? "${tempRating.toInt()} / 5"
                      : "Tap a star to rate",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: tempRating > 0
                    ? () async {
                        await _saveUserRating(tempRating);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Rating submitted!"),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _loadProgress() async {
    final user = await UserStore.getCurrentUser();
    final email = user?["email"] ?? "";
    final title = widget.course["title"] ?? "";

    final progressBox = Hive.box('progressBox');
    final key = "${email}_${title}_completed";

    final saved = progressBox.get(key);

    if (saved != null && saved is List) {
      setState(() {
        completedLectures = Set<String>.from(saved.map((e) => e.toString()));
      });
    }
  }

  Future<void> _saveProgress() async {
    final user = await UserStore.getCurrentUser();
    final email = user?["email"] ?? "";
    final title = widget.course["title"] ?? "";

    final progressBox = Hive.box('progressBox');
    final key = "${email}_${title}_completed";

    await progressBox.put(key, completedLectures.toList());
  }

  void _toggleComplete(String lectureKey) {
    setState(() {
      if (completedLectures.contains(lectureKey)) {
        completedLectures.remove(lectureKey);
      } else {
        completedLectures = {...completedLectures, lectureKey};
      }
    });

    _saveProgress();

    // Show rating dialog when all lectures are completed
    if (_isAllCompleted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showRatingDialog();
      });
    }
  }

  List get weeks => widget.course["weeks"] ?? [];

  @override
  Widget build(BuildContext context) {
    final title = widget.course["title"] ?? "Course";
    final image = widget.course["image"] ?? "";

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

                /// BACK BUTTON
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// COURSE IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: image.isNotEmpty
                      ? Image.file(
                          File(image),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 60),
                        ),
                ),

                const SizedBox(height: 16),

                /// TITLE + RATE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showRatingDialog,
                        child: Column(
                          children: [
                            Icon(
                              userRating > 0 ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 28,
                            ),
                            Text(
                              userRating > 0
                                  ? "${userRating.toInt()}/5"
                                  : "Rate",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// WEEK TABS
                if (weeks.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(weeks.length, (index) {
                        final isSelected = selectedWeekIndex == index;

                        return GestureDetector(
                          onTap: () {
                            if (index > selectedWeekIndex) {
                              if (!_isWeekCompleted(selectedWeekIndex)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Complete all lectures before moving to next week."),
                                  ),
                                );
                                return;
                              }
                            }
                            setState(() {
                              selectedWeekIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: primaryColor),
                            ),
                            child: Text(
                              "Week ${index + 1}",
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : primaryColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    "Course Contents",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (weeks.isEmpty)
                  const Center(child: Text("No content available"))
                else
                  _buildWeekContent(selectedWeekIndex),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekContent(int weekIndex) {
    final week = weeks[weekIndex];
    final lectures = week["lectures"] ?? [];

    final List<Widget> sections = [];
    const int lecturesPerGroup = 3;

    for (int i = 0; i < lectures.length; i += lecturesPerGroup) {
      final groupEnd = (i + lecturesPerGroup).clamp(0, lectures.length);

      for (int j = i; j < groupEnd; j++) {
        final lecture = lectures[j];
        final lectureTitle =
            "Lecture ${j + 1}: ${lecture["title"] ?? "Untitled"}";
        final lectureKey = "w${weekIndex}_l$j";
        final isCompleted = completedLectures.contains(lectureKey);

        sections.add(
          _buildLectureTile(
            lectureTitle: lectureTitle,
            lectureKey: lectureKey,
            isCompleted: isCompleted,
            onToggle: () => _toggleComplete(lectureKey),
            lecture: lecture,
          ),
        );
      }

      sections.add(const SizedBox(height: 20));
    }

    return Column(children: sections);
  }

  Widget _buildLectureTile({
    required String lectureTitle,
    required String lectureKey,
    required bool isCompleted,
    required VoidCallback onToggle,
    required Map lecture,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              if (lecture["pdf"] != null &&
                  lecture["pdf"].toString().isNotEmpty) {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfViewerPage(
                      filePath: lecture["pdf"],
                      title: lectureTitle,
                    ),
                  ),
                );

                if (result == true) {
                  setState(() {
                    completedLectures = {...completedLectures, lectureKey};
                  });
                  await _saveProgress();

                  // Show rating dialog when all lectures are completed
                  if (_isAllCompleted && mounted) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) _showRatingDialog();
                    });
                  }
                }
              } else {
                onToggle();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      lectureTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isCompleted ? Colors.grey : primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? primaryColor : Colors.transparent,
                      border: Border.all(
                        color: primaryColor,
                        width: isCompleted ? 2 : 1,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}