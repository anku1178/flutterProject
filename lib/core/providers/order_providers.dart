import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'auth_providers.dart';

// Real-time order state
class OrderState {
  final List<Order> pendingOrders;
  final List<Order> completedOrders;
  final List<Order> allOrders;
  final int newOrdersCount;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdate;
  final Map<String, int> categoryStats;
  final double todayRevenue;

  const OrderState({
    this.pendingOrders = const [],
    this.completedOrders = const [],
    this.allOrders = const [],
    this.newOrdersCount = 0,
    this.isLoading = false,
    this.error,
    required this.lastUpdate,
    this.categoryStats = const {},
    this.todayRevenue = 0.0,
  });

  OrderState copyWith({
    List<Order>? pendingOrders,
    List<Order>? completedOrders,
    List<Order>? allOrders,
    int? newOrdersCount,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    Map<String, int>? categoryStats,
    double? todayRevenue,
  }) {
    return OrderState(
      pendingOrders: pendingOrders ?? this.pendingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      allOrders: allOrders ?? this.allOrders,
      newOrdersCount: newOrdersCount ?? this.newOrdersCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      categoryStats: categoryStats ?? this.categoryStats,
      todayRevenue: todayRevenue ?? this.todayRevenue,
    );
  }
}

// Real-time order provider
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return OrderNotifier(storageService);
});

// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<OrderNotification>>((ref) {
  return NotificationNotifier();
});

// Order statistics provider
final orderStatsProvider = Provider<OrderStatistics>((ref) {
  final orderState = ref.watch(orderProvider);
  return OrderStatistics.fromOrderState(orderState);
});

// Real-time timer provider - Updated to prevent freezing
final realTimeTimerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (count) => count);
});

class OrderNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;

  const OrderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = NotificationType.info,
    this.isRead = false,
    this.data,
  });

  OrderNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return OrderNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  info,
  warning,
  error,
  success,
  newOrder,
  statusUpdate,
  lowStock,
}

class OrderStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int completedToday;
  final double averageOrderValue;
  final double todayRevenue;
  final Map<String, int> categoryBreakdown;
  final Map<OrderStatus, int> statusBreakdown;
  final List<Order> recentOrders;

  const OrderStatistics({
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.completedToday = 0,
    this.averageOrderValue = 0.0,
    this.todayRevenue = 0.0,
    this.categoryBreakdown = const {},
    this.statusBreakdown = const {},
    this.recentOrders = const [],
  });

  static OrderStatistics fromOrderState(OrderState state) {
    final today = DateTime.now();
    final todayOrders = state.allOrders
        .where((order) =>
            order.createdAt.year == today.year &&
            order.createdAt.month == today.month &&
            order.createdAt.day == today.day)
        .toList();

    final completedToday = todayOrders
        .where((order) =>
            order.status == OrderStatus.completed ||
            order.status == OrderStatus.pickedUp)
        .toList();

    final todayRevenue =
        completedToday.fold(0.0, (sum, order) => sum + order.totalAmount);
    final averageOrderValue =
        todayOrders.isNotEmpty ? todayRevenue / todayOrders.length : 0.0;

    // Category breakdown
    final categoryBreakdown = <String, int>{};
    for (final order in todayOrders) {
      for (final item in order.items) {
        categoryBreakdown[item.product.category] =
            (categoryBreakdown[item.product.category] ?? 0) + item.quantity;
      }
    }

    // Status breakdown
    final statusBreakdown = <OrderStatus, int>{};
    for (final order in state.allOrders) {
      statusBreakdown[order.status] = (statusBreakdown[order.status] ?? 0) + 1;
    }

    return OrderStatistics(
      totalOrders: state.allOrders.length,
      pendingOrders: state.pendingOrders.length,
      completedToday: completedToday.length,
      averageOrderValue: averageOrderValue,
      todayRevenue: todayRevenue,
      categoryBreakdown: categoryBreakdown,
      statusBreakdown: statusBreakdown,
      recentOrders: state.allOrders.take(5).toList(),
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final StorageService _storageService;
  Timer? _simulationTimer;
  Timer? _statsTimer;
  final Random _random = Random();

  OrderNotifier(this._storageService)
      : super(OrderState(lastUpdate: DateTime.now())) {
    _initializeOrders();
    _startRealTimeSimulation();
    _startStatsUpdates();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _statsTimer?.cancel();
    super.dispose();
  }

  void _initializeOrders() {
    final mockOrders = _generateMockOrders();
    final pending = mockOrders
        .where((order) =>
            order.status == OrderStatus.received ||
            order.status == OrderStatus.preparing)
        .toList();
    final completed = mockOrders
        .where((order) =>
            order.status == OrderStatus.completed ||
            order.status == OrderStatus.pickedUp)
        .toList();

    state = state.copyWith(
      pendingOrders: pending,
      completedOrders: completed,
      allOrders: mockOrders,
      lastUpdate: DateTime.now(),
      todayRevenue: _calculateTodayRevenue(completed),
    );
  }

  List<Order> _generateMockOrders() {
    final products = _getMockProducts();
    final orders = <Order>[];
    final now = DateTime.now();

    // Generate orders for the last few hours
    for (int i = 0; i < 15; i++) {
      final orderId = 'ORD${(1000 + i).toString().padLeft(4, '0')}';
      final orderTime =
          now.subtract(Duration(minutes: _random.nextInt(240))); // Last 4 hours
      final items = <CartItem>[];

      // Add 1-3 items per order
      final itemCount = 1 + _random.nextInt(3);
      for (int j = 0; j < itemCount; j++) {
        final product = products[_random.nextInt(products.length)];
        final quantity = 1 + _random.nextInt(3);
        items.add(CartItem(product: product, quantity: quantity));
      }

      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final status = _getRandomOrderStatus(orderTime);

      orders.add(Order(
        id: orderId,
        customerId: 'customer_${i + 1}',
        items: items,
        totalAmount: totalAmount,
        status: status,
        paymentMethod: _random.nextBool()
            ? PaymentMethod.online
            : PaymentMethod.cashOnPickup,
        createdAt: orderTime,
        updatedAt: status != OrderStatus.received
            ? orderTime.add(Duration(minutes: 10 + _random.nextInt(30)))
            : null,
        notes: _random.nextBool() ? 'Customer notes for order $orderId' : null,
      ));
    }

    return orders..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Product> _getMockProducts() {
    return [
      Product(
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
      Product(
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
      Product(
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
      Product(
        id: '4',
        name: 'Smartphone',
        description: 'Latest smartphone with advanced features',
        price: 699.99,
        stock: 8,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/100x100?text=Smartphone',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '5',
        name: 'Bananas',
        description: 'Fresh yellow bananas',
        price: 2.99,
        stock: 100,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/100x100?text=Bananas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  OrderStatus _getRandomOrderStatus(DateTime orderTime) {
    final now = DateTime.now();
    final minutesAgo = now.difference(orderTime).inMinutes;

    if (minutesAgo < 5) return OrderStatus.received;
    if (minutesAgo < 20) return OrderStatus.preparing;
    if (minutesAgo < 60) return OrderStatus.completed;
    return OrderStatus.pickedUp;
  }

  void _startRealTimeSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (mounted) {
        // 30% chance of new order every 45 seconds
        if (_random.nextDouble() < 0.3) {
          _simulateNewOrder();
        }

        // 20% chance of status update
        if (_random.nextDouble() < 0.2) {
          _simulateStatusUpdate();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startStatsUpdates() {
    _statsTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _updateStatistics();
      } else {
        timer.cancel();
      }
    });
  }

  void _simulateNewOrder() {
    final products = _getMockProducts();
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final items = <CartItem>[];

    // Add 1-2 items for new orders
    final itemCount = 1 + _random.nextInt(2);
    for (int i = 0; i < itemCount; i++) {
      final product = products[_random.nextInt(products.length)];
      final quantity = 1 + _random.nextInt(2);
      items.add(CartItem(product: product, quantity: quantity));
    }

    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    final newOrder = Order(
      id: orderId,
      customerId: 'customer_${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      totalAmount: totalAmount,
      status: OrderStatus.received,
      paymentMethod: _random.nextBool()
          ? PaymentMethod.online
          : PaymentMethod.cashOnPickup,
      createdAt: DateTime.now(),
      notes: _random.nextBool() ? 'Special instructions for order' : null,
    );

    final updatedPending = [...state.pendingOrders, newOrder];
    final updatedAll = [...state.allOrders, newOrder];

    state = state.copyWith(
      pendingOrders: updatedPending,
      allOrders: updatedAll,
      newOrdersCount: state.newOrdersCount + 1,
      lastUpdate: DateTime.now(),
    );

    // Trigger notification
    _addNotification(OrderNotification(
      id: 'new_order_${newOrder.id}',
      title: 'New Order Received',
      message:
          'Order ${newOrder.id} - \$${newOrder.totalAmount.toStringAsFixed(2)}',
      timestamp: DateTime.now(),
      type: NotificationType.newOrder,
      data: {'orderId': newOrder.id},
    ));
  }

  void _simulateStatusUpdate() {
    if (state.pendingOrders.isEmpty) return;

    final order =
        state.pendingOrders[_random.nextInt(state.pendingOrders.length)];
    final nextStatus = _getNextStatus(order.status);

    if (nextStatus != null) {
      updateOrderStatus(order.id, nextStatus);
    }
  }

  OrderStatus? _getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.received:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.completed;
      case OrderStatus.completed:
        return OrderStatus.pickedUp;
      case OrderStatus.pickedUp:
        return null;
    }
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final updatedPending = <Order>[];
    final updatedCompleted = [...state.completedOrders];
    final updatedAll = <Order>[];
    Order? updatedOrder;

    for (final order in state.pendingOrders) {
      if (order.id == orderId) {
        updatedOrder = order.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );

        if (newStatus == OrderStatus.pickedUp) {
          updatedCompleted.add(updatedOrder);
        } else {
          updatedPending.add(updatedOrder);
        }
      } else {
        updatedPending.add(order);
      }
    }

    // Update all orders list
    for (final order in state.allOrders) {
      if (order.id == orderId && updatedOrder != null) {
        updatedAll.add(updatedOrder);
      } else {
        updatedAll.add(order);
      }
    }

    if (updatedOrder != null) {
      state = state.copyWith(
        pendingOrders: updatedPending,
        completedOrders: updatedCompleted,
        allOrders: updatedAll,
        lastUpdate: DateTime.now(),
        todayRevenue: _calculateTodayRevenue(updatedCompleted),
      );

      // Add status update notification
      _addNotification(OrderNotification(
        id: 'status_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order Status Updated',
        message: 'Order ${orderId} is now ${_getStatusText(newStatus)}',
        timestamp: DateTime.now(),
        type: NotificationType.statusUpdate,
        data: {'orderId': orderId, 'status': newStatus.name},
      ));
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.preparing:
        return 'Being Prepared';
      case OrderStatus.completed:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
    }
  }

  void _updateStatistics() {
    final categoryStats = <String, int>{};
    for (final order in state.allOrders) {
      for (final item in order.items) {
        categoryStats[item.product.category] =
            (categoryStats[item.product.category] ?? 0) + item.quantity;
      }
    }

    state = state.copyWith(
      categoryStats: categoryStats,
      lastUpdate: DateTime.now(),
    );
  }

  double _calculateTodayRevenue(List<Order> completedOrders) {
    final today = DateTime.now();
    return completedOrders
        .where((order) =>
            order.createdAt.year == today.year &&
            order.createdAt.month == today.month &&
            order.createdAt.day == today.day)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  void clearNewOrdersCount() {
    state = state.copyWith(newOrdersCount: 0);
  }

  void refreshOrders() {
    state = state.copyWith(isLoading: true);

    // Simulate refresh delay
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _updateStatistics();
        state = state.copyWith(
          isLoading: false,
          lastUpdate: DateTime.now(),
        );
      }
    });
  }

  void _addNotification(OrderNotification notification) {
    // This will be handled by the notification provider
  }
}

class NotificationNotifier extends StateNotifier<List<OrderNotification>> {
  NotificationNotifier() : super([]);

  void addNotification(OrderNotification notification) {
    state = [notification, ...state];

    // Auto-remove old notifications (keep last 50)
    if (state.length > 50) {
      state = state.take(50).toList();
    }
  }

  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void markAllAsRead() {
    state = state
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
  }

  void clearAll() {
    state = [];
  }

  void removeNotification(String notificationId) {
    state = state
        .where((notification) => notification.id != notificationId)
        .toList();
  }

  int get unreadCount {
    return state.where((notification) => !notification.isRead).length;
  }
}
