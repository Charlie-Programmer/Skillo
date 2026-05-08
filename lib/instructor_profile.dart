import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user_store.dart';
import 'main.dart';
import 'help_center.dart';
import 'my_certificate.dart';
import 'my_courses.dart';
import 'course_analytics.dart';


class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  String fullName = "Guest";
  String email = "No email";
  String role = "";
  String bio = "";
  String expertise = "";
  String selectedMethod = "card";

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final user = await UserStore.getCurrentUser();

      if (!mounted) return;

    if (user != null) {
      setState(() {
        fullName = user["fullName"] ?? "No Name";
        email = user["email"] ?? "No Email";
        role = user["role"] ?? "Instructor";
        bio = user["bio"] ?? "";
        expertise = user["expertise"] ?? "";

        if (user["profileImage"] != null &&
            user["profileImage"]!.isNotEmpty) {
          _profileImage = File(user["profileImage"]!);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      if (UserStore.currentUserEmail != null) {
        await UserStore.updateProfileImage(
          email: UserStore.currentUserEmail!,
          imagePath: pickedFile.path,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFFD6E4F0),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                                size: 40,
                                color: Color.fromARGB(255, 24, 105, 172))
                            : null,
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 24, 105, 172),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 24, 105, 172),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 1),

              _menuItem(
                Icons.menu_book,
                "My Courses",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyCoursesPage(),
                    ),
                  );
                },
              ),

              _menuItem(
                Icons.bar_chart,
                "Course Analytics",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseAnalyticsPage(),
                    ),
                  );
                },
              ),

              _menuItem(
                Icons.menu_book,
                "My Certificates",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyCertificatePage(),
                    ),
                  );
                },
              ),

              _menuItem(
                Icons.headphones,
                "Help Center",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterPage(),
                    ),
                  );
                },
              ),

              _menuItem(Icons.logout, "Log out", 
               onTap: () async {
                await UserStore.clearCurrentUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon,
              color: const Color.fromARGB(255, 24, 105, 172)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}