import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 10),

              // Title
              const Center(
                child: Text(
                  "Help Center",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 24, 105, 172),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Learning Support",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,

                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: const [
                    FAQTile(
                      question: "How do I access my courses?",
                      answer:
                          "Go to the Courses tab after login and select the course you enrolled in.",
                    ),
                    FAQTile(
                      question: "My video is not loading",
                      answer:
                          "Check your internet connection or try lowering video quality.",
                    ),
                    FAQTile(
                      question: "Can I continue where I left off?",
                      answer:
                          "Yes, your progress is automatically saved in each lesson.",
                    ),
                    FAQTile(
                      question: "How do I get my certificate?",
                      answer:
                          "Complete all lessons and quizzes to unlock your certificate.",
                    ),
                    FAQTile(
                      question: "I can't access a course I purchased",
                      answer:
                          "Try logging out and logging back in. If the issue continues, contact support.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Support section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Still need help?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Contact our learning support team anytime.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        print("Contact Support");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 24, 105, 172),
                      ),
                      child: const Text(
                        "Contact Support",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// FAQ tile
class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
     
      child: ExpansionTile(
        iconColor: const Color.fromARGB(255, 24, 105, 172),
        collapsedIconColor: const Color.fromARGB(255, 24, 105, 172),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}