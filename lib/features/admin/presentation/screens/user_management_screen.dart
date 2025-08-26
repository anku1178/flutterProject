import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<User> _customers = [];
  List<User> _workers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading users
    await Future.delayed(const Duration(seconds: 1));

    _customers = [
      User(
        id: 'customer1',
        name: 'John Doe',
        email: 'john.doe@email.com',
        phone: '+1234567890',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      User(
        id: 'customer2',
        name: 'Jane Smith',
        email: 'jane.smith@email.com',
        phone: '+1234567891',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      User(
        id: 'customer3',
        name: 'Bob Johnson',
        email: 'bob.johnson@email.com',
        phone: '+1234567892',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      User(
        id: 'customer4',
        name: 'Alice Wilson',
        email: 'alice.wilson@email.com',
        phone: '+1234567893',
        role: UserRole.customer,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _workers = [
      User(
        id: 'worker1',
        name: 'Mike Chen',
        email: 'mike.chen@store.com',
        phone: '+1234567894',
        role: UserRole.worker,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'worker2',
        name: 'Sarah Davis',
        email: 'sarah.davis@store.com',
        phone: '+1234567895',
        role: UserRole.worker,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<User> _getFilteredUsers(List<User> users) {
    if (_searchController.text.isEmpty) {
      return users;
    }

    return users.where((user) {
      final query = _searchController.text.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Customers (${_customers.length})',
              icon: const Icon(Icons.people),
            ),
            Tab(
              text: 'Workers (${_workers.length})',
              icon: const Icon(Icons.work),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // User Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList(
                    _getFilteredUsers(_customers), UserRole.customer),
                _buildUsersList(_getFilteredUsers(_workers), UserRole.worker),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewUser,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildUsersList(List<User> users, UserRole role) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return _buildEmptyState(role);
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildEmptyState(UserRole role) {
    final isCustomer = role == UserRole.customer;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCustomer ? Icons.people_outlined : Icons.work_outline,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            isCustomer ? 'No customers found' : 'No workers found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : isCustomer
                    ? 'Customer accounts will appear here'
                    : 'Worker accounts will appear here',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 24),
            PrimaryButton(
              text: isCustomer ? 'Add Customer' : 'Add Worker',
              icon: Icons.person_add,
              onPressed: _addNewUser,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: _getRoleColor(user.role),
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: AppTextStyles.subtitle1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRoleText(user.role),
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.body2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Joined ${_formatDate(user.createdAt)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'View Details',
                    icon: Icons.info_outline,
                    onPressed: () => _viewUserDetails(user),
                    height: 36,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    text: 'Edit',
                    icon: Icons.edit,
                    onPressed: () => _editUser(user),
                    height: 36,
                  ),
                ),
                const SizedBox(width: 8),
                SecondaryButton(
                  text: 'Delete',
                  icon: Icons.delete,
                  onPressed: () => _deleteUser(user),
                  height: 36,
                  width: 80,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.primary;
      case UserRole.worker:
        return AppColors.accent;
      case UserRole.admin:
        return AppColors.error;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.worker:
        return Icons.work;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.worker:
        return 'Worker';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addNewUser() {
    _showUserDialog();
  }

  void _editUser(User user) {
    _showUserDialog(user: user);
  }

  void _showUserDialog({User? user}) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    UserRole selectedRole = user?.role ??
        (_tabController.index == 0 ? UserRole.customer : UserRole.worker);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit User' : 'Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [
                  DropdownMenuItem(
                    value: UserRole.customer,
                    child: Text('Customer'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.worker,
                    child: Text('Worker'),
                  ),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
                _saveUser(
                  user: user,
                  name: name,
                  email: email,
                  phone: phone,
                  role: selectedRole,
                );
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _saveUser({
    User? user,
    required String name,
    required String email,
    required String phone,
    required UserRole role,
  }) {
    setState(() {
      if (user != null) {
        // Edit existing user
        final updatedUser = User(
          id: user.id,
          name: name,
          email: email,
          phone: phone,
          role: role,
          createdAt: user.createdAt,
        );

        if (role == UserRole.customer) {
          final index = _customers.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            _customers[index] = updatedUser;
          }
          _workers.removeWhere((u) => u.id == user.id);
        } else {
          final index = _workers.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            _workers[index] = updatedUser;
          }
          _customers.removeWhere((u) => u.id == user.id);
        }
      } else {
        // Add new user
        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );

        if (role == UserRole.customer) {
          _customers.add(newUser);
        } else {
          _workers.add(newUser);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user != null
            ? 'User updated successfully'
            : 'User added successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _viewUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'User Details',
                style: AppTextStyles.heading3,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          _getRoleColor(user.role).withOpacity(0.1),
                      child: Icon(
                        _getRoleIcon(user.role),
                        color: _getRoleColor(user.role),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Name', user.name),
                    _buildDetailRow('Email', user.email),
                    _buildDetailRow('Phone', user.phone),
                    _buildDetailRow('Role', _getRoleText(user.role)),
                    _buildDetailRow(
                        'Member Since', _formatDate(user.createdAt)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: 'Edit User',
                            onPressed: () {
                              Navigator.pop(context);
                              _editUser(user);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.subtitle2,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customers.removeWhere((u) => u.id == user.id);
                _workers.removeWhere((u) => u.id == user.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
