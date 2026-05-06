import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'user_store.dart'; 
import 'nav_bar.dart';

class BeTheInstructorPage extends StatefulWidget {
  const BeTheInstructorPage({super.key});

  @override
  State<BeTheInstructorPage> createState() =>
      _BeTheInstructorPageState();
}

class _BeTheInstructorPageState
    extends State<BeTheInstructorPage> {
  int currentStep = 0;
  bool showErrors = false;

  // Step 1
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  String? education;
  final experienceController = TextEditingController();

  // Step 2
  PlatformFile? resumeFile;

  // Step 3
  final skillsController = TextEditingController();
  final teachingExpController = TextEditingController();
  final bioController = TextEditingController();

  // ✅ LOAD CURRENT USER
  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final user = await UserStore.getCurrentUser();

    if (user != null) {
      setState(() {
        fullNameController.text = user["fullName"] ?? "";
        emailController.text = user["email"] ?? "";
      });
    }
  }

  Future<void> pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() => resumeFile = result.files.first);
    }
  }

  // ================= VALIDATION =================

  bool validateStep0() {
    return fullNameController.text.trim().isNotEmpty &&
        emailController.text.contains("@") &&
        education != null &&
        experienceController.text.trim().isNotEmpty;
  }

  bool validateStep1() {
    return resumeFile != null;
  }

  bool validateStep2() {
    return skillsController.text.trim().isNotEmpty &&
        teachingExpController.text.trim().isNotEmpty &&
        bioController.text.trim().isNotEmpty;
  }

  void nextStep() {
    setState(() => showErrors = true);

    if (currentStep == 0 && !validateStep0()) return;
    if (currentStep == 1 && !validateStep1()) return;
    if (currentStep == 2 && !validateStep2()) return;

    if (currentStep < 2) {
      setState(() {
        currentStep++;
        showErrors = false;
      });
    } else {
      submitForm();
    }
  }

void submitForm() async {
  await UserStore.updateUserRole(
    email: emailController.text,
    role: "Instructor",
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Application Submitted Successfully!")),
  );

  await Future.delayed(const Duration(milliseconds: 200));

 Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => const MainNavigation(),
  ),
  (route) => false,
);
}

  // ================= INPUT DESIGN =================

  InputDecoration input(
    String label, {
    required bool hasError,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      errorText: hasError ? errorText : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError
              ? Colors.red
              : const Color.fromARGB(255, 24, 105, 172),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError
              ? Colors.red
              : const Color.fromARGB(255, 24, 105, 172),
          width: 3,
        ),
      ),
    );
  }

  // ================= STEP BOX =================

  Widget stepBox({
    required int step,
    required String title,
    required Widget child,
  }) {
    bool isActive = currentStep == step;
    bool isDone = currentStep > step;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color.fromARGB(255, 24, 105, 172)
              : isDone
                  ? Colors.green
                  : const Color.fromARGB(255, 24, 105, 172),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isDone
                    ? Colors.green
                    : const Color.fromARGB(255, 24, 105, 172),
                child: Text(
                  "${step + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? const Color.fromARGB(255, 24, 105, 172)
                      : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isActive) child,
        ],
      ),
    );
  }

  // ================= STEP 1 =================

  Widget buildBasicInfo() {
    return Column(
      children: [
        TextField(
          controller: fullNameController,
          readOnly: true,
          decoration: input(
            "Full Name",
            hasError:
                showErrors && fullNameController.text.isEmpty,
            errorText: "Full name is required",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          readOnly: true,
          decoration: input(
            "Email",
            hasError:
                showErrors && !emailController.text.contains("@"),
            errorText: "Enter valid email",
          ),
        ),
        const SizedBox(height: 10,),
        const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: education,
              dropdownColor: Colors.white, // 👈 background of dropdown menu
              iconEnabledColor: const Color.fromARGB(255, 24, 105, 172),
              decoration: input(
                "Highest Education",
                hasError: showErrors && education == null,
                errorText: "Select education",
              ).copyWith(
                fillColor: Colors.white, 
                filled: true,
              ),
              items: const [
                DropdownMenuItem(
                    value: "High School", child: Text("High School")),
                DropdownMenuItem(
                    value: "Bachelor", child: Text("Bachelor")),
                DropdownMenuItem(
                    value: "Master", child: Text("Master")),
                DropdownMenuItem(value: "PhD", child: Text("PhD")),
              ],
              onChanged: (v) => setState(() => education = v),
            ),
        const SizedBox(height: 10),
        TextField(
          controller: experienceController,
          decoration: input(
            "Experience (Years)",
            hasError: showErrors &&
                experienceController.text.isEmpty,
            errorText: "Experience is required",
          ),
        ),
      ],
    );
  }

  // ================= STEP 2 =================

  Widget buildResumeUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: pickResume,
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload Resume"),
        ),
        const SizedBox(height: 10),
        Text(
          resumeFile != null
              ? "Selected: ${resumeFile!.name}"
              : "Resume is required",
          style: TextStyle(
            color: showErrors && resumeFile == null
                ? Colors.red
                : Colors.green,
          ),
        ),
      ],
    );
  }

  // ================= STEP 3 =================

  Widget buildMoreDetails() {
    return Column(
      children: [
        TextField(
          controller: skillsController,
          decoration: input(
            "Skills",
            hasError:
                showErrors && skillsController.text.isEmpty,
            errorText: "Skills required",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: teachingExpController,
          decoration: input(
            "Teaching Experience",
            hasError: showErrors &&
                teachingExpController.text.isEmpty,
            errorText: "Teaching experience required",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: bioController,
          maxLines: 4,
          decoration: input(
            "Short Bio",
            hasError:
                showErrors && bioController.text.isEmpty,
            errorText: "Bio required",
          ),
        ),
      ],
    );
  }

  Widget buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 24, 105, 172),
        ),
        child: Text(
          currentStep == 2 ? "SUBMIT" : "NEXT",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Instructor Application",
          style: TextStyle(
            color: Color.fromARGB(255, 24, 105, 172),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              stepBox(
                  step: 0,
                  title: "Basic Info",
                  child: buildBasicInfo()),
              stepBox(
                  step: 1,
                  title: "Resume",
                  child: buildResumeUpload()),
              stepBox(
                  step: 2,
                  title: "More Details",
                  child: buildMoreDetails()),
              const SizedBox(height: 20),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }
}