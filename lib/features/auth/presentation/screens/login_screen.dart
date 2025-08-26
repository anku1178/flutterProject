import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passkeyController = TextEditingController();
  bool _obscurePasskey = true;
  bool _isLoading = false;
  LoginMode _loginMode = LoginMode.customerOtp;

  // Private access codes
  static const String _workerAccessCode = 'worker123';
  static const String _adminAccessCode = 'admin123';

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passkeyController.dispose();
    super.dispose();
  }

  Future<void> _customerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();

    // Navigate to OTP verification screen
    if (mounted) {
      context.push(
        '/otp-verification',
        extra: {
          'phoneNumber': phoneNumber,
          'selectedLanguages': <String>[], // Not needed for login
          'isRegistration': false,
        },
      );
    }
  }

  Future<void> _adminWorkerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final passkey = _passkeyController.text.trim();

    UserRole role = UserRole.customer;
    String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    String userName = name;

    // Check for private access codes
    if (passkey == _adminAccessCode) {
      role = UserRole.admin;
      userId = 'admin_${DateTime.now().millisecondsSinceEpoch}';
      userName = name.isEmpty ? 'Admin User' : name;
    } else if (passkey == _workerAccessCode) {
      role = UserRole.worker;
      userId = 'worker_${DateTime.now().millisecondsSinceEpoch}';
      userName = name.isEmpty ? 'Worker User' : name;
    } else {
      // Invalid passkey
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid passkey. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Create user object
    final user = User(
      id: userId,
      name: userName,
      email: '', // Not required for admin/worker
      phone: '', // Not required for admin/worker
      role: role,
      createdAt: DateTime.now(),
    );

    // Use the authentication provider to login
    final authNotifier = ref.read(authStateProvider.notifier);
    final userNotifier = ref.read(currentUserProvider.notifier);

    await authNotifier.login(user);
    await userNotifier.setUser(user);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to respective dashboard
      switch (role) {
        case UserRole.customer:
          context.go('/customer');
          break;
        case UserRole.worker:
          context.go('/worker');
          break;
        case UserRole.admin:
          context.go('/admin');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo and Welcome Text
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
                        Icons.storefront,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back!',
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access General Store',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Login Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _LoginModeButton(
                          mode: LoginMode.customerOtp,
                          selectedMode: _loginMode,
                          onTap: (mode) => setState(() => _loginMode = mode),
                          icon: Icons.phone_android,
                          label: 'Customer',
                        ),
                      ),
                      Expanded(
                        child: _LoginModeButton(
                          mode: LoginMode.adminWorker,
                          selectedMode: _loginMode,
                          onTap: (mode) => setState(() => _loginMode = mode),
                          icon: Icons.admin_panel_settings,
                          label: 'Admin/Worker',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Customer OTP Login
                if (_loginMode == LoginMode.customerOtp) ...[
                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Basic Indian phone number validation
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        return 'Please enter a valid Indian phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Get OTP Button
                  PrimaryButton(
                    text: 'Get OTP',
                    onPressed: _customerLogin,
                  ),
                  const SizedBox(height: 16),

                  // Registration Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: Text(
                          'Register',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] 
                // Admin/Worker Passkey Login
                else ...[
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Passkey Field
                  TextFormField(
                    controller: _passkeyController,
                    obscureText: _obscurePasskey,
                    decoration: InputDecoration(
                      labelText: 'Passkey',
                      hintText: 'Enter your passkey',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasskey
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePasskey = !_obscurePasskey;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your passkey';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  PrimaryButton(
                    text: 'Login',
                    onPressed: _adminWorkerLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Demo Passkey Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Passkeys:',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Admin: admin123\nWorker: worker123',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
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

// Login mode enum
enum LoginMode { customerOtp, adminWorker }

// Login mode button widget
class _LoginModeButton extends StatelessWidget {
  final LoginMode mode;
  final LoginMode selectedMode;
  final Function(LoginMode) onTap;
  final IconData icon;
  final String label;

  const _LoginModeButton({
    required this.mode,
    required this.selectedMode,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == selectedMode;
    return GestureDetector(
      onTap: () => onTap(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}