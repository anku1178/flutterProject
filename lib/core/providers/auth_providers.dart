import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/cart_sync_service.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Cart sync service provider
final cartSyncServiceProvider = Provider<CartSyncService>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return CartSyncService(storageService);
});

// Initialize storage service
final storageInitProvider = FutureProvider<void>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  await storageService.init();
});

// Current user provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return CurrentUserNotifier(storageService);
});

// Authentication state provider
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return AuthStateNotifier(storageService);
});

// Cart provider with persistence and sync
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final storageService = ref.read(storageServiceProvider);
  final cartSyncService = ref.read(cartSyncServiceProvider);
  return CartNotifier(storageService, cartSyncService);
});

// App settings provider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return AppSettingsNotifier(storageService);
});

// Authentication state model
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final bool onboardingCompleted;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.onboardingCompleted = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    bool? onboardingCompleted,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

// App settings model
class AppSettings {
  final String theme;
  final bool notificationEnabled;
  final String language;

  const AppSettings({
    this.theme = 'light',
    this.notificationEnabled = true,
    this.language = 'en',
  });

  AppSettings copyWith({
    String? theme,
    bool? notificationEnabled,
    String? language,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      language: language ?? this.language,
    );
  }
}

// Current user notifier
class CurrentUserNotifier extends StateNotifier<User?> {
  final StorageService _storageService;

  CurrentUserNotifier(this._storageService) : super(null) {
    _loadUser();
  }

  void _loadUser() {
    final user = _storageService.getUser();
    state = user;
  }

  Future<void> setUser(User user) async {
    await _storageService.saveUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    await _storageService.clearUser();
    state = null;
  }

  Future<void> updateUser(User updatedUser) async {
    await _storageService.saveUser(updatedUser);
    state = updatedUser;
  }
}

// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final StorageService _storageService;

  AuthStateNotifier(this._storageService) : super(const AuthState()) {
    _loadAuthState();
  }

  void _loadAuthState() {
    final isLoggedIn = _storageService.isLoggedIn();
    final onboardingCompleted = _storageService.isOnboardingCompleted();

    state = state.copyWith(
      isLoggedIn: isLoggedIn,
      onboardingCompleted: onboardingCompleted,
    );
  }

  Future<void> login(User user) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _storageService.saveUser(user);
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _storageService.clearUser();
      // Keep cart items and app settings, only clear auth data
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
    }
  }

  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    state = state.copyWith(onboardingCompleted: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Cart notifier with persistence and sync
class CartNotifier extends StateNotifier<List<CartItem>> {
  final StorageService _storageService;
  final CartSyncService _cartSyncService;

  CartNotifier(this._storageService, this._cartSyncService) : super([]) {
    _loadCartItems();
  }

  void _loadCartItems() {
    final cartItems = _storageService.getCartItems();
    state = cartItems;
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    final existingIndex =
        state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update existing item
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = updatedItems;
    } else {
      // Add new item
      state = [...state, CartItem(product: product, quantity: quantity)];
    }

    await _saveAndSync('add_item', {
      'productId': product.id,
      'quantity': quantity,
    });
  }

  Future<void> removeItem(String productId) async {
    state = state.where((item) => item.product.id != productId).toList();
    await _saveAndSync('remove_item', {'productId': productId});
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final updatedItems = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = updatedItems;
    await _saveAndSync('update_quantity', {
      'productId': productId,
      'quantity': quantity,
    });
  }

  Future<void> clearCart() async {
    state = [];
    await _saveAndSync('clear_cart', {});
  }

  double get totalAmount {
    return state.fold(0.0, (total, item) => total + item.totalPrice);
  }

  int get totalItems {
    return state.fold(0, (total, item) => total + item.quantity);
  }

  // Enhanced sync functionality
  Future<void> _saveAndSync(String operation, Map<String, dynamic> data) async {
    await _storageService.saveCartItems(state);
    await _cartSyncService.saveCartOffline(state, operation);
    await _cartSyncService.trackOperation(operation, data);
  }

  Future<bool> syncCart(String userId) async {
    return await _cartSyncService.syncWithBackend(userId);
  }

  Future<void> retrySyncIfNeeded(String userId) async {
    await _cartSyncService.retryFailedSync(userId);
  }

  Future<bool> needsSync() async {
    return await _cartSyncService.needsSync();
  }

  Future<int> getPendingOperationsCount() async {
    return await _cartSyncService.getPendingOperationsCount();
  }
}

// App settings notifier
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storageService;

  AppSettingsNotifier(this._storageService) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final theme = _storageService.getThemePreference();
    final notificationEnabled = _storageService.isNotificationEnabled();
    final language = _storageService.getLanguage();

    state = AppSettings(
      theme: theme,
      notificationEnabled: notificationEnabled,
      language: language,
    );
  }

  Future<void> setTheme(String theme) async {
    await _storageService.setThemePreference(theme);
    state = state.copyWith(theme: theme);
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _storageService.setNotificationEnabled(enabled);
    state = state.copyWith(notificationEnabled: enabled);
  }

  Future<void> setLanguage(String language) async {
    await _storageService.setLanguage(language);
    state = state.copyWith(language: language);
  }
}
