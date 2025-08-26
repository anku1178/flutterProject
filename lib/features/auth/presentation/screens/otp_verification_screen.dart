import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/services/storage_service.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String name;
  final String phoneNumber;
  final String selectedLanguage;
  final bool isRegistration;

  const OtpVerificationScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.selectedLanguage,
    required this.isRegistration,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String _generatedOtp = '123456'; // Demo OTP
  int _resendAttempts = 0;
  bool _canResend = true;
  bool _otpVerified = false;
  bool _hasShownDemoInfo = false;

  @override
  void initState() {
    super.initState();
    _generateOtp(); // In a real app, this would send an SMS
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show demo info after the widget is fully built
    if (!_hasShownDemoInfo) {
      _hasShownDemoInfo = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo mode: Use OTP 123456'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _generateOtp() {
    // In a real implementation, this would send an SMS
    // For now, we're using a hardcoded demo OTP
    setState(() {
      _generatedOtp = '123456';
    });
  }

  Future<void> _resendOtp() async {
    if (_resendAttempts >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum resend attempts reached'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _resendAttempts++;
      _canResend = false;
      _otpVerified = false; // Reset verification status
    });

    _generateOtp();

    // Re-enable resend after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    // Simulate verification process
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (_otpController.text.trim() == _generatedOtp) {
      // OTP is correct
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpVerified = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createAccount() async {
    if (!_otpVerified) return;

    setState(() {
      _isLoading = true;
    });

    // Create user and login
    final user = User(
      id: 'customer_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.name.isEmpty ? 'Customer User' : widget.name,
      email: '', // Not required for OTP login
      phone: widget.phoneNumber,
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );

    // Use the authentication provider to login
    final authNotifier = ref.read(authStateProvider.notifier);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final storageService = ref.read(storageServiceProvider);

    await authNotifier.login(user);
    await userNotifier.setUser(user);

    // Save selected language
    if (widget.selectedLanguage.isNotEmpty) {
      await storageService.setLanguage(widget.selectedLanguage);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to customer dashboard
      context.go('/customer');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isRegistration ? 'Create Account' : 'Login'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.sms_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.isRegistration ? 'Verify Your Phone' : 'Login with OTP',
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 6-digit code to ${widget.phoneNumber}',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.isRegistration && widget.name.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Name: ${widget.name}',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (widget.selectedLanguage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Language: ${widget.selectedLanguage}',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // OTP Input Field
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  enabled: !_otpVerified, // Disable after verification
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    hintText: 'Enter 6-digit code',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Action Buttons
                if (!_otpVerified) ...[
                  // Verify OTP Button
                  PrimaryButton(
                    text: 'Verify OTP',
                    onPressed: _verifyOtp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Resend OTP Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _canResend ? _resendOtp : null,
                        child: Text(
                          'Resend OTP',
                          style: AppTextStyles.body2.copyWith(
                            color: _canResend ? AppColors.primary : AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Create Account Button (only shown after OTP verification)
                  PrimaryButton(
                    text: widget.isRegistration ? 'Create Account' : 'Login',
                    onPressed: _createAccount,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Resend OTP Button (in case user wants to restart)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Wrong number?',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _canResend ? _resendOtp : null,
                        child: Text(
                          'Resend OTP',
                          style: AppTextStyles.body2.copyWith(
                            color: _canResend ? AppColors.primary : AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Registration info
                if (widget.isRegistration) ...[
                  const SizedBox(height: 16),
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}