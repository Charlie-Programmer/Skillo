import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'user_store.dart';

class EditCoursePage extends StatefulWidget {
  final Map course;

  const EditCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  List weeks = [];
  File? selectedImage;

  late String originalTitle;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.course["title"]);

    descriptionController =
        TextEditingController(text: widget.course["description"]);

    weeks = widget.course["weeks"] ?? [];

    originalTitle = widget.course["title"];

    final imagePath = widget.course["image"];

    if (imagePath != null &&
        imagePath.toString().isNotEmpty) {
      selectedImage = File(imagePath);
    }
  }

  // ================= CLEAN DATA =================
  void cleanEmptyData() {

    // REMOVE EMPTY LECTURES
    for (var week in weeks) {
      if (week["lectures"] != null) {
        week["lectures"].removeWhere((lecture) {

          final title =
              (lecture["title"] ?? "")
                  .toString()
                  .trim();

          final video =
              (lecture["video"] ?? "")
                  .toString()
                  .trim();

          final pdf =
              (lecture["pdf"] ?? "")
                  .toString()
                  .trim();

          return title.isEmpty ||
              video.isEmpty ||
              pdf.isEmpty;
        });
      }
    }

    // REMOVE EMPTY WEEKS
    weeks.removeWhere((week) {

      final lectures = week["lectures"] ?? [];

      if (lectures.isEmpty) {
        return true;
      }

      final hasValidLecture =
          lectures.any((lecture) {

        final title =
            (lecture["title"] ?? "")
                .toString()
                .trim();

        final video =
            (lecture["video"] ?? "")
                .toString()
                .trim();

        final pdf =
            (lecture["pdf"] ?? "")
                .toString()
                .trim();

        return title.isNotEmpty &&
            video.isNotEmpty &&
            pdf.isNotEmpty;
      });

      return !hasValidLecture;
    });

    setState(() {});
  }

  // ================= SAVE =================
  Future<void> saveCleanedData() async {

    cleanEmptyData();

    final box = Hive.box('coursesBox');

    widget.course["title"] =
        titleController.text;

    widget.course["description"] =
        descriptionController.text;

    widget.course["weeks"] = weeks;

    widget.course["image"] =
        selectedImage?.path ?? "";

    final courses = box.values.toList();

    final index = courses.indexWhere(
      (c) =>
          c["email"] ==
              widget.course["email"] &&
          c["title"] == originalTitle,
    );

    if (index != -1) {
      await box.putAt(index, widget.course);
    }
  }

  // ================= IMAGE PICK =================
  Future<void> pickImage() async {

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // ================= PICK VIDEO =================
  Future<void> pickVideo(
    int weekIndex,
    int lectureIndex,
  ) async {

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {

      String path =
          result.files.single.path!;

      setState(() {
        weeks[weekIndex]["lectures"]
            [lectureIndex]["video"] = path;
      });
    }
  }

  // ================= PICK PDF =================
  Future<void> pickPdf(
    int weekIndex,
    int lectureIndex,
  ) async {

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {

      String path =
          result.files.single.path!;

      setState(() {
        weeks[weekIndex]["lectures"]
            [lectureIndex]["pdf"] = path;
      });
    }
  }

  // ================= SAVE BUTTON =================
  void saveCourse() async {

  await saveCleanedData();

  // CHECK IF COURSE IS PUBLISHED
  final isPublished =
      widget.course["isPublished"] == true;

  // NOTIFICATION
  if (isPublished) {

    final notificationBox =
        Hive.box('notificationsBox');

    await notificationBox.add({
      "user": UserStore.currentUserEmail,
      "title": "Course Updated ✏️",
      "subtitle":
          "${widget.course["title"]} has been updated.",
      "time": DateTime.now().toString(),
    });
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Changes Saved"),
    ),
  );
}

  // ================= ADD WEEK =================
  void addWeek() {
    setState(() {
      weeks.add({
        "title": "",
        "lectures": [],
      });
    });
  }

  // ================= ADD LECTURE =================
  void addLecture(int weekIndex) {
    setState(() {
      weeks[weekIndex]["lectures"].add({
        "title": "",
        "video": "",
        "pdf": "",
      });
    });
  }

  // ================= AUTO SAVE =================
  Future<bool> onWillPop() async {

    await saveCleanedData();

    return true;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF5F6FA),

        body: SafeArea(
          child: Column(
            children: [

              // ================= HEADER =================
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [

                    const SizedBox(height: 10),

                    Align(
                      alignment:
                          Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () async {

                          await saveCleanedData();

                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(
                              255,
                              24,
                              105,
                              172),
                        ),
                      ),
                    ),

                    const Text(
                      "Edit Course",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w600,
                        color: Color.fromARGB(
                            255,
                            24,
                            105,
                            172),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  children: [

                    // ================= IMAGE =================
                    Center(
                      child: Stack(
                        children: [

                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              height: 130,
                              width: 130,
                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                    0xFFD6E4F0),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                                image:
                                    selectedImage !=
                                            null
                                        ? DecorationImage(
                                            image:
                                                FileImage(
                                              selectedImage!,
                                            ),
                                            fit: BoxFit
                                                .cover,
                                          )
                                        : null,
                              ),
                              child:
                                  selectedImage ==
                                          null
                                      ? const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Color
                                              .fromARGB(
                                                  255,
                                                  24,
                                                  105,
                                                  172),
                                        )
                                      : null,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .all(8),
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color.fromARGB(
                                          255,
                                          24,
                                          105,
                                          172),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= TITLE =================
                    const Text(
                      "Course Title",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller:
                          titleController,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Enter course title",
                        filled: true,
                        fillColor:
                            Colors.white,
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(10),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= DESCRIPTION =================
                    const Text(
                      "Course Description",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 5,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Enter course description",
                        filled: true,
                        fillColor:
                            Colors.white,
                        contentPadding:
                            const EdgeInsets
                                .all(15),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(10),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================= ADD WEEK =================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                          ElevatedButton.icon(
                        onPressed: addWeek,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color
                                  .fromARGB(
                                      255,
                                      24,
                                      105,
                                      172),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "ADD WEEK",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= WEEKS =================
                    ...List.generate(
                      weeks.length,
                      (weekIndex) {

                        final week =
                            weeks[weekIndex];

                        return Card(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(14),
                            child: Column(
                              children: [

                                // WEEK TITLE
                                Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,
                                  child: Text(
                                    "Week ${weekIndex + 1}",
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color: Color
                                          .fromARGB(
                                              255,
                                              24,
                                              105,
                                              172),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height: 10),

                                // ADD LECTURE
                                Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,
                                  child:
                                      TextButton
                                          .icon(
                                    onPressed:
                                        () =>
                                            addLecture(
                                      weekIndex,
                                    ),
                                    icon:
                                        const Icon(
                                      Icons.add,
                                    ),
                                    label:
                                        const Text(
                                      "Add Lecture",
                                    ),
                                  ),
                                ),

                                ...List.generate(
                                  week["lectures"]
                                      .length,
                                  (
                                    lectureIndex,
                                  ) {

                                    final lecture =
                                        week[
                                                "lectures"]
                                            [
                                            lectureIndex];

                                    return Column(
                                      children: [

                                        // LECTURE TITLE
                                        TextFormField(
                                          initialValue:
                                              lecture[
                                                      "title"] ??
                                                  "",
                                          onChanged:
                                              (
                                            value,
                                          ) {
                                            lecture[
                                                    "title"] =
                                                value;
                                          },
                                          decoration:
                                              const InputDecoration(
                                            labelText:
                                                "Lecture Title",
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                15),

                                        // VIDEO BUTTON
                                        SizedBox(
                                          width: double
                                              .infinity,
                                          height: 50,
                                          child:
                                              ElevatedButton.icon(
                                            onPressed:
                                                () =>
                                                    pickVideo(
                                              weekIndex,
                                              lectureIndex,
                                            ),
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255,
                                                      24,
                                                      105,
                                                      172),
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                              ),
                                            ),
                                            icon:
                                                const Icon(
                                              Icons
                                                  .video_library,
                                              color: Colors
                                                  .white,
                                            ),
                                            label:
                                                Text(
                                              lecture["video"] ==
                                                          null ||
                                                      lecture["video"]
                                                          .toString()
                                                          .isEmpty
                                                  ? "UPLOAD VIDEO"
                                                  : "VIDEO UPLOADED",
                                              style:
                                                  const TextStyle(
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                10),

                                        // PDF BUTTON
                                        SizedBox(
                                          width: double
                                              .infinity,
                                          height: 50,
                                          child:
                                              ElevatedButton.icon(
                                            onPressed:
                                                () =>
                                                    pickPdf(
                                              weekIndex,
                                              lectureIndex,
                                            ),
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255,
                                                      24,
                                                      105,
                                                      172),
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                              ),
                                            ),
                                            icon:
                                                const Icon(
                                              Icons
                                                  .picture_as_pdf,
                                              color: Colors
                                                  .white,
                                            ),
                                            label:
                                                Text(
                                              lecture["pdf"] ==
                                                          null ||
                                                      lecture["pdf"]
                                                          .toString()
                                                          .isEmpty
                                                  ? "UPLOAD PDF"
                                                  : "PDF UPLOADED",
                                              style:
                                                  const TextStyle(
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                15),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ================= BUTTONS =================
                    Row(
                      children: [

                        // SAVE
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child:
                                ElevatedButton(
                              onPressed:
                                  saveCourse,
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    const Color
                                        .fromARGB(
                                            255,
                                            24,
                                            105,
                                            172),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              10),
                                ),
                              ),
                              child:
                                  const Text(
                                "SAVE COURSE",
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  letterSpacing:
                                      1,
                                  color: Colors
                                      .white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        // PUBLISH
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child:
                                ElevatedButton(
                              onPressed: () async {

                              cleanEmptyData();

                              // CHECK IF ALREADY PUBLISHED
                              final alreadyPublished =
                                  widget.course["isPublished"] == true;

                              // IF ALREADY PUBLISHED
                              if (alreadyPublished) {

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Course is already published",
                                    ),
                                  ),
                                );

                                return;
                              }

                              // FIRST TIME PUBLISH
                              widget.course["isPublished"] = true;
                              widget.course["rating"] = 0.0;
                              widget.course["students"] = 0;

                              await saveCleanedData();

                              final box = Hive.box('notificationsBox');

                              await box.add({
                                "user": UserStore.currentUserEmail,
                                "title": "Course Published 🎉",
                                "subtitle":
                                    "${widget.course["title"]} is now live!",
                                "time": DateTime.now().toString(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Course Published"),
                                ),
                              );
                            },
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    const Color
                                        .fromARGB(
                                            255,
                                            24,
                                            105,
                                            172),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              10),
                                ),
                              ),
                              child:
                                  const Text(
                                "PUBLISH COURSE",
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  letterSpacing:
                                      1,
                                  color: Colors
                                      .white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}