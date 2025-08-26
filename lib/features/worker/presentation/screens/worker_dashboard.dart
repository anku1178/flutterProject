import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _currentIndex = 0;
  List<Order> _pendingOrders = [];
  List<Order> _completedOrders = [];
  int _newOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _simulateNewOrders();
  }

  void _loadOrders() {
    // Simulate loading orders
    _pendingOrders = [
      Order(
        id: 'ORD001',
        customerId: 'customer1',
        items: [
          CartItem(
            product: Product(
              id: '1',
              name: 'Wireless Headphones',
              description: 'High-quality wireless headphones',
              price: 129.99,
              stock: 15,
              category: 'Electronics',
              imageUrl: 'https://via.placeholder.com/100x100?text=Headphones',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            quantity: 1,
          ),
        ],
        totalAmount: 129.99,
        status: OrderStatus.received,
        paymentMethod: PaymentMethod.online,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Order(
        id: 'ORD002',
        customerId: 'customer2',
        items: [
          CartItem(
            product: Product(
              id: '2',
              name: 'Fresh Apples',
              description: 'Organic red apples',
              price: 4.99,
              stock: 50,
              category: 'Groceries',
              imageUrl: 'https://via.placeholder.com/100x100?text=Apples',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            quantity: 5,
          ),
        ],
        totalAmount: 24.95,
        status: OrderStatus.preparing,
        paymentMethod: PaymentMethod.cashOnPickup,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    _completedOrders = [
      Order(
        id: 'ORD003',
        customerId: 'customer3',
        items: [
          CartItem(
            product: Product(
              id: '3',
              name: 'Cotton T-Shirt',
              description: 'Comfortable cotton t-shirt',
              price: 19.99,
              stock: 30,
              category: 'Clothing',
              imageUrl: 'https://via.placeholder.com/100x100?text=T-Shirt',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            quantity: 2,
          ),
        ],
        totalAmount: 39.98,
        status: OrderStatus.completed,
        paymentMethod: PaymentMethod.online,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void _simulateNewOrders() {
    // Simulate receiving new orders every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _newOrdersCount++;
        });
        _simulateNewOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildOrdersTab(),
          _buildInventoryTab(),
          _buildProfileTab(),
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
          title: const Text('Worker Dashboard'),
          actions: [
            badges.Badge(
              badgeContent: Text(
                '$_newOrdersCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge: _newOrdersCount > 0,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotifications(),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Quick Stats
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

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pending Orders',
                        value: '${_pendingOrders.length}',
                        icon: Icons.pending_actions,
                        color: AppColors.warning,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Completed Today',
                        value: '${_completedOrders.length}',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'New Orders',
                        value: '$_newOrdersCount',
                        icon: Icons.new_releases,
                        color: AppColors.accent,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Inventory Check',
                        value: 'Due',
                        icon: Icons.inventory,
                        color: AppColors.info,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Recent Orders Section
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
                    TextButton(
                      onPressed: () => setState(() => _currentIndex = 1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Recent Orders List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final order = index < _pendingOrders.length
                  ? _pendingOrders[index]
                  : _completedOrders[index - _pendingOrders.length];

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
            childCount:
                (_pendingOrders.length + _completedOrders.length).clamp(0, 3),
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
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          AppBar(
            title: const Text('Orders'),
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(_pendingOrders, showActions: true),
                _buildOrdersList(_completedOrders, showActions: false),
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
        _loadOrders();
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
                        onTap: () {},
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
                        onTap: () => context.go('/login'),
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 1) {
            _newOrdersCount = 0; // Reset new orders count when viewing orders
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
              '$_newOrdersCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: _newOrdersCount > 0,
            child: const Icon(Icons.receipt_long_outlined),
          ),
          activeIcon: badges.Badge(
            badgeContent: Text(
              '$_newOrdersCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: _newOrdersCount > 0,
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
                    onPressed: () {
                      setState(() {
                        _newOrdersCount = 0;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _newOrdersCount > 0
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _newOrdersCount,
                      itemBuilder: (context, index) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.new_releases,
                              color: AppColors.accent),
                          title: Text('New Order Received'),
                          subtitle: Text(
                              'Order #${DateTime.now().millisecondsSinceEpoch + index}'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 1);
                          },
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No new notifications'),
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

    setState(() {
      final index = _pendingOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _pendingOrders[index] = order.copyWith(
          status: nextStatus,
          updatedAt: DateTime.now(),
        );

        if (nextStatus == OrderStatus.pickedUp) {
          _completedOrders.add(_pendingOrders.removeAt(index));
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${_getStatusText(nextStatus)}'),
        backgroundColor: AppColors.success,
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
}
