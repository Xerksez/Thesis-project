import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;

  const LoginForm({super.key, required this.onLogin, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Email TextField
        _buildStyledTextField(
          controller: emailController,
          labelText: 'Email',
          enabled: !isLoading, // Disable input while loading
        ),
        const SizedBox(height: 16),

        // Password TextField
        _buildStyledTextField(
          controller: passwordController,
          labelText: 'Password',
          obscureText: true,
          enabled: !isLoading, // Disable input while loading
        ),
        const SizedBox(height: 32),

        // Login Button or Loading Indicator
        isLoading
            ? const CircularProgressIndicator() // Show loading indicator if request is ongoing
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  foregroundColor: Colors.white, // White text color
                  side: const BorderSide(color: Colors.white), // White border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // More rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  if (email.isNotEmpty && password.isNotEmpty) {
                    onLogin(email, password);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Both fields are required')),
                    );
                  }
                },
                child: const Text('Log in'),
              ),
        const SizedBox(height: 16),

        // Don't have an account? Register
        TextButton(
          onPressed: isLoading
              ? null // Disable button during loading
              : () {
                  Navigator.pushNamed(context, '/register');
                },
          child: const Text(
            'Dont have an account? Register',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Reusable method for styled text field creation
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true, // Control if the field is enabled or not
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled, // Disable interaction if loading
      style: const TextStyle(color: Colors.white), // White text color
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white54), // Label text style
        fillColor: Colors.transparent, // Fully transparent background
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54), // Light white border when enabled
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white), // Solid white border when focused
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
        ),
      ),
    );
  }
}
