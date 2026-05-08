import 'package:flutter/material.dart';
import 'user_store.dart';

class CourseCategoriesPage extends StatefulWidget {
  const CourseCategoriesPage({
    super.key,
  });

  @override
  State<CourseCategoriesPage> createState() =>
      _CourseCategoriesPageState();
}

class _CourseCategoriesPageState
    extends State<CourseCategoriesPage> {
  final List<String> allCategories = [
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

  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final user = await UserStore.getCurrentUser();

    if (!mounted) return;

    setState(() {
      selectedCategories = List<String>.from(
        user?["categories"] ?? [],
      );
    });
  }

  void toggleCategory(String category) async {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });

    final user = await UserStore.getCurrentUser();

    if (user != null) {
      user["categories"] = selectedCategories;

      await UserStore.updateCurrentUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

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

              const Text(
                "Course Categories",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GridView.builder(
                    itemCount: allCategories.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3,
                    ),

                    itemBuilder: (context, index) {
                      final category = allCategories[index];

                      final isSelected =
                          selectedCategories.contains(category);

                      return GestureDetector(
                        onTap: () => toggleCategory(category),

                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 250),

                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(
                                    255,
                                    24,
                                    105,
                                    172,
                                  )
                                : Colors.grey.shade100,

                            borderRadius:
                                BorderRadius.circular(16),

                            border: Border.all(
                              color: isSelected
                                  ? const Color.fromARGB(
                                      255,
                                      24,
                                      105,
                                      172,
                                    )
                                  : Colors.grey.shade300,
                            ),
                          ),

                          child: Center(
                            child: Text(
                              category,
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}