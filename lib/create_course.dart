import 'package:flutter/material.dart';
import "user_store.dart";
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:hive/hive.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() =>
      _CreateCoursePageState();
}

class _CreateCoursePageState
    extends State<CreateCoursePage> {

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController
      descriptionController =
      TextEditingController();

  final TextEditingController
      priceController =
      TextEditingController();

  File? _courseImage;

  final ImagePicker _picker =
      ImagePicker();

  String selectedCategory =
      "Programming";

  // ================= ERROR VARIABLES =================
  bool titleError = false;
  bool descriptionError = false;
  bool priceError = false;
  bool imageError = false;

  final List<String> categories = [
    "Programming",
    "Web Development",
    "Mobile Development",
    "Game Development",
    "Artificial Intelligence",
    "Machine Learning",
    "Cybersecurity",
    "Data Science",
    "Cloud Computing",
    "UI/UX Design",
    "Graphic Design",
    "Business",
    "Entrepreneurship",
    "Marketing",
    "Digital Marketing",
    "Finance",
    "Accounting",
    "Photography",
    "Video Editing",
    "Music",
    "Health & Fitness",
    "Personal Development",
    "Language Learning",
    "Teaching & Academics",
    "Cooking",
    "Lifestyle",
  ];

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {

    final pickedFile =
        await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {

      setState(() {
        _courseImage =
            File(pickedFile.path);

        imageError = false;
      });
    }
  }

  // ================= CREATE COURSE =================
  Future<void> createCourse() async {

    setState(() {

      titleError =
          titleController.text
              .trim()
              .isEmpty;

      descriptionError =
          descriptionController.text
              .trim()
              .isEmpty;

      priceError =
          priceController.text
              .trim()
              .isEmpty;

      imageError =
          _courseImage == null;
    });

    // STOP IF THERE IS ERROR
    if (titleError ||
        descriptionError ||
        priceError ||
        imageError) {
      return;
    }

    final box =
        Hive.box('coursesBox');

    final email =
        UserStore.currentUserEmail;

    if (email == null) return;

    final newCourse = {

      "title":
          titleController.text,

      "description":
          descriptionController.text,

      "category":
          selectedCategory,

      "price":
          priceController.text,

      "image":
          _courseImage?.path ?? "",

      "rating": 0.0,

      "enrolled": 0,

      "weeks": [],

      "isPublished": false,

      // OWNER
      "email": email,
    };

    await box.add(newCourse);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 10),

              // ================= BACK BUTTON =================
              IconButton(
                onPressed: () =>
                    Navigator.pop(context),

                icon: const Icon(
                  Icons.arrow_back,

                  color: Color.fromARGB(
                      255,
                      24,
                      105,
                      172),
                ),
              ),

              const SizedBox(height: 10),

              // ================= TITLE =================
              const Center(
                child: Text(
                  "Create Course",

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
              ),

              const SizedBox(height: 35),

              // ================= IMAGE =================
              Center(
                child: Column(
                  children: [

                    Stack(
                      children: [

                        Container(
                          height: 130,
                          width: 130,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                                    0xFFD6E4F0),

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        15),

                            image:
                                _courseImage !=
                                        null
                                    ? DecorationImage(
                                        image:
                                            FileImage(
                                          _courseImage!,
                                        ),

                                        fit: BoxFit
                                            .cover,
                                      )
                                    : null,
                          ),

                          child:
                              _courseImage ==
                                      null
                                  ? const Icon(
                                      Icons
                                          .image,

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

                        Positioned(
                          bottom: 0,
                          right: 0,

                          child:
                              GestureDetector(
                            onTap:
                                _pickImage,

                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .all(8),

                              decoration:
                                  const BoxDecoration(
                                color: Color
                                    .fromARGB(
                                        255,
                                        24,
                                        105,
                                        172),

                                shape: BoxShape
                                    .circle,
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .camera_alt,

                                size: 18,

                                color: Colors
                                    .white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (imageError)
                      const Padding(
                        padding:
                            EdgeInsets.only(
                          top: 8,
                        ),

                        child: Text(
                          "Please upload course image",

                          style: TextStyle(
                            color: Colors.red,

                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= COURSE TITLE =================
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

                  errorText:
                      titleError
                          ? "Please enter course title"
                          : null,
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

                  errorText:
                      descriptionError
                          ? "Please enter course description"
                          : null,
                ),
              ),

              const SizedBox(height: 20),

              // ================= CATEGORY =================
              const Text(
                "Category",

                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              DropdownSearch<String>(
                items: categories,

                selectedItem:
                    selectedCategory,

                popupProps:
                    PopupProps.menu(
                  showSearchBox: true,

                  containerBuilder:
                      (
                    context,
                    popupWidget,
                  ) {
                    return Container(
                      color: Colors.white,
                      child: popupWidget,
                    );
                  },

                  searchFieldProps:
                      const TextFieldProps(
                    decoration:
                        InputDecoration(
                      hintText:
                          "Search category",

                      prefixIcon:
                          Icon(Icons.search),
                    ),
                  ),

                  itemBuilder:
                      (
                    context,
                    item,
                    isSelected,
                  ) {
                    return ListTile(
                      title: Text(item),
                    );
                  },

                  emptyBuilder:
                      (
                    context,
                    searchEntry,
                  ) {
                    return const Padding(
                      padding:
                          EdgeInsets.all(
                              20),

                      child: Center(
                        child: Text(
                          "No category found",

                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },

                  searchDelay:
                      const Duration(
                    milliseconds: 0,
                  ),
                ),

                filterFn:
                    (item, filter) {

                  return item
                      .toLowerCase()
                      .contains(
                        filter
                            .toLowerCase(),
                      );
                },

                dropdownDecoratorProps:
                    DropDownDecoratorProps(
                  dropdownSearchDecoration:
                      InputDecoration(
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
                              .circular(
                                  10),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                onChanged: (value) {

                  setState(() {
                    selectedCategory =
                        value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ================= PRICE =================
              const Text(
                "Price",

                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    priceController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    InputDecoration(
                  hintText:
                      "Enter course price",

                  prefixText: "₱ ",

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

                  errorText:
                      priceError
                          ? "Please enter course price"
                          : null,
                ),
              ),

              const SizedBox(height: 35),

              // ================= CREATE BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                      createCourse,

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

                  child: const Text(
                    "CREATE COURSE",

                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,

                      letterSpacing: 1,

                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}