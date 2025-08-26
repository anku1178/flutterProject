import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({super.key});

  @override
  State<LiveOrdersScreen> createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Received',
    'Preparing',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading orders
    await Future.delayed(const Duration(seconds: 1));

    _orders = [
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

    setState(() {
      _isLoading = false;
    });
  }

  List<Order> get _filteredOrders {
    if (_selectedFilter == 'All') {
      return _orders;
    }

    OrderStatus? filterStatus;
    switch (_selectedFilter) {
      case 'Received':
        filterStatus = OrderStatus.received;
        break;
      case 'Preparing':
        filterStatus = OrderStatus.preparing;
        break;
      case 'Completed':
        filterStatus = OrderStatus.completed;
        break;
    }

    return _orders.where((order) => order.status == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = filter == _selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No orders found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when customers place them',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SecondaryButton(
            text: 'Refresh',
            icon: Icons.refresh,
            onPressed: _loadOrders,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              order: order,
              showStatusUpdate: order.status != OrderStatus.pickedUp,
              onStatusUpdate: () => _updateOrderStatus(order),
              onTap: () => _showOrderDetails(order),
            ),
          );
        },
      ),
    );
  }

  void _updateOrderStatus(Order order) {
    OrderStatus nextStatus;
    String actionText;

    switch (order.status) {
      case OrderStatus.received:
        nextStatus = OrderStatus.preparing;
        actionText = 'started preparing';
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.completed;
        actionText = 'marked as ready';
        break;
      case OrderStatus.completed:
        nextStatus = OrderStatus.pickedUp;
        actionText = 'marked as picked up';
        break;
      case OrderStatus.pickedUp:
        return; // Already completed
    }

    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order.copyWith(
          status: nextStatus,
          updatedAt: DateTime.now(),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${order.id} $actionText'),
        backgroundColor: AppColors.success,
      ),
    );
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
              child: Row(
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppTextStyles.heading3,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Information',
                              style: AppTextStyles.subtitle1,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Customer ID', order.customerId),
                            _buildInfoRow('Total Amount',
                                '\$${order.totalAmount.toStringAsFixed(2)}'),
                            _buildInfoRow(
                                'Payment Method',
                                order.paymentMethod == PaymentMethod.online
                                    ? 'Online Payment'
                                    : 'Cash on Pickup'),
                            _buildInfoRow(
                                'Order Time', _formatDateTime(order.createdAt)),
                            if (order.notes != null && order.notes!.isNotEmpty)
                              _buildInfoRow('Notes', order.notes!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items (${order.items.length})',
                              style: AppTextStyles.subtitle1,
                            ),
                            const SizedBox(height: 12),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.image,
                                          color: AppColors.textLight,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: AppTextStyles.body2,
                                            ),
                                            Text(
                                              'Qty: ${item.quantity}',
                                              style: AppTextStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\$${item.totalPrice.toStringAsFixed(2)}',
                                        style: AppTextStyles.subtitle2,
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Button
                    if (order.status != OrderStatus.pickedUp)
                      PrimaryButton(
                        text: _getActionButtonText(order.status),
                        onPressed: () {
                          _updateOrderStatus(order);
                          Navigator.pop(context);
                        },
                        width: double.infinity,
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.caption,
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

  String _getActionButtonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Start Preparing';
      case OrderStatus.preparing:
        return 'Mark as Ready';
      case OrderStatus.completed:
        return 'Mark as Picked Up';
      case OrderStatus.pickedUp:
        return 'Completed';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
