# API Integration Guide

## Overview

This guide documents the API service layer structure that has been implemented for the General Store app. The architecture is designed to seamlessly integrate with a REST API backend while maintaining offline-first functionality.

## Architecture

### 1. API Service Layer (`lib/core/services/api_service.dart`)

The API service layer consists of:

- **ApiConfig**: Configuration class containing base URLs, endpoints, and API keys
- **ApiResponse<T>**: Generic response wrapper for consistent API responses
- **ApiClient**: HTTP client wrapper with error handling and authentication
- **ApiService**: Main service class with endpoint-specific methods

### 2. API Providers (`lib/core/providers/api_providers.dart`)

Riverpod providers that bridge the gap between UI and API:

- **apiAuthProvider**: Authentication state management with API integration
- **apiProductsProvider**: Product data management with server sync
- **apiOrdersProvider**: Order management with real-time updates
- **apiCartProvider**: Cart synchronization with offline-first approach
- **apiInventoryProvider**: Inventory management for workers
- **networkStatusProvider**: Network connectivity status monitoring

### 3. Enhanced Storage Service (`lib/core/services/storage_service.dart`)

Extended with authentication token storage:
- Auth token persistence
- Refresh token management
- Secure token clearing

## API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Token refresh

### Products
- `GET /products` - Get products with filters
- `GET /products/{id}` - Get single product
- `GET /categories` - Get product categories

### Cart Management
- `GET /cart` - Get user's cart
- `POST /cart/add` - Add item to cart
- `PUT /cart/item/{productId}` - Update cart item quantity
- `DELETE /cart/item/{productId}` - Remove item from cart
- `DELETE /cart` - Clear entire cart

### Orders
- `GET /orders` - Get user's orders
- `GET /orders/{id}` - Get single order
- `POST /orders` - Create new order
- `PUT /orders/{id}/status` - Update order status

### Inventory (Workers)
- `GET /inventory` - Get inventory with filters
- `PUT /inventory/{productId}` - Update product stock

### User Profile
- `GET /users/profile` - Get user profile
- `PUT /users/profile` - Update user profile

## Configuration Steps

### 1. Backend Configuration

Update `ApiConfig` in `api_service.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-domain.com/v1';
  static const String apiKey = 'your_actual_api_key';
  static const Duration timeout = Duration(seconds: 30);
}
```

### 2. Authentication Setup

The API client automatically handles:
- Bearer token authentication
- Token persistence in SharedPreferences
- Automatic token refresh (implement refresh logic)
- Token clearing on logout

### 3. Error Handling

Comprehensive error handling for:
- Network connectivity issues
- HTTP status codes (400, 401, 403, 404, 429, 5xx)
- JSON parsing errors
- Timeout errors
- Custom validation errors

## Integration Patterns

### 1. Offline-First Approach

The app follows an offline-first pattern:

```dart
// Cart example - immediate local update, background sync
await apiCartNotifier.addItem(product);
// ↑ Updates local state immediately
// ↑ Syncs with server in background
// ↑ Handles conflicts gracefully
```

### 2. Optimistic Updates

For better UX, the app performs optimistic updates:
- Update local state immediately
- Show user the change right away
- Sync with server in background
- Handle errors gracefully

### 3. Hybrid Providers

The app can switch between online and offline modes:

```dart
final hybridProductsProvider = Provider<List<Product>>((ref) {
  final isOnline = ref.watch(networkStatusProvider);
  
  if (isOnline) {
    // Use API data when online
    final apiProducts = ref.watch(apiProductsProvider);
    return apiProducts.data ?? [];
  } else {
    // Fall back to local/mock data when offline
    final localProducts = ref.watch(productSearchProvider);
    return localProducts.filteredProducts;
  }
});
```

## Migration from Mock to Real API

### 1. Update Providers

Replace existing providers with API-enabled versions:

```dart
// Before (mock data)
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(...);

// After (API-enabled)
final cartProvider = apiCartProvider; // or create an alias
```

### 2. Update UI Components

UI components require minimal changes since they already use Riverpod providers:

```dart
// This code remains the same
final cartItems = ref.watch(cartProvider);
```

### 3. Environment Configuration

Use different API configurations for different environments:

```dart
class ApiConfig {
  static String get baseUrl {
    switch (const String.fromEnvironment('ENV')) {
      case 'production':
        return 'https://api.generalstore.com/v1';
      case 'staging':
        return 'https://staging-api.generalstore.com/v1';
      default:
        return 'https://dev-api.generalstore.com/v1';
    }
  }
}
```

## Testing Strategy

### 1. Mock API Responses

Use the existing mock data for testing:

```dart
// For testing, you can override the API service
final mockApiServiceProvider = Provider<ApiService>((ref) {
  return MockApiService(); // Returns mock data
});
```

### 2. Integration Testing

Test API integration with a test server:

```dart
testWidgets('Cart sync with API', (tester) async {
  // Test cart synchronization
  // Test offline behavior
  // Test error handling
});
```

## Performance Considerations

### 1. Caching Strategy

- Local storage for immediate data access
- Background refresh for data freshness
- Intelligent cache invalidation

### 2. Network Optimization

- Request debouncing for search
- Pagination for large data sets
- Compression for API responses
- Connection pooling

### 3. Error Recovery

- Automatic retry with exponential backoff
- Graceful degradation to offline mode
- User-friendly error messages
- Recovery suggestions

## Security Considerations

### 1. Token Management

- Secure token storage
- Automatic token refresh
- Token expiry handling
- Logout on token invalidation

### 2. API Security

- HTTPS enforcement
- API key management
- Request signing (if required)
- Rate limiting compliance

### 3. Data Validation

- Client-side validation
- Server response validation
- XSS prevention
- SQL injection prevention

## Monitoring and Analytics

### 1. Error Tracking

Implement error tracking for:
- API failures
- Network issues
- Authentication errors
- Performance bottlenecks

### 2. Usage Analytics

Track:
- API response times
- Cache hit rates
- Offline usage patterns
- Feature usage statistics

## Future Enhancements

### 1. Real-time Features

- WebSocket integration for real-time updates
- Push notifications for order status
- Live inventory updates
- Real-time chat support

### 2. Advanced Caching

- GraphQL integration
- Advanced cache strategies
- Background sync optimization
- Selective data updates

### 3. Offline Capabilities

- Complete offline mode
- Conflict resolution
- Data synchronization
- Offline queue management

## Quick Start Checklist

- [ ] Update API configuration in `ApiConfig`
- [ ] Replace API key with actual key
- [ ] Update base URL to production/staging
- [ ] Test authentication flow
- [ ] Test product loading
- [ ] Test cart synchronization
- [ ] Test order creation
- [ ] Test error handling
- [ ] Test offline behavior
- [ ] Deploy and monitor

## Support

For questions or issues with the API integration:

1. Check the error logs in the app
2. Verify network connectivity
3. Check API server status
4. Review authentication tokens
5. Consult this documentation
6. Contact the development team

---

*This API service layer is designed to be production-ready and can be seamlessly integrated with any REST API backend that follows standard conventions.*