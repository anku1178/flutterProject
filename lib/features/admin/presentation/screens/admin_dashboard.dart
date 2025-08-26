import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildInventoryTab(),
          _buildAnalyticsTab(),
          _buildUsersTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.primary,
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotifications(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => setState(() => _currentIndex = 4),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Welcome Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s what\'s happening in your store today',
                  style: AppTextStyles.body2,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Key Metrics
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Total Sales',
                        value: '\$2,847',
                        subtitle: '+12% from yesterday',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Orders Today',
                        value: '24',
                        subtitle: '+3 from yesterday',
                        icon: Icons.shopping_cart,
                        color: AppColors.primary,
                        onTap: () => context.push('/admin/analytics'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Active Products',
                        value: '156',
                        subtitle: '12 low stock alerts',
                        icon: Icons.inventory,
                        color: AppColors.warning,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Total Users',
                        value: '89',
                        subtitle: '5 new this week',
                        icon: Icons.people,
                        color: AppColors.info,
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Sales Chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sales Overview',
                          style: AppTextStyles.subtitle1,
                        ),
                        TextButton(
                          onPressed: () => setState(() => _currentIndex = 2),
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(_buildSalesChart()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Recent Activity
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Activity List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final activities = [
                'New order #ORD123 - \$45.99',
                'Product "Wireless Headphones" stock updated',
                'New customer registration - John Doe',
                'Order #ORD122 completed',
                'Low stock alert - Fresh Apples (5 remaining)',
              ];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getActivityIcon(index),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(activities[index]),
                    subtitle: Text('${index + 1} minutes ago'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            },
            childCount: 5,
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: IconTextButton(
                        text: 'Add Product',
                        icon: Icons.add_box,
                        onPressed: () => setState(() => _currentIndex = 1),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IconTextButton(
                        text: 'Import Excel',
                        icon: Icons.upload_file,
                        onPressed: () => context.push('/admin/import'),
                        backgroundColor: AppColors.accent,
                        textColor: AppColors.textPrimary,
                        iconColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: IconTextButton(
                        text: 'View Analytics',
                        icon: Icons.analytics,
                        onPressed: () => setState(() => _currentIndex = 2),
                        backgroundColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IconTextButton(
                        text: 'Manage Users',
                        icon: Icons.people,
                        onPressed: () => setState(() => _currentIndex = 3),
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildInventoryTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Inventory Overview'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/admin/inventory'),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inventory Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Total Products',
                        value: '156',
                        subtitle: '+12 this week',
                        icon: Icons.inventory,
                        color: AppColors.primary,
                        onTap: () => context.push('/admin/inventory'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Low Stock Alerts',
                        value: '12',
                        subtitle: 'Needs attention',
                        icon: Icons.warning,
                        color: AppColors.warning,
                        onTap: () => context.push('/admin/inventory'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Out of Stock',
                        value: '3',
                        subtitle: 'Immediate action',
                        icon: Icons.error,
                        color: AppColors.error,
                        onTap: () => context.push('/admin/inventory'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Total Value',
                        value: '\$15.2K',
                        subtitle: '+8% from last month',
                        icon: Icons.attach_money,
                        color: AppColors.success,
                        onTap: () => context.push('/admin/inventory'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: IconTextButton(
                        text: 'Add Product',
                        icon: Icons.add_box,
                        onPressed: () => context.push('/admin/inventory'),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IconTextButton(
                        text: 'Import Excel',
                        icon: Icons.upload_file,
                        onPressed: () => context.push('/admin/import'),
                        backgroundColor: AppColors.accent,
                        textColor: AppColors.textPrimary,
                        iconColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Inventory Activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Inventory Activity',
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                            6,
                            (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _getActivityColor(index)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Icon(
                                          _getActivityIcon(index),
                                          color: _getActivityColor(index),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getActivityTitle(index),
                                              style: AppTextStyles.body2,
                                            ),
                                            Text(
                                              '${index + 1} minutes ago',
                                              style: AppTextStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                        const SizedBox(height: 8),
                        Center(
                          child: SecondaryButton(
                            text: 'View Full Inventory',
                            onPressed: () => context.push('/admin/inventory'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Analytics'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Row(
                  children: [
                    Text(
                      'Analytics Overview',
                      style: AppTextStyles.heading3,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Text('Last 7 days'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Key Metrics Row 1
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Revenue',
                        value: '\$12.5K',
                        subtitle: '+15% from last week',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                        onTap: () => context.push('/admin/analytics'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Orders',
                        value: '89',
                        subtitle: '+8% from last week',
                        icon: Icons.shopping_cart,
                        color: AppColors.primary,
                        onTap: () => context.push('/admin/analytics'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Key Metrics Row 2
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Customers',
                        value: '56',
                        subtitle: '12 new this week',
                        icon: Icons.people,
                        color: AppColors.info,
                        onTap: () => context.push('/admin/analytics'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Avg Order',
                        value: '\$140',
                        subtitle: '+5% from last week',
                        icon: Icons.bar_chart,
                        color: AppColors.accent,
                        onTap: () => context.push('/admin/analytics'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mini Sales Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sales Trend',
                              style: AppTextStyles.subtitle1,
                            ),
                            SecondaryButton(
                              text: 'View Details',
                              onPressed: () => context.push('/admin/analytics'),
                              height: 32,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sales trending up 📈',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Products
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Selling Products',
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                            5,
                            (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: index < 3
                                              ? AppColors.accent
                                                  .withOpacity(0.1)
                                              : AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: index < 3
                                                  ? AppColors.accent
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.image,
                                            color: AppColors.textLight,
                                            size: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Product ${index + 1}',
                                              style: AppTextStyles.body2,
                                            ),
                                            Text(
                                              '${25 - index * 3} sold this week',
                                              style: AppTextStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${((index + 1) * 99.99).toStringAsFixed(0)}',
                                        style: AppTextStyles.price
                                            .copyWith(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return const Center(
      child: Text('User Management - Coming Soon'),
    );
  }

  Widget _buildSettingsTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Settings'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.store),
                        title: const Text('Store Settings'),
                        subtitle: const Text('Manage store information'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        subtitle: const Text('Configure notification settings'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security),
                        title: const Text('Security'),
                        subtitle: const Text('Password and security settings'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.backup),
                        title: const Text('Backup & Restore'),
                        subtitle: const Text('Manage data backups'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        subtitle: const Text('Get help and contact support'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About'),
                        subtitle: const Text('App version and information'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text('Logout',
                        style: TextStyle(color: AppColors.error)),
                    onTap: () => _logout(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          activeIcon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  LineChartData _buildSalesChart() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            const FlSpot(0, 3),
            const FlSpot(1, 1),
            const FlSpot(2, 4),
            const FlSpot(3, 2),
            const FlSpot(4, 5),
            const FlSpot(5, 3),
            const FlSpot(6, 4),
          ],
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(int index) {
    switch (index % 5) {
      case 0:
        return Icons.shopping_cart;
      case 1:
        return Icons.inventory;
      case 2:
        return Icons.person_add;
      case 3:
        return Icons.check_circle;
      case 4:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(int index) {
    switch (index % 5) {
      case 0:
        return AppColors.success;
      case 1:
        return AppColors.info;
      case 2:
        return AppColors.primary;
      case 3:
        return AppColors.success;
      case 4:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getActivityTitle(int index) {
    switch (index % 5) {
      case 0:
        return 'New order received - #ORD${100 + index}';
      case 1:
        return 'Product stock updated - Wireless Headphones';
      case 2:
        return 'New customer registered - John Doe';
      case 3:
        return 'Order completed - #ORD${95 + index}';
      case 4:
        return 'Low stock alert - Fresh Apples';
      default:
        return 'System update';
    }
  }

  void _showNotifications() {
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
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: AppTextStyles.heading3,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('No new notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
