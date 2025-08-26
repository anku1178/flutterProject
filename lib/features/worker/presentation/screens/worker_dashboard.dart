import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/order_providers.dart';
import '../../../../core/providers/auth_providers.dart';

class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final orderStats = ref.watch(orderStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(orderState, orderStats),
          _buildOrdersTab(orderState),
          _buildInventoryTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(orderState.newOrdersCount),
    );
  }

  Widget _buildDashboardTab(OrderState orderState, OrderStatistics stats) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(orderProvider.notifier).refreshOrders();
      },
      child: CustomScrollView(
        slivers: [
          // App Bar with real-time updates
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Worker Dashboard'),
                Text(
                  'Last updated: ${_formatTime(orderState.lastUpdate)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              badges.Badge(
                badgeContent: Text(
                  '${orderState.newOrdersCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                showBadge: orderState.newOrdersCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showNotifications(orderState),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Enhanced Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  Text(
                    'Hello, Worker!',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s what\'s happening today',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 24),

                  // Primary Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Pending Orders',
                          value: '${stats.pendingOrders}',
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                          trend: orderState.newOrdersCount > 0
                              ? '+${orderState.newOrdersCount}'
                              : null,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Completed Today',
                          value: '${stats.completedToday}',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Secondary Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Today Revenue',
                          value: '\$${stats.todayRevenue.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: AppColors.primary,
                          subtitle:
                              'Avg: \$${stats.averageOrderValue.toStringAsFixed(0)}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'New Orders',
                          value: '${orderState.newOrdersCount}',
                          icon: Icons.new_releases,
                          color: AppColors.accent,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                    ],
                  ),

                  // Loading indicator for real-time updates
                  if (orderState.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Updating...',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Recent Orders Section with real-time updates
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Orders',
                        style: AppTextStyles.heading3,
                      ),
                      Row(
                        children: [
                          if (orderState.newOrdersCount > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${orderState.newOrdersCount} new',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () => setState(() => _currentIndex = 1),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Recent Orders List with real-time data
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recentOrders = [
                  ...orderState.pendingOrders,
                  ...orderState.completedOrders
                ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (index >= recentOrders.length) return null;
                final order = recentOrders[index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: OrderCard(
                    order: order,
                    showStatusUpdate: order.status != OrderStatus.pickedUp,
                    onStatusUpdate: () => _updateOrderStatus(order),
                    onTap: () => _showOrderDetails(order),
                  ),
                );
              },
              childCount: (orderState.pendingOrders.length +
                      orderState.completedOrders.length)
                  .clamp(0, 3),
            ),
          ),

          // Quick Actions with enhanced functionality
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
                          text: 'Update Stock',
                          icon: Icons.add_box,
                          onPressed: () => setState(() => _currentIndex = 2),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: IconTextButton(
                          text: 'Check Orders',
                          icon: Icons.list_alt,
                          onPressed: () => setState(() => _currentIndex = 1),
                          backgroundColor: AppColors.accent,
                          textColor: AppColors.textPrimary,
                          iconColor: AppColors.textPrimary,
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
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Row(
                    children: [
                      if (trend != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            trend,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: color,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.caption,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTab(OrderState orderState) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          AppBar(
            title: const Text('Orders'),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Pending (${orderState.pendingOrders.length})'),
                Tab(text: 'Completed (${orderState.completedOrders.length})'),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(orderState.pendingOrders, showActions: true),
                _buildOrdersList(orderState.completedOrders,
                    showActions: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, {required bool showActions}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              showActions ? 'No pending orders' : 'No completed orders',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              showActions
                  ? 'New orders will appear here'
                  : 'Completed orders will appear here',
              style: AppTextStyles.body2,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(orderProvider.notifier).refreshOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              order: order,
              showStatusUpdate:
                  showActions && order.status != OrderStatus.pickedUp,
              onStatusUpdate: () => _updateOrderStatus(order),
              onTap: () => _showOrderDetails(order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Quick Inventory'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.inventory),
              onPressed: () => context.push('/worker/inventory'),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Low Stock',
                        value: '12',
                        icon: Icons.warning,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Out of Stock',
                        value: '3',
                        icon: Icons.error,
                        color: AppColors.error,
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
                        text: 'Update Stock',
                        icon: Icons.add_box,
                        onPressed: () => context.push('/worker/inventory'),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IconTextButton(
                        text: 'View All',
                        icon: Icons.list,
                        onPressed: () => context.push('/worker/inventory'),
                        backgroundColor: AppColors.accent,
                        textColor: AppColors.textPrimary,
                        iconColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Updates
                Text(
                  'Recent Stock Updates',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                ...List.generate(
                    5,
                    (index) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory,
                                  color: AppColors.textLight),
                            ),
                            title: Text('Product ${index + 1}'),
                            subtitle:
                                Text('Stock updated: ${20 + index * 5} items'),
                            trailing: Text(
                              '${index + 1}h ago',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Worker Profile'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.accent.withOpacity(0.1),
                          child: const Icon(
                            Icons.work,
                            size: 40,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mike Worker',
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'worker@demo.com',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Worker',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Work Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Performance',
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPerformanceItem(
                                'Orders Processed',
                                '12',
                                Icons.check_circle,
                                AppColors.success,
                              ),
                            ),
                            Expanded(
                              child: _buildPerformanceItem(
                                'Stock Updates',
                                '8',
                                Icons.inventory,
                                AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Options
                Card(
                  child: Column(
                    children: [
                      _buildProfileOption(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        onTap: () => context.push('/worker/profile'),
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.schedule,
                        title: 'Work Schedule',
                        subtitle: 'View your work hours',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Configure alerts',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out',
                        onTap: () => _showLogoutConfirmation(),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle1.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar(int newOrdersCount) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 1) {
            // Clear new orders count when viewing orders
            ref.read(orderProvider.notifier).clearNewOrdersCount();
          }
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: badges.Badge(
            badgeContent: Text(
              '$newOrdersCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: newOrdersCount > 0,
            child: const Icon(Icons.receipt_long_outlined),
          ),
          activeIcon: badges.Badge(
            badgeContent: Text(
              '$newOrdersCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: newOrdersCount > 0,
            child: const Icon(Icons.receipt_long),
          ),
          label: 'Orders',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          activeIcon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 30) {
      return 'just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showNotifications(OrderState orderState) {
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
                  if (orderState.newOrdersCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${orderState.newOrdersCount} new',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      ref.read(orderProvider.notifier).clearNewOrdersCount();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: orderState.newOrdersCount > 0
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: orderState.newOrdersCount,
                      itemBuilder: (context, index) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.new_releases,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          title: const Text('New Order Received'),
                          subtitle: Text(
                            'Order received at ${_formatTime(DateTime.now().subtract(Duration(minutes: index * 2)))}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'NEW',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 1);
                          },
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No new notifications',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'New order notifications will appear here',
                            style: AppTextStyles.body2,
                            textAlign: TextAlign.center,
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

  void _updateOrderStatus(Order order) {
    OrderStatus nextStatus;
    switch (order.status) {
      case OrderStatus.received:
        nextStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.completed;
        break;
      case OrderStatus.completed:
        nextStatus = OrderStatus.pickedUp;
        break;
      case OrderStatus.pickedUp:
        return; // Already completed
    }

    // Update through provider
    ref.read(orderProvider.notifier).updateOrderStatus(order.id, nextStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${_getStatusText(nextStatus)}'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 1),
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.completed:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
    }
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                'Order #${order.id}',
                style: AppTextStyles.heading3,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OrderCard(
                  order: order,
                  showStatusUpdate: order.status != OrderStatus.pickedUp,
                  onStatusUpdate: () {
                    _updateOrderStatus(order);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
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
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Logging out...'),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Clear authentication state
      await ref.read(authStateProvider.notifier).logout();
      await ref.read(currentUserProvider.notifier).clearUser();

      // Navigate to login screen
      if (mounted) {
        context.go('/login');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
