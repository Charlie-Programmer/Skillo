import 'package:flutter/material.dart';
import 'user_store.dart';
import 'nav_bar.dart';
import 'onboarding_screen.dart';

class FacebookSignInScreen extends StatefulWidget {
  const FacebookSignInScreen({super.key});

  @override
  State<FacebookSignInScreen> createState() => _FacebookSignInScreenState();
}

class _FacebookSignInScreenState extends State<FacebookSignInScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _fullNameError = _fullNameController.text.trim().isEmpty
          ? "Full Name is required"
          : null;
      _emailError = _emailController.text.trim().isEmpty
          ? "Email is required"
          : null;
      _passwordError = _passwordController.text.isEmpty
          ? "Password is required"
          : null;
    });

    if (_fullNameError != null ||
        _emailError != null ||
        _passwordError != null) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();

    await UserStore.loadUsers();
    final existingUser = await UserStore.getUser(email);

    if (existingUser != null) {
      final success = await UserStore.loginUser(
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (success) {
        final user = await UserStore.getCurrentUser();
        _navigateAfterLogin(user);
      } else {
        setState(() {
          _passwordError = "Incorrect password for this account";
        });
      }
    } else {
      await UserStore.addUser(
        fullName: fullName,
        email: email,
        password: password,
      );

      await UserStore.loginUser(email: email, password: password);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Facebook account linked successfully")),
      );

      final user = await UserStore.getCurrentUser();
      _navigateAfterLogin(user);
    }
  }

  void _navigateAfterLogin(Map<String, dynamic>? user) {
    if (user?["hasSeenOnboarding"] == "true") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 24, 105, 172)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/facebook.png', width: 40, height: 40),
                      const SizedBox(width: 8),
                      const Text(
                        "FACEBOOK",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 24, 105, 172),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Sign In With Your Facebook Account\nTo Continue Your Learning Journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 94, 92, 92),
                    fontFamily: "Cali",
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Full Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                TextField(
                  controller: _fullNameController,
                  decoration: _inputDecoration(errorText: _fullNameError),
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Facebook Email",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(errorText: _emailError),
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 24, 105, 172),
                    ),
                  ),
                ),
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSignIn,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Image.asset('assets/facebook.png',
                            width: 21, height: 24),
                    label: Text(
                      _isLoading ? "Signing In..." : "SIGN IN WITH FACEBOOK",
                      style: const TextStyle(fontSize: 15),
                    ),
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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