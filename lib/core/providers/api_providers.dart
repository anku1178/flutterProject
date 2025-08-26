import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';
import 'auth_providers.dart';
import 'product_providers.dart';

// API-enabled auth provider
final apiAuthProvider =
    StateNotifierProvider<ApiAuthNotifier, ApiState<User>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return ApiAuthNotifier(apiService, storageService);
});

class ApiAuthNotifier extends ApiStateNotifier<User> {
  final ApiService _apiService;
  final StorageService _storageService;

  ApiAuthNotifier(this._apiService, this._storageService);

  Future<void> login(String email, String password) async {
    await execute(() async {
      final response = await _apiService.login(email, password);
      if (response.success && response.data != null) {
        // Save user locally
        await _storageService.saveUser(response.data!);
        return response.data!;
      } else {
        throw AppError.validation(
          message: response.message ?? 'Login failed',
        );
      }
    });
  }

  Future<void> register(Map<String, dynamic> userData) async {
    await execute(() async {
      final response = await _apiService.register(userData);
      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        return response.data!;
      } else {
        throw AppError.validation(
          message: response.message ?? 'Registration failed',
        );
      }
    });
  }

  Future<void> logout() async {
    await execute(() async {
      // Call API logout
      await _apiService.logout();

      // Clear local storage
      await _storageService.clearUser();
      await _storageService.clearAuthTokens();
      await _storageService.clearCartItems();

      // Reset state
      state = const ApiState();

      return state.data!;
    });
  }

  Future<void> loadCurrentUser() async {
    // First try to load from local storage
    final localUser = _storageService.getUser();
    if (localUser != null && _storageService.isLoggedIn()) {
      state = ApiState<User>(
        data: localUser,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // Then refresh from API
      await refreshProfile();
    }
  }

  Future<void> refreshProfile() async {
    await execute(() async {
      final response = await _apiService.getProfile();
      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        return response.data!;
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to refresh profile',
        );
      }
    });
  }
}

// API-enabled products provider
final apiProductsProvider =
    StateNotifierProvider<ApiProductsNotifier, ApiState<List<Product>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ApiProductsNotifier(apiService);
});

class ApiProductsNotifier extends ApiStateNotifier<List<Product>> {
  final ApiService _apiService;

  ApiProductsNotifier(this._apiService);

  Future<void> loadProducts({
    String? category,
    String? search,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    int page = 1,
    int limit = 20,
  }) async {
    await execute(() async {
      final response = await _apiService.getProducts(
        category: category,
        search: search,
        sortBy: sortBy,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to load products',
        );
      }
    });
  }

  Future<void> searchProducts(String query) async {
    await loadProducts(search: query);
  }

  Future<void> filterByCategory(String category) async {
    await loadProducts(category: category);
  }

  Future<void> refresh() async {
    await loadProducts();
  }
}

// API-enabled orders provider
final apiOrdersProvider =
    StateNotifierProvider<ApiOrdersNotifier, ApiState<List<Order>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ApiOrdersNotifier(apiService);
});

class ApiOrdersNotifier extends ApiStateNotifier<List<Order>> {
  final ApiService _apiService;

  ApiOrdersNotifier(this._apiService);

  Future<void> loadOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    await execute(() async {
      final response = await _apiService.getOrders(
        status: status,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to load orders',
        );
      }
    });
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await execute(() async {
      final response = await _apiService.createOrder(orderData);

      if (response.success && response.data != null) {
        // Refresh orders list to include new order
        await loadOrders();
        return state.data ?? [];
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to create order',
        );
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await execute(() async {
      final response = await _apiService.updateOrderStatus(orderId, status);

      if (response.success) {
        // Update local state
        final updatedOrders = state.data?.map((order) {
          if (order.id == orderId) {
            return order.copyWith(status: status, updatedAt: DateTime.now());
          }
          return order;
        }).toList();

        return updatedOrders ?? [];
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to update order status',
        );
      }
    });
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}

// API-enabled cart provider
final apiCartProvider =
    StateNotifierProvider<ApiCartNotifier, ApiState<List<CartItem>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return ApiCartNotifier(apiService, storageService);
});

class ApiCartNotifier extends ApiStateNotifier<List<CartItem>> {
  final ApiService _apiService;
  final StorageService _storageService;

  ApiCartNotifier(this._apiService, this._storageService) {
    // Load cart from local storage initially
    _loadLocalCart();
  }

  void _loadLocalCart() {
    final localCart = _storageService.getCartItems();
    state = ApiState<List<CartItem>>(
      data: localCart,
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> syncWithServer() async {
    await execute(() async {
      final response = await _apiService.getCart();
      if (response.success && response.data != null) {
        // Save to local storage
        await _storageService.saveCartItems(response.data!);
        return response.data!;
      } else {
        // Fall back to local cart if server sync fails
        return _storageService.getCartItems();
      }
    });
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    // Optimistic update for better UX
    final currentCart = state.data ?? [];
    final existingItemIndex = currentCart.indexWhere(
      (item) => item.product.id == product.id,
    );

    List<CartItem> updatedCart;
    if (existingItemIndex >= 0) {
      updatedCart = [...currentCart];
      updatedCart[existingItemIndex] = updatedCart[existingItemIndex].copyWith(
        quantity: updatedCart[existingItemIndex].quantity + quantity,
      );
    } else {
      updatedCart = [
        ...currentCart,
        CartItem(product: product, quantity: quantity)
      ];
    }

    // Update local state immediately
    state = state.copyWith(data: updatedCart);
    await _storageService.saveCartItems(updatedCart);

    // Sync with server in background
    try {
      await _apiService.addToCart(product.id, quantity);
    } catch (e) {
      // Handle API error but keep local changes
      // In a real app, you might want to show a warning about offline mode
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final currentCart = state.data ?? [];
    final updatedCart = currentCart
        .map((item) {
          if (item.product.id == productId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        })
        .where((item) => item.quantity > 0)
        .toList();

    // Update local state immediately
    state = state.copyWith(data: updatedCart);
    await _storageService.saveCartItems(updatedCart);

    // Sync with server
    try {
      if (quantity > 0) {
        await _apiService.updateCartItem(productId, quantity);
      } else {
        await _apiService.removeFromCart(productId);
      }
    } catch (e) {
      // Handle API error but keep local changes
    }
  }

  Future<void> removeItem(String productId) async {
    final currentCart = state.data ?? [];
    final updatedCart = currentCart
        .where(
          (item) => item.product.id != productId,
        )
        .toList();

    // Update local state immediately
    state = state.copyWith(data: updatedCart);
    await _storageService.saveCartItems(updatedCart);

    // Sync with server
    try {
      await _apiService.removeFromCart(productId);
    } catch (e) {
      // Handle API error but keep local changes
    }
  }

  Future<void> clearCart() async {
    // Update local state immediately
    state = state.copyWith(data: []);
    await _storageService.clearCartItems();

    // Sync with server
    try {
      await _apiService.clearCart();
    } catch (e) {
      // Handle API error but keep local changes
    }
  }

  Future<void> refresh() async {
    await syncWithServer();
  }
}

// API-enabled inventory provider (for workers)
final apiInventoryProvider =
    StateNotifierProvider<ApiInventoryNotifier, ApiState<List<Product>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ApiInventoryNotifier(apiService);
});

class ApiInventoryNotifier extends ApiStateNotifier<List<Product>> {
  final ApiService _apiService;

  ApiInventoryNotifier(this._apiService);

  Future<void> loadInventory({
    bool? lowStock,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    await execute(() async {
      final response = await _apiService.getInventory(
        lowStock: lowStock,
        category: category,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to load inventory',
        );
      }
    });
  }

  Future<void> updateStock(String productId, int stock) async {
    await execute(() async {
      final response = await _apiService.updateStock(productId, stock);

      if (response.success && response.data != null) {
        // Update local state
        final updatedInventory = state.data?.map((product) {
          if (product.id == productId) {
            return product.copyWith(stock: stock, updatedAt: DateTime.now());
          }
          return product;
        }).toList();

        return updatedInventory ?? [];
      } else {
        throw AppError.network(
          message: response.message ?? 'Failed to update stock',
        );
      }
    });
  }

  Future<void> refresh() async {
    await loadInventory();
  }
}

// Connection status provider that checks network connectivity
final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, bool>((ref) {
  return NetworkStatusNotifier();
});

class NetworkStatusNotifier extends StateNotifier<bool> {
  NetworkStatusNotifier() : super(true) {
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    // In a real app, you would use connectivity_plus package
    // For now, we'll simulate connectivity checking
    try {
      // This is a placeholder - implement proper connectivity checking
      state = true;
    } catch (e) {
      state = false;
    }
  }

  Future<void> checkConnection() async {
    await _checkConnection();
  }
}

// Combined provider that switches between offline and online mode
final hybridProductsProvider = Provider<List<Product>>((ref) {
  final isOnline = ref.watch(networkStatusProvider);

  if (isOnline) {
    final apiProducts = ref.watch(apiProductsProvider);
    return apiProducts.data ?? [];
  } else {
    // Fall back to local/mock products
    final localProducts = ref.watch(productSearchProvider);
    return localProducts.filteredProducts;
  }
});

// Error handling provider that listens to all API errors
final apiErrorProvider =
    StateNotifierProvider<ApiErrorNotifier, AppError?>((ref) {
  return ApiErrorNotifier(ref);
});

class ApiErrorNotifier extends StateNotifier<AppError?> {
  final Ref _ref;

  ApiErrorNotifier(this._ref) : super(null) {
    // Listen to all API providers for errors
    _ref.listen<ApiState<User>>(apiAuthProvider, (previous, next) {
      if (next.hasError) {
        state = next.error;
      }
    });

    _ref.listen<ApiState<List<Product>>>(apiProductsProvider, (previous, next) {
      if (next.hasError) {
        state = next.error;
      }
    });

    _ref.listen<ApiState<List<Order>>>(apiOrdersProvider, (previous, next) {
      if (next.hasError) {
        state = next.error;
      }
    });

    _ref.listen<ApiState<List<CartItem>>>(apiCartProvider, (previous, next) {
      if (next.hasError) {
        state = next.error;
      }
    });
  }

  void clearError() {
    state = null;
  }
}
