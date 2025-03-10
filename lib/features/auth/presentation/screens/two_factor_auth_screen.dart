// lib/features/auth/presentation/screens/two_factor_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../controller/auth_controller.dart';
import '../../../../config/theme.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({Key? key}) : super(key: key);

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isResending = false;
  int _resendTimer = 60;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendTimer > 0 && mounted) {
        setState(() {
          _resendTimer--;
        });
        startTimer();
      }
    });
  }

  void resendCode() {
    setState(() {
      _isResending = true;
      _resendTimer = 60;
    });
    
    // Call the resend OTP method
    _authController.resendOtp();
    
    setState(() {
      _isResending = false;
    });
    
    startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments['email'] ?? '';
    
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
                    'Two-Factor Authentication',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the verification code sent to your email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        email,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.grey[100],
                      selectedFillColor: Colors.white,
                      activeColor: AppTheme.primaryColor,
                      inactiveColor: Colors.grey[300],
                      selectedColor: AppTheme.primaryColor,
                    ),
                    cursorColor: AppTheme.primaryColor,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    onCompleted: (v) {
                      // Automatically verify when all digits entered
                      if (_formKey.currentState!.validate()) {
                        _authController.verifyOtp(_otpController.text);
                      }
                    },
                    onChanged: (value) {
                      // Handle on change
                    },
                  ),
                  const SizedBox(height: 40),
                  Obx(() => _authController.isLoading.value
                      ? const Center(child: LoadingIndicator())
                      : CustomButton(
                          text: 'Verify Code',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _authController.verifyOtp(_otpController.text);
                            }
                          },
                        )),
                  const SizedBox(height: 24),
                  Center(
                    child: _isResending
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _resendTimer > 0 ? null : resendCode,
                            child: Text(
                              _resendTimer > 0
                                  ? 'Resend code in $_resendTimer seconds'
                                  : 'Resend Code',
                              style: TextStyle(
                                color: _resendTimer > 0
                                    ? Colors.grey
                                    : AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
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