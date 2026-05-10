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

 bool _isWeekCompleted(int weekIndex) {
  final week = weeks[weekIndex];
  final lectures = week["lectures"] ?? [];

  for (int i = 0; i < lectures.length; i++) {
    final key = "w${weekIndex}_l$i";

    if (!completedLectures.contains(key)) {
      return false;
    }
  }

  return true;
}

  static const Color primaryColor = Color.fromARGB(255, 24, 105, 172);

  @override
  void initState() {
    super.initState();
    _loadProgress();
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
                    onPressed: () => Navigator.pop(context),
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

                /// TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
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
                                        content: Text("Complete all lectures before moving to next week."),
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
                              color: isSelected ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: primaryColor),
                            ),
                            child: Text(
                              "Week ${index + 1}",
                              style: TextStyle(
                                color: isSelected ? Colors.white : primaryColor,
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

  /// WEEK CONTENT
  Widget _buildWeekContent(int weekIndex) {
    final week = weeks[weekIndex];
    final lectures = week["lectures"] ?? [];

    final List<Widget> sections = [];
    const int lecturesPerGroup = 3;

    for (int i = 0; i < lectures.length; i += lecturesPerGroup) {
      final groupEnd = (i + lecturesPerGroup).clamp(0, lectures.length);

      for (int j = i; j < groupEnd; j++) {
        final lecture = lectures[j];
        final lectureTitle = "Lecture ${j + 1}: ${lecture["title"] ?? "Untitled"}";
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

  /// LECTURE TILE
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
                        color: isCompleted
                            ? Colors.grey
                            : primaryColor,
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
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
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