// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../controller/auth_controller.dart';
// Ensure AppTheme is correctly defined or import theme.dart if needed
import '../../../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  // Removed _obscureText state as CustomTextField handles it internally now

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/images/comet_logo.png', // Ensure this asset exists
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor, // Ensure AppTheme.primaryColor is defined
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue sharing with your community',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    // FIX: Added required 'label'
                    label: 'Email',
                    controller: _emailController,
                    // FIX: Changed 'hintText' to 'hint'
                    hint: 'Enter your email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Consider a more robust email regex if needed
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    // FIX: Added required 'label'
                    label: 'Password',
                    controller: _passwordController,
                    // FIX: Changed 'hintText' to 'hint'
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    // FIX: Removed suffixIcon - CustomTextField handles the toggle internally
                    // suffixIcon: IconButton(...) // REMOVED
                    // FIX: Pass obscureText: true to enable internal toggle
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password navigation/logic
                        Get.snackbar('TODO', 'Forgot Password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.primaryColor, // Ensure AppTheme.primaryColor is defined
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    // Ensure isLoading exists in AuthController
                    bool isLoading = _authController.isLoading.value;
                    return isLoading
                      ? const Center(child: LoadingIndicator())
                      : CustomButton(
                          text: 'Login',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Ensure login method exists in AuthController
                              _authController.login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                            }
                          },
                        );
                   }
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              color: AppTheme.primaryColor, // Ensure AppTheme.primaryColor is defined
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed('/register'); // Ensure route exists
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}