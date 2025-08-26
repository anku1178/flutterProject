import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';
import 'storage_service.dart';
import '../providers/auth_providers.dart';

// API configuration
class ApiConfig {
  static const String baseUrl =
      'https://api.generalstore.com/v1'; // Replace with actual API URL
  static const String apiKey =
      'your_api_key_here'; // Replace with actual API key
  static const Duration timeout = Duration(seconds: 30);

  // API endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String cartEndpoint = '/cart';
  static const String categoriesEndpoint = '/categories';
  static const String inventoryEndpoint = '/inventory';
}

// API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    this.data,
    this.message,
    required this.success,
    required this.statusCode,
    this.meta,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'],
      message: json['message'],
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 200,
      meta: json['meta'],
    );
  }
}

// HTTP client wrapper with error handling
class ApiClient {
  final http.Client _client;
  final StorageService _storageService;
  late String _baseUrl;
  String? _authToken;

  ApiClient(this._client, this._storageService) {
    _baseUrl = ApiConfig.baseUrl;
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    _authToken = await _storageService.getAuthToken();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': ApiConfig.apiKey,
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      body: body,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      body: body,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: _defaultHeaders)
              .timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: _defaultHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: _defaultHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _defaultHeaders)
              .timeout(ApiConfig.timeout);
          break;
        default:
          throw AppError(
            message: 'Unsupported HTTP method: $method',
            type: ErrorType.unknown,
            timestamp: DateTime.now(),
          );
      }

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      throw AppError.network(
        message: 'No internet connection',
        details: 'Please check your network settings',
      );
    } on HttpException catch (e) {
      throw AppError.network(
        message: 'Network error occurred',
        details: e.message,
      );
    } on FormatException {
      throw AppError.network(
        message: 'Invalid response format',
        details: 'The server returned an invalid response',
      );
    } catch (e) {
      throw AppError(
        message: 'Unexpected error occurred',
        details: e.toString(),
        type: ErrorType.unknown,
        timestamp: DateTime.now(),
      );
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse.fromJson(jsonData, fromJson);
      } else {
        _handleErrorResponse(statusCode, jsonData);
        return ApiResponse<T>(
          success: false,
          statusCode: statusCode,
          message: jsonData['message'] ?? 'Request failed',
        );
      }
    } catch (e) {
      throw AppError.network(
        message: 'Failed to parse response',
        details: 'Response: ${response.body}',
        code: statusCode.toString(),
      );
    }
  }

  void _handleErrorResponse(int statusCode, Map<String, dynamic> jsonData) {
    final message = jsonData['message'] ?? 'Unknown error';

    switch (statusCode) {
      case 400:
        throw AppError.validation(
          message: message,
          details: jsonData['errors']?.toString(),
          code: '400',
        );
      case 401:
        throw AppError(
          message: 'Authentication required',
          details: message,
          type: ErrorType.authentication,
          code: '401',
          timestamp: DateTime.now(),
        );
      case 403:
        throw AppError(
          message: 'Access denied',
          details: message,
          type: ErrorType.permission,
          code: '403',
          timestamp: DateTime.now(),
        );
      case 404:
        throw AppError.network(
          message: 'Resource not found',
          details: message,
          code: '404',
        );
      case 429:
        throw AppError.network(
          message: 'Too many requests',
          details: 'Please wait before trying again',
          code: '429',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw AppError.network(
          message: 'Server error',
          details: 'Please try again later',
          code: statusCode.toString(),
        );
      default:
        throw AppError.network(
          message: 'Request failed',
          details: message,
          code: statusCode.toString(),
        );
    }
  }

  void dispose() {
    _client.close();
  }
}

// Main API service
class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // Authentication endpoints
  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${ApiConfig.authEndpoint}/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final userData = response.data!;
      final user = User.fromJson(userData['user']);
      final token = userData['token'];

      _client.setAuthToken(token);

      return ApiResponse<User>(
        data: user,
        success: true,
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    return ApiResponse<User>(
      success: false,
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<User>> register(Map<String, dynamic> userData) async {
    return await _client.post<User>(
      '${ApiConfig.authEndpoint}/register',
      body: userData,
      fromJson: (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse<void>> logout() async {
    final response =
        await _client.post<void>('${ApiConfig.authEndpoint}/logout');
    if (response.success) {
      _client.clearAuthToken();
    }
    return response;
  }

  Future<ApiResponse<User>> refreshToken() async {
    return await _client.post<User>(
      '${ApiConfig.authEndpoint}/refresh',
      fromJson: (data) => User.fromJson(data),
    );
  }

  // Product endpoints
  Future<ApiResponse<List<Product>>> getProducts({
    String? category,
    String? search,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (inStock != null) queryParams['inStock'] = inStock.toString();

    return await _client.get<List<Product>>(
      ApiConfig.productsEndpoint,
      queryParams: queryParams,
      fromJson: (data) =>
          (data as List).map((item) => Product.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Product>> getProduct(String id) async {
    return await _client.get<Product>(
      '${ApiConfig.productsEndpoint}/$id',
      fromJson: (data) => Product.fromJson(data),
    );
  }

  Future<ApiResponse<List<String>>> getCategories() async {
    return await _client.get<List<String>>(
      ApiConfig.categoriesEndpoint,
      fromJson: (data) => List<String>.from(data),
    );
  }

  // Cart endpoints
  Future<ApiResponse<List<CartItem>>> getCart() async {
    return await _client.get<List<CartItem>>(
      ApiConfig.cartEndpoint,
      fromJson: (data) =>
          (data as List).map((item) => CartItem.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<CartItem>> addToCart(
      String productId, int quantity) async {
    return await _client.post<CartItem>(
      '${ApiConfig.cartEndpoint}/add',
      body: {
        'productId': productId,
        'quantity': quantity,
      },
      fromJson: (data) => CartItem.fromJson(data),
    );
  }

  Future<ApiResponse<CartItem>> updateCartItem(
      String productId, int quantity) async {
    return await _client.put<CartItem>(
      '${ApiConfig.cartEndpoint}/item/$productId',
      body: {'quantity': quantity},
      fromJson: (data) => CartItem.fromJson(data),
    );
  }

  Future<ApiResponse<void>> removeFromCart(String productId) async {
    return await _client
        .delete<void>('${ApiConfig.cartEndpoint}/item/$productId');
  }

  Future<ApiResponse<void>> clearCart() async {
    return await _client.delete<void>(ApiConfig.cartEndpoint);
  }

  // Order endpoints
  Future<ApiResponse<List<Order>>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status.name;

    return await _client.get<List<Order>>(
      ApiConfig.ordersEndpoint,
      queryParams: queryParams,
      fromJson: (data) =>
          (data as List).map((item) => Order.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Order>> getOrder(String id) async {
    return await _client.get<Order>(
      '${ApiConfig.ordersEndpoint}/$id',
      fromJson: (data) => Order.fromJson(data),
    );
  }

  Future<ApiResponse<Order>> createOrder(Map<String, dynamic> orderData) async {
    return await _client.post<Order>(
      ApiConfig.ordersEndpoint,
      body: orderData,
      fromJson: (data) => Order.fromJson(data),
    );
  }

  Future<ApiResponse<Order>> updateOrderStatus(
      String orderId, OrderStatus status) async {
    return await _client.put<Order>(
      '${ApiConfig.ordersEndpoint}/$orderId/status',
      body: {'status': status.name},
      fromJson: (data) => Order.fromJson(data),
    );
  }

  // Worker/Inventory endpoints
  Future<ApiResponse<List<Product>>> getInventory({
    bool? lowStock,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (lowStock != null) queryParams['lowStock'] = lowStock.toString();
    if (category != null) queryParams['category'] = category;

    return await _client.get<List<Product>>(
      ApiConfig.inventoryEndpoint,
      queryParams: queryParams,
      fromJson: (data) =>
          (data as List).map((item) => Product.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Product>> updateStock(String productId, int stock) async {
    return await _client.put<Product>(
      '${ApiConfig.inventoryEndpoint}/$productId',
      body: {'stock': stock},
      fromJson: (data) => Product.fromJson(data),
    );
  }

  // User profile endpoints
  Future<ApiResponse<User>> getProfile() async {
    return await _client.get<User>(
      '${ApiConfig.usersEndpoint}/profile',
      fromJson: (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> userData) async {
    return await _client.put<User>(
      '${ApiConfig.usersEndpoint}/profile',
      body: userData,
      fromJson: (data) => User.fromJson(data),
    );
  }

  void dispose() {
    _client.dispose();
  }
}

// Provider for API client
final apiClientProvider = Provider<ApiClient>((ref) {
  final httpClient = http.Client();
  final storageService = ref.read(storageServiceProvider);
  return ApiClient(httpClient, storageService);
});

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ApiService(apiClient);
});

// Connection status provider
final connectionStatusProvider = StateProvider<bool>((ref) => true);

// API state management for loading states
class ApiState<T> {
  final T? data;
  final bool isLoading;
  final AppError? error;
  final DateTime? lastUpdated;

  const ApiState({
    this.data,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  ApiState<T> copyWith({
    T? data,
    bool? isLoading,
    AppError? error,
    DateTime? lastUpdated,
  }) {
    return ApiState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get isSuccess => hasData && !hasError && !isLoading;
}

// Generic API state notifier
abstract class ApiStateNotifier<T> extends StateNotifier<ApiState<T>> {
  ApiStateNotifier() : super(const ApiState());

  Future<void> execute(Future<T> Function() apiCall) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await apiCall();
      state = ApiState<T>(
        data: result,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } on AppError catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppError(
          message: 'Unexpected error occurred',
          details: e.toString(),
          type: ErrorType.unknown,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void reset() {
    state = const ApiState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
