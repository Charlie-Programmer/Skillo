import 'package:flutter/material.dart';
import 'user_store.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
              const SizedBox(height: 35),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png', width: 45, height: 45),
                    const SizedBox(width: 5),
                    const Text(
                      "RESET PASSWORD",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 24, 105, 172),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Reset Your Password To Regain Access/nTo Your Learning Journey",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color.fromARGB(255, 94, 92, 92)),
              ),

              const SizedBox(height: 20),

              // EMAIL
              _buildLabel("Email"),
              _buildTextField(
                controller: _emailController,
                hasError: _emailError != null,
              ),
              if (_emailError != null)
                _errorText(_emailError!),

              const SizedBox(height: 10),

              // PASSWORD
              _buildLabel("New Password"),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  hasError: _passwordError != null,
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
              if (_passwordError != null)
                _errorText(_passwordError!),

              const SizedBox(height: 10),

              // CONFIRM PASSWORD
              _buildLabel("Confirm Password"),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _inputDecoration(
                  hasError: _confirmPasswordError != null,
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
              if (_confirmPasswordError != null)
                _errorText(_confirmPasswordError!),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _emailError =
                          _emailController.text.isEmpty
                              ? "Email is required"
                              : null;

                      _passwordError =
                          _passwordController.text.isEmpty
                              ? "New password is required"
                              : null;

                      _confirmPasswordError =
                          _confirmPasswordController.text.isEmpty
                              ? "Confirm password is required"
                              : (_confirmPasswordController.text !=
                                      _passwordController.text
                                  ? "Passwords do not match"
                                  : null);
                    });

                    if (_emailError == null &&
                        _passwordError == null &&
                        _confirmPasswordError == null) {

                      bool updated = UserStore.updatePassword(
                        email: _emailController.text,
                        newPassword: _passwordController.text,
                      );

                      setState(() {
                        if (!updated) {
                          _emailError = "Email not found";
                        } else {
                          _emailError = null;
                        }
                      });

                      if (updated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password Reset Successful"),
                          ),
                        );
                        Navigator.pop(context);
                      }
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
                  child: const Text("RESET PASSWORD"),
                ),
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
    bool hasError = false,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hasError: hasError),
    );
  }

  Widget _errorText(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    bool hasError = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError
              ? Colors.red
              : const Color.fromARGB(255, 24, 105, 172),
          width: 3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.blue,
          width: 3,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }
}