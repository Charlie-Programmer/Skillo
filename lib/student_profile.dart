import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user_store.dart';
import 'main.dart';
import 'be_the_instructor.dart';
import 'instructor_profile.dart';
import 'help_center.dart';
import 'my_certificate.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "Guest";
  String email = "No email";
  String role = "";
  String selectedMethod = "card";

  bool get isInstructor => role == "Instructor";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

void loadUser() async {
  final user = await UserStore.getCurrentUser();

  if (!mounted) return; // 🔥 ADD THIS LINE

  if (user != null) {
    setState(() {
      fullName = user["fullName"] ?? "No Name";
      email = user["email"] ?? "No Email";
      role = user["role"] ?? "Student";

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
                  )
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),

              const SizedBox(height: 10),

             _menuItem(
                  Icons.school,
                  "Be the Instructor",
                  onTap: () async {
                    final user = await UserStore.getCurrentUser();
                    final currentRole = user?["role"] ?? "Student";

                    if (currentRole == "Instructor") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InstructorProfileScreen(),
                        ),
                      ).then((_) => loadUser()); // 🔥 REFRESH AFTER RETURN
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BeTheInstructorPage(),
                        ),
                      ).then((_) => loadUser()); // 🔥 REFRESH AFTER RETURN
                    }
                  }
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

              _menuItem(Icons.logout, "Log out", onTap: () async {

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