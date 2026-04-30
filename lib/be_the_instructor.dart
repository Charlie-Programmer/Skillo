
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BeTheInstructorPage extends StatefulWidget {
  const BeTheInstructorPage({super.key});

  @override
  State<BeTheInstructorPage> createState() => _BeTheInstructorPageState();
}

class _BeTheInstructorPageState extends State<BeTheInstructorPage> {
  int currentStep = 0;

  final _formKey = GlobalKey<FormState>();

  // Step 1
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? education;
  final TextEditingController experienceController = TextEditingController();

  // Step 2
  String? resumeFileName;
  String? resumePath;

  // Step 3
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController teachingExpController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  void nextStep() {
    if (!_formKey.currentState!.validate()) return;

    if (currentStep < 2) {
      setState(() => currentStep++);
    } else {
      submitForm();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  Future<void> pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          resumeFileName = result.files.single.name;
          resumePath = result.files.single.path;
        });
      }
    } catch (e) {
      debugPrint("File pick error: $e");
    }
  }

  void submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "fullName": fullNameController.text,
      "email": emailController.text,
      "education": education,
      "experience": experienceController.text,
      "resumeFileName": resumeFileName,
      "resumePath": resumePath,
      "skills": skillsController.text,
      "teachingExperience": teachingExpController.text,
      "bio": bioController.text,
    };

    debugPrint("Submitted Data: $data");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Application Submitted Successfully!")),
    );
  }

  // ✅ UPDATED INPUT STYLE (YOUR DESIGN)
  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 24, 105, 172),
          width: 3,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 24, 105, 172),
          width: 3,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 3,
        ),
      ),
    );
  }

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
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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

  Widget buildBasicInfo() {
    return Column(
      children: [
        TextFormField(
          controller: fullNameController,
          decoration: input("Full Name"),
          validator: (v) =>
              v == null || v.trim().isEmpty ? "Full name required" : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: emailController,
          decoration: input("Email"),
          validator: (v) =>
              v == null || !v.contains("@") ? "Invalid email" : null,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: education,
          decoration: input("Highest Education"),
          items: const [
            DropdownMenuItem(value: "High School", child: Text("High School")),
            DropdownMenuItem(value: "Bachelor", child: Text("Bachelor")),
            DropdownMenuItem(value: "Master", child: Text("Master")),
            DropdownMenuItem(value: "PhD", child: Text("PhD")),
          ],
          onChanged: (v) => setState(() => education = v),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: experienceController,
          decoration: input("Experience (Years)"),
        ),
      ],
    );
  }

  Widget buildResumeUpload() {
    return GestureDetector(
      onTap: pickResume,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 24, 105, 172), width: 3),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, size: 40),
              const SizedBox(height: 10),
              Text(resumeFileName ?? "Tap to upload Resume (Optional)"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMoreDetails() {
    return Column(
      children: [
        TextFormField(
          controller: skillsController,
          decoration: input("Skills"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: teachingExpController,
          decoration: input("Teaching Experience"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: bioController,
          maxLines: 4,
          decoration: input("Short Bio"),
        ),
      ],
    );
  }

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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      stepBox(step: 0, title: "Basic Info", child: buildBasicInfo()),
                      stepBox(step: 1, title: "Resume", child: buildResumeUpload()),
                      stepBox(step: 2, title: "More Details", child: buildMoreDetails()),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    ElevatedButton(onPressed: prevStep, child: const Text("Back")),
                  ElevatedButton(
                    onPressed: nextStep,
                    child: Text(currentStep == 2 ? "Submit" : "Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}