import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/auth_providers.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  ConsumerState<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends ConsumerState<WorkerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _workerIdController;
  late TextEditingController _roleController;
  late TextEditingController _assignedAreaController;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _jobTypes = ['Delivery', 'Support', 'Inventory', 'Customer Service'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _workerIdController = TextEditingController();
    _roleController = TextEditingController();
    _assignedAreaController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _workerIdController.dispose();
    _roleController.dispose();
    _assignedAreaController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // In a real app, this would save to a backend
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Worker Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Worker User',
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.phone ?? 'No phone number',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Worker',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Worker Information',
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: 16),
                        
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
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

                        // Phone Number Field
                        TextFormField(
                          controller: _phoneController,
                          enabled: _isEditing,
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
                        const SizedBox(height: 16),

                        // Worker ID Field
                        TextFormField(
                          controller: _workerIdController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'Worker ID',
                            hintText: 'Enter your worker ID',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your worker ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Role/Job Type
                        Text(
                          'Role/Job Type',
                          style: AppTextStyles.subtitle2,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isEditing 
                                ? AppColors.borderColor 
                                : Colors.transparent,
                            ),
                          ),
                          child: _isEditing
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _jobTypes.map((role) {
                                    return RadioListTile<String>(
                                      title: Text(
                                        role,
                                        style: AppTextStyles.body1,
                                      ),
                                      value: role,
                                      groupValue: _roleController.text,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _roleController.text = value ?? '';
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  }).toList(),
                                )
                              : Row(
                                  children: [
                                    Text(
                                      _roleController.text.isEmpty 
                                        ? 'Not selected' 
                                        : _roleController.text,
                                      style: AppTextStyles.body1,
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Assigned Area/Zone Field
                        TextFormField(
                          controller: _assignedAreaController,
                          enabled: _isEditing,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Area/Zone',
                            hintText: 'Enter your assigned area or zone',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your assigned area';
                            }
                            if (value.length < 3) {
                              return 'Please enter a valid area';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (_isEditing) ...[
                  PrimaryButton(
                    text: 'Save Profile',
                    onPressed: _saveProfile,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
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