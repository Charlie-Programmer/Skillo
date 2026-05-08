import 'package:flutter/material.dart';
import 'user_store.dart';
import 'course_categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  String fullName = "Guest";

  List<String> selectedCategories = [];

  Key _animationKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final user =
        await UserStore.getCurrentUser();

    if (!mounted) return;

    setState(() {
      fullName =
          user?["fullName"] ?? "Guest";

      selectedCategories =
          List<String>.from(
        user?["categories"] ?? [],
      );
    });
  }

  Future<void> updateUserCategories() async {
    final user =
        await UserStore.getCurrentUser();

    if (user != null) {
      user["categories"] =
          selectedCategories;

      await UserStore
          .updateCurrentUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          key: _animationKey,
          duration:
              const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset:
                    Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                              text:
                                  "Welcome "),
                          TextSpan(
                            text: fullName,
                            style:
                                const TextStyle(
                              color: Color.fromARGB(
                                255,
                                24,
                                105,
                                172,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons
                          .notifications_none,
                      color: Color.fromARGB(
                        255,
                        24,
                        105,
                        172,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// SEARCH
                TextField(
                  decoration:
                      InputDecoration(
                    hintText: "Search",
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(25),
                      borderSide:
                          const BorderSide(
                        color: Color.fromARGB(
                          255,
                          24,
                          105,
                          172,
                        ),
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(25),
                      borderSide:
                          const BorderSide(
                        color: Color.fromARGB(
                          255,
                          24,
                          105,
                          172,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _sectionTitle("Continue Watching"),

                const SizedBox(height: 10),

                _emptyCard(
                  "No courses yet",
                  Icons.play_circle_outline,
                ),

                const SizedBox(height: 20),

                _sectionTitle("Categories"),

                const SizedBox(height: 10),

                selectedCategories.isEmpty
                    ? _emptyCard(
                        "No categories selected",
                        Icons
                            .category_outlined,
                      )
                    : SizedBox(
                        height: 45,
                        child:
                            ListView.builder(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              selectedCategories
                                  .length,
                          itemBuilder:
                              (context, index) {
                            final category =
                                selectedCategories[
                                    index];

                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  selectedCategories
                                      .remove(
                                    category,
                                  );
                                });

                                await updateUserCategories();
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  right: 10,
                                ),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 16,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color
                                          .fromARGB(
                                    255,
                                    24,
                                    105,
                                    172,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    25,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 20),

                _sectionTitle(
                    "Suggestions for You"),

                const SizedBox(height: 10),

                _emptyCard(
                  "No suggestions available",
                  Icons.lightbulb_outline,
                ),

                const SizedBox(height: 20),

                _sectionTitle("Courses"),

                const SizedBox(height: 10),

                _emptyCard(
                  "No courses available",
                  Icons.school_outlined,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color:
                Color.fromARGB(255, 24, 105, 172),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (title == "Categories") {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CourseCategoriesPage(),
                ),
              );

              loadUser();
            }
          },
          child: const Text(
            "See All",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(
      String message, IconData icon) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}