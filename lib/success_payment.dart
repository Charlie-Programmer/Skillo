import 'package:flutter/material.dart';

class SuccessPayment extends StatelessWidget {
  final Map course;

  const SuccessPayment({
    super.key,
    required this.course,
  });

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

              // BACK BUTTON
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

              const SizedBox(height: 40),

              // IMAGE
              Image.asset(
                'assets/success.png',
                height: 220,
              ),

              const SizedBox(height: 25),

              // TITLE
              const Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 10),

              // SUBTITLE
              const Text(
                "Start Your Learning Today",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON (NOT FIXED, NORMAL FLOW)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                 onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 105, 172),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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