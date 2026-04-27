import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<OnboardModel> pages = [
    OnboardModel(
      image: "assets/slide1.png",
      title: "Enter the World of Skillo",
      subtitle:
          "Begin your educational journey with access to a wide range of courses.",
    ),
    OnboardModel(
      image: "assets/slide2.png",
      title: "Embark on Your Learning Adventure",
      subtitle:
          "Explore interactive lessons, quizzes, and multimedia content.",
    ),
    OnboardModel(
      image: "assets/slide3.png",
      title: "Engage with Expert Instructors",
      subtitle:
          "Connect with knowledgeable tutors for personalized guidance.",
    ),
    OnboardModel(
      image: "assets/slide4.png",
      title: "Personalize Your Learning Path",
      subtitle:
          "Customize your learning with progress tracking and activities.",
    ),
  ];

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
            setState(() {
        currentIndex = 0;
        _pageController.jumpToPage(0);
      });
    }
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentIndex == index ? 12 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.blue : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [


            /// PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// IMAGE
                        Image.asset(
                          page.image,
                          height: 280,
                        ),

                        const SizedBox(height: 40),

                        /// TITLE
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 24, 105, 172),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// SUBTITLE
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 94, 92, 92),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  List.generate(pages.length, (index) => buildDot(index)),
            ),

            const SizedBox(height: 30),

            // CONTINUE BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color.fromARGB(255, 24, 105, 172),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          currentIndex == pages.length - 1
                              ? "Get Started"
                              : "Continue",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// SKIP BUTTON
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentIndex = pages.length - 1;
                          _pageController.jumpToPage(pages.length - 1);
                        });
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Color.fromARGB(255, 94, 92, 92)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// MODEL CLASS
class OnboardModel {
  final String image;
  final String title;
  final String subtitle;

  OnboardModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}