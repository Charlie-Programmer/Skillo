import 'package:flutter/material.dart';
import 'user_store.dart';
import 'student_profile.dart';
import 'instructor_profile.dart';

class ProfileRouter extends StatefulWidget {
  const ProfileRouter({super.key});

  @override
  State<ProfileRouter> createState() => _ProfileRouterState();
}

class _ProfileRouterState extends State<ProfileRouter> {
  Widget? targetPage;

  @override
  void initState() {
    super.initState();
    resolveProfile();
  }

  void resolveProfile() async {
    final user = await UserStore.getCurrentUser();
    final role = user?["role"] ?? "Student";

    if (!mounted) return;

    setState(() {
      targetPage = role == "Instructor"
          ? const InstructorProfileScreen()
          : const ProfileScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (targetPage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return targetPage!;
  }
}