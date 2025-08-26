import 'dart:convert';
import '../models/models.dart';
import '../services/storage_service.dart';

// Cart sync state
enum CartSyncStatus {
  synced,
  pendingSync,
  syncFailed,
  offline,
}

class CartSyncData {
  final List<CartItem> items;
  final CartSyncStatus status;
  final DateTime lastSyncTime;
  final List<String> pendingOperations;
  final String? errorMessage;

  const CartSyncData({
    this.items = const [],
    this.status = CartSyncStatus.offline,
    required this.lastSyncTime,
    this.pendingOperations = const [],
    this.errorMessage,
  });

  CartSyncData copyWith({
    List<CartItem>? items,
    CartSyncStatus? status,
    DateTime? lastSyncTime,
    List<String>? pendingOperations,
    String? errorMessage,
  }) {
    return CartSyncData(
      items: items ?? this.items,
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      errorMessage: errorMessage,
    );
  }
}

class CartSyncService {
  final StorageService _storageService;
  static const String _syncDataKey = 'cart_sync_data';
  static const String _operationsKey = 'cart_pending_operations';

  CartSyncService(this._storageService);

  // Save cart with offline support
  Future<void> saveCartOffline(List<CartItem> items, String operation) async {
    final syncData = await getCartSyncData();
    final pendingOps = List<String>.from(syncData.pendingOperations)
      ..add(operation);

    final updatedSyncData = CartSyncData(
      items: items,
      status: CartSyncStatus.pendingSync,
      lastSyncTime: DateTime.now(),
      pendingOperations: pendingOps,
    );

    await _saveSyncData(updatedSyncData);
    await _storageService.saveCartItems(items);
  }

  // Load cart with sync status
  Future<CartSyncData> getCartSyncData() async {
    final syncDataJson = _storageService.prefs.getString(_syncDataKey);
    if (syncDataJson != null) {
      try {
        final data = jsonDecode(syncDataJson);
        return CartSyncData(
          items: (data['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
          status: CartSyncStatus.values[data['status']],
          lastSyncTime: DateTime.parse(data['lastSyncTime']),
          pendingOperations: List<String>.from(data['pendingOperations'] ?? []),
          errorMessage: data['errorMessage'],
        );
      } catch (e) {
        // Return default data if parsing fails
        return CartSyncData(lastSyncTime: DateTime.now());
      }
    }

    // Return current cart items with offline status
    final items = _storageService.getCartItems();
    return CartSyncData(
      items: items,
      status: CartSyncStatus.offline,
      lastSyncTime: DateTime.now(),
    );
  }

  // Simulate backend sync (prepare for real API)
  Future<bool> syncWithBackend(String userId) async {
    try {
      final syncData = await getCartSyncData();

      if (syncData.status == CartSyncStatus.synced) {
        return true; // Already synced
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate 90% success rate
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      if (random < 9) {
        // Sync successful
        final updatedSyncData = syncData.copyWith(
          status: CartSyncStatus.synced,
          lastSyncTime: DateTime.now(),
          pendingOperations: [],
          errorMessage: null,
        );

        await _saveSyncData(updatedSyncData);
        return true;
      } else {
        // Sync failed
        final updatedSyncData = syncData.copyWith(
          status: CartSyncStatus.syncFailed,
          errorMessage: 'Network error - will retry automatically',
        );

        await _saveSyncData(updatedSyncData);
        return false;
      }
    } catch (e) {
      final syncData = await getCartSyncData();
      final updatedSyncData = syncData.copyWith(
        status: CartSyncStatus.syncFailed,
        errorMessage: 'Sync error: ${e.toString()}',
      );

      await _saveSyncData(updatedSyncData);
      return false;
    }
  }

  // Resolve cart conflicts (for future backend integration)
  Future<List<CartItem>> resolveCartConflicts(
    List<CartItem> localCart,
    List<CartItem> serverCart,
  ) async {
    final resolvedCart = <String, CartItem>{};

    // Add local items
    for (final item in localCart) {
      resolvedCart[item.product.id] = item;
    }

    // Merge server items (server wins on conflicts, but keep higher quantity)
    for (final serverItem in serverCart) {
      final localItem = resolvedCart[serverItem.product.id];
      if (localItem != null) {
        // Keep the item with higher quantity
        resolvedCart[serverItem.product.id] =
            localItem.quantity > serverItem.quantity ? localItem : serverItem;
      } else {
        resolvedCart[serverItem.product.id] = serverItem;
      }
    }

    return resolvedCart.values.toList();
  }

  // Auto-retry failed syncs
  Future<void> retryFailedSync(String userId) async {
    final syncData = await getCartSyncData();
    if (syncData.status == CartSyncStatus.syncFailed) {
      await syncWithBackend(userId);
    }
  }

  // Clear sync data (for logout)
  Future<void> clearSyncData() async {
    await _storageService.prefs.remove(_syncDataKey);
    await _storageService.prefs.remove(_operationsKey);
  }

  // Get pending operations count
  Future<int> getPendingOperationsCount() async {
    final syncData = await getCartSyncData();
    return syncData.pendingOperations.length;
  }

  // Check if cart needs sync
  Future<bool> needsSync() async {
    final syncData = await getCartSyncData();
    return syncData.status == CartSyncStatus.pendingSync ||
        syncData.status == CartSyncStatus.syncFailed;
  }

  // Get sync status message for UI
  String getSyncStatusMessage(CartSyncStatus status, DateTime lastSync) {
    switch (status) {
      case CartSyncStatus.synced:
        return 'Cart synced ${_getTimeAgo(lastSync)}';
      case CartSyncStatus.pendingSync:
        return 'Sync pending...';
      case CartSyncStatus.syncFailed:
        return 'Sync failed - will retry';
      case CartSyncStatus.offline:
        return 'Offline mode';
    }
  }

  // Helper: Save sync data
  Future<void> _saveSyncData(CartSyncData syncData) async {
    final data = {
      'items': syncData.items.map((item) => item.toJson()).toList(),
      'status': syncData.status.index,
      'lastSyncTime': syncData.lastSyncTime.toIso8601String(),
      'pendingOperations': syncData.pendingOperations,
      'errorMessage': syncData.errorMessage,
    };

    await _storageService.prefs.setString(_syncDataKey, jsonEncode(data));
  }

  // Helper: Get time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Cart operation tracking for future API calls
  Future<void> trackOperation(
      String operation, Map<String, dynamic> data) async {
    final operations =
        _storageService.prefs.getStringList(_operationsKey) ?? [];
    final operationData = {
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    operations.add(jsonEncode(operationData));
    await _storageService.prefs.setStringList(_operationsKey, operations);
  }

  // Get all tracked operations
  Future<List<Map<String, dynamic>>> getTrackedOperations() async {
    final operations =
        _storageService.prefs.getStringList(_operationsKey) ?? [];
    return operations
        .map((op) => jsonDecode(op) as Map<String, dynamic>)
        .toList();
  }

  // Clear tracked operations
  Future<void> clearTrackedOperations() async {
    await _storageService.prefs.remove(_operationsKey);
  }
}
