import 'package:flutter/material.dart';
import 'user_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "Guest";

  // 👇 animation key to restart animation
  Key _animationKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final user = await UserStore.getCurrentUser();
    if (!mounted) return;

    setState(() {
      fullName = user?["fullName"] ?? "Guest";
    });
  }

  // 👇 call this when Home tab is clicked
  void restartAnimation() {
    setState(() {
      _animationKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          key: _animationKey, // 👈 IMPORTANT
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // default text color
                            ),
                            children: [
                              const TextSpan(text: "Welcome "),
                              TextSpan(
                                text: fullName,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 24, 105, 172), // 👈 NAME COLOR
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                    const Icon(
                      Icons.notifications_none,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// SEARCH
                TextField(
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

                _sectionTitle("Continue Watching",
                    color: const Color.fromARGB(255, 24, 105, 172)),
                const SizedBox(height: 10),
                _emptyCard("No courses yet", Icons.play_circle_outline),

                const SizedBox(height: 20),

                _sectionTitle("Categories",
                    color: const Color.fromARGB(255, 24, 105, 172)),

                const SizedBox(height: 20),

                _sectionTitle("Suggestions for You",
                    color: const Color.fromARGB(255, 24, 105, 172)),
                const SizedBox(height: 10),
                _emptyCard("No suggestions available",
                    Icons.lightbulb_outline),

                const SizedBox(height: 20),

                _sectionTitle("Top Courses",
                    color: const Color.fromARGB(255, 24, 105, 172)),
                const SizedBox(height: 10),
                _emptyCard("No courses available",
                    Icons.school_outlined),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        const Text(
          "See All",
          style: TextStyle(color: Color.fromARGB(255, 94, 92, 92)),
        ),
      ],
    );
  }

  Widget _emptyCard(String message, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}