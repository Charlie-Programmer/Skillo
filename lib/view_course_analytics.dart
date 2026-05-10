import 'dart:io';
import 'package:flutter/material.dart';

class ViewAnalyticsPage extends StatelessWidget {
  final Map course;

  const ViewAnalyticsPage({
    super.key,
    required this.course,
  });

  // ================= TOTAL WEEKS =================
  int getTotalWeeks() {
    final weeks = course["weeks"];
    if (weeks is List) {
      return weeks.length;
    }
    return 0;
  }

  // ================= TOTAL LECTURES (FIXED) =================
  int getTotalLectures() {
    int count = 0;

    final weeks = course["weeks"];

    if (weeks == null || weeks is! List) return 0;

    for (var week in weeks) {
      if (week is Map) {
        final lectures = week["lectures"];

        if (lectures is List) {
          count += lectures.length;
        }
      }
    }

    return count;
  }


  // ================= TOTAL PDFS =================
  int getTotalPdfs() {
    int count = 0;

    final weeks = course["weeks"];

    if (weeks == null || weeks is! List) return 0;

    for (var week in weeks) {
      if (week is Map) {
        final lectures = week["lectures"];

        if (lectures is List) {
          for (var lec in lectures) {
            if ((lec["pdf"] ?? "").toString().isNotEmpty) {
              count++;
            }
          }
        }
      }
    }

    return count;
  }

  // ================= REVENUE =================
  double getRevenue() {
    final price =
        double.tryParse(course["price"]?.toString() ?? "0") ?? 0;

    final enrolled = course["enrolled"] ?? 0;

    return price * enrolled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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

              const SizedBox(height: 5),

              const Text(
                "Course Analytics",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [

                    // ================= COURSE CARD =================
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [

                          // IMAGE
                          course["image"] != ""
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(course["image"]),
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.image),
                                ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course["title"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 105, 172),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Category: ${course["category"] ?? ""}",
                                  style: const TextStyle(color: Colors.grey),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  "Price: ₱${course["price"] ?? "0"}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= STATS =================
                    Row(
                      children: [
                        _buildStatCard(
                          "⭐ Rating",
                          "${course["rating"] ?? 0}",
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          "👨‍🎓 Students",
                          "${course["enrolled"] ?? 0}",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildStatCard(
                          "📚 Weeks",
                          "${getTotalWeeks()}",
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          "🎥 Lectures",
                          "${getTotalLectures()}",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildStatCard(
                          "📄 PDFs",
                          "${getTotalPdfs()}",
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox()), // spacer only
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= REVENUE =================
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "💰 Total Revenue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₱${getRevenue().toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 24, 105, 172),
                            ),
                          ),
                        ],
                      ),
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

  // ================= STAT CARD =================
  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 24, 105, 172),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}