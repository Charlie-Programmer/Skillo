import 'package:flutter/material.dart';
import 'package:skillo/onboarding_screen.dart';
import 'user_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  } catch (e) {
    print("Google Sign-In error: $e");
    return null;
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 1),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 45,
                      height: 45,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "SIGN IN",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 24, 105, 172),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 1),

              const Text(
                "Create Your Account To Embark On Your\nEducational Adventure",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 94, 92, 92),
                  fontFamily: "Cali",
                ),
              ),

              const SizedBox(height: 1),

              _buildLabel("Full Name"),
              _buildTextField(
                controller: _fullNameController,
                errorText: _fullNameError,
              ),

              const SizedBox(height: 1),

              _buildLabel("Email"),
              _buildTextField(
                controller: _emailController,
                errorText: _emailError,
              ),

              const SizedBox(height: 1),

              _buildLabel("Password"),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 1),

              _buildLabel("Confirm Password"),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _inputDecoration(
                  errorText: _confirmPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fullNameError = _fullNameController.text.isEmpty
                          ? "Full Name is required"
                          : null;

                      _emailError = _emailController.text.isEmpty
                          ? "Email is required"
                          : null;

                      _passwordError = _passwordController.text.isEmpty
                          ? "Password is required"
                          : null;

                      _confirmPasswordError =
                          _confirmPasswordController.text.isEmpty
                              ? "Confirm Password is required"
                              : (_confirmPasswordController.text !=
                                      _passwordController.text
                                  ? "Password does not match"
                                  : null);
                    });

                    if (_fullNameError == null &&
                        _emailError == null &&
                        _passwordError == null &&
                        _confirmPasswordError == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account Created Successfully"),
                        ),
                      );
                      UserStore.addUser(
                        fullName: _fullNameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      UserStore.currentUserEmail = _emailController.text.trim();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 24, 105, 172),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("or Sign In with"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/facebook.png',
                    width: 21,
                    height: 24,
                  ),
                  label: const Text("Sign In with Facebook"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 24, 105, 172),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final userCredential = await signInWithGoogle();

                    if (userCredential != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/google.png',
                    height: 20,
                  ),
                  label: const Text("Sign In with Google"),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an Account?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w400,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(255, 24, 105, 172),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(errorText: errorText),
    );
  }

  InputDecoration _inputDecoration({
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      errorText: errorText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null
              ? Colors.red
              : const Color.fromARGB(255, 24, 105, 172),
          width: 3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : Colors.blue,
          width: 3,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }
}