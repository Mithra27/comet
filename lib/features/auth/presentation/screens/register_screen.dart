// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../controller/auth_controller.dart';
// Ensure AppTheme is correctly defined or import theme.dart if needed
import '../../../../config/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  // Removed _obscureText state variables as CustomTextField handles them
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _apartmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor, // Ensure AppTheme.primaryColor is defined
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join your community sharing platform',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    // FIX: Added required 'label'
                    label: 'Full Name',
                    controller: _nameController,
                    // FIX: Changed 'hintText' to 'hint'
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    // FIX: Added required 'label'
                    label: 'Phone Number',
                    controller: _phoneController,
                    // FIX: Changed 'hintText' to 'hint'
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Add more specific phone validation if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    // FIX: Added required 'label'
                    label: 'Apartment/Flat Number',
                    controller: _apartmentController,
                    // FIX: Changed 'hintText' to 'hint'
                    hint: 'Enter your apartment or flat number',
                    prefixIcon: Icons.home_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your apartment/flat number';
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
                    hint: 'Create a password (min. 8 characters)',
                    prefixIcon: Icons.lock_outline,
                    // FIX: Removed suffixIcon - handled internally
                    // suffixIcon: IconButton(...) // REMOVED
                    // FIX: Pass obscureText: true
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                     // FIX: Added required 'label'
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    // FIX: Changed 'hintText' to 'hint'
                    hint: 'Re-enter your password',
                    prefixIcon: Icons.lock_outline,
                    // FIX: Removed suffixIcon - handled internally
                    // suffixIcon: IconButton(...) // REMOVED
                    // FIX: Pass obscureText: true
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        activeColor: AppTheme.primaryColor, // Ensure defined
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(color: Colors.grey[700]),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppTheme.primaryColor, // Ensure defined
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: Navigate to Terms of Service
                                    Get.snackbar('TODO', 'Navigate to Terms');
                                  },
                              ),
                              const TextSpan( text: ' and ', ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppTheme.primaryColor, // Ensure defined
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                     // TODO: Navigate to Privacy Policy
                                     Get.snackbar('TODO', 'Navigate to Privacy');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                     // Ensure isLoading exists in AuthController
                     bool isLoading = _authController.isLoading.value;
                     return isLoading
                      ? const Center(child: LoadingIndicator())
                      : CustomButton(
                          text: 'Register',
                          onPressed: () {
                            if (!_agreeToTerms) {
                              Get.snackbar(
                                'Agreement Required',
                                'Please agree to the Terms of Service and Privacy Policy',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange[800],
                                colorText: Colors.white,
                              );
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              // Ensure register method exists in AuthController
                              _authController.register(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                phone: _phoneController.text.trim(),
                                apartment: _apartmentController.text.trim(),
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
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppTheme.primaryColor, // Ensure defined
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.back();
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