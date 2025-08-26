import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order _order;
  bool _isLoading = true;

  final List<TrackingStep> _trackingSteps = [
    TrackingStep(
      status: OrderStatus.received,
      title: 'Order Received',
      description: 'Your order has been received and is being processed',
      icon: Icons.receipt_long,
    ),
    TrackingStep(
      status: OrderStatus.preparing,
      title: 'Preparing Order',
      description: 'Your items are being prepared by our team',
      icon: Icons.inventory,
    ),
    TrackingStep(
      status: OrderStatus.completed,
      title: 'Ready for Pickup',
      description: 'Your order is ready! Come and collect it',
      icon: Icons.check_circle,
    ),
    TrackingStep(
      status: OrderStatus.pickedUp,
      title: 'Order Completed',
      description: 'Thank you for shopping with us!',
      icon: Icons.handshake,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    // Simulate loading order data
    await Future.delayed(const Duration(seconds: 1));

    _order = Order(
      id: widget.orderId,
      customerId: 'customer123',
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
          quantity: 3,
        ),
      ],
      totalAmount: 144.96,
      status: OrderStatus.preparing, // Current status
      paymentMethod: PaymentMethod.online,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      notes: 'Please handle electronics with care',
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${widget.orderId.substring(3, 11)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              _buildOrderStatusCard(),
              const SizedBox(height: 24),

              // Tracking Timeline
              _buildTrackingTimeline(),
              const SizedBox(height: 24),

              // Order Details
              _buildOrderDetailsCard(),
              const SizedBox(height: 24),

              // Store Information
              _buildStoreInfoCard(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getStatusColor(_order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getStatusIcon(_order.status),
                size: 40,
                color: _getStatusColor(_order.status),
              ),
            ),
            const SizedBox(height: 16),

            // Status Text
            Text(
              _getStatusTitle(_order.status),
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(_order.status),
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Estimated Time
            if (_order.status != OrderStatus.pickedUp)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getEstimatedTime(_order.status),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Progress',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 20),

            // Timeline
            Column(
              children: _trackingSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isCompleted = _order.status.index >= step.status.index;
                final isCurrent = _order.status == step.status;

                return TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  isFirst: index == 0,
                  isLast: index == _trackingSteps.length - 1,
                  indicatorStyle: IndicatorStyle(
                    width: 40,
                    color:
                        isCompleted ? AppColors.primary : AppColors.textLight,
                    iconStyle: IconStyle(
                      iconData: step.icon,
                      color: isCompleted ? Colors.white : AppColors.textLight,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color:
                        isCompleted ? AppColors.primary : AppColors.textLight,
                    thickness: 2,
                  ),
                  endChild: Container(
                    padding: const EdgeInsets.only(left: 16, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w500,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.description,
                          style: AppTextStyles.caption.copyWith(
                            color: isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textLight,
                          ),
                        ),
                        if (isCurrent && _order.updatedAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Updated ${_formatTime(_order.updatedAt!)}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 16),

            // Order Items
            ...(_order.items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: AppTextStyles.body2,
                                ),
                                Text(
                                  'Qty: ${item.quantity} × \$${item.product.price.toStringAsFixed(2)}',
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
                    ))
                .toList()),

            const Divider(),

            // Order Summary
            _buildSummaryRow('Total Amount', _order.totalAmount, isTotal: true),
            const SizedBox(height: 8),
            _buildSummaryRow(
                'Payment Method',
                _order.paymentMethod == PaymentMethod.online
                    ? 'Online Payment'
                    : 'Cash on Pickup'),
            if (_order.notes != null && _order.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Notes', _order.notes!),
            ],
            _buildSummaryRow('Order Date', _formatDateTime(_order.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value, {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: isTotal
                ? AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.caption,
          ),
        ),
        Expanded(
          child: Text(
            value is double
                ? '\$${value.toStringAsFixed(2)}'
                : value.toString(),
            style: isTotal ? AppTextStyles.price : AppTextStyles.body2,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pickup Location',
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'General Store',
              style:
                  AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('123 Main Street, Downtown'),
            const Text('Phone: (555) 123-4567'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Call Store',
                    icon: Icons.phone,
                    onPressed: _callStore,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    text: 'Get Directions',
                    icon: Icons.directions,
                    onPressed: _getDirections,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_order.status == OrderStatus.completed)
          PrimaryButton(
            text: 'I\'ve Picked Up My Order',
            icon: Icons.check,
            onPressed: _confirmPickup,
            width: double.infinity,
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Need Help?',
                icon: Icons.help_outline,
                onPressed: _getHelp,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                text: 'Reorder',
                icon: Icons.refresh,
                onPressed: _reorder,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.warning;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.pickedUp:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return Icons.receipt_long;
      case OrderStatus.preparing:
        return Icons.inventory;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.pickedUp:
        return Icons.handshake;
    }
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing Your Order';
      case OrderStatus.completed:
        return 'Ready for Pickup!';
      case OrderStatus.pickedUp:
        return 'Order Completed';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'We\'ve received your order and will start preparing it soon.';
      case OrderStatus.preparing:
        return 'Your items are being carefully prepared by our team.';
      case OrderStatus.completed:
        return 'Your order is ready! Please come to the store to collect it.';
      case OrderStatus.pickedUp:
        return 'Thank you for shopping with us! We hope to see you again soon.';
    }
  }

  String _getEstimatedTime(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Estimated preparation: 15-30 minutes';
      case OrderStatus.preparing:
        return 'Ready in approximately 10-15 minutes';
      case OrderStatus.completed:
        return 'Ready now - Store closes at 8:00 PM';
      case OrderStatus.pickedUp:
        return '';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareOrder() {
    // Implement order sharing
  }

  void _callStore() {
    // Implement calling store
  }

  void _getDirections() {
    // Implement getting directions
  }

  void _confirmPickup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text('Have you collected your order from the store?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _order = _order.copyWith(status: OrderStatus.pickedUp);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Order marked as completed.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _getHelp() {
    // Implement help/support
  }

  void _reorder() {
    // Implement reordering
    context.push('/customer/products');
  }
}

class TrackingStep {
  final OrderStatus status;
  final String title;
  final String description;
  final IconData icon;

  TrackingStep({
    required this.status,
    required this.title,
    required this.description,
    required this.icon,
  });
}
