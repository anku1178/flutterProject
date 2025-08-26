import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

// Error types for better categorization
enum ErrorType {
  network,
  validation,
  authentication,
  permission,
  storage,
  unknown,
}

// Enhanced error model
class AppError {
  final String message;
  final String? details;
  final ErrorType type;
  final String? code;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  const AppError({
    required this.message,
    this.details,
    this.type = ErrorType.unknown,
    this.code,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });

  factory AppError.network({
    String? message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message ?? 'Network connection failed',
      details: details,
      type: ErrorType.network,
      code: code,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  factory AppError.validation({
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      details: details,
      type: ErrorType.validation,
      code: code,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  factory AppError.storage({
    String? message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message ?? 'Storage operation failed',
      details: details,
      type: ErrorType.storage,
      code: code,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.validation:
        return message;
      case ErrorType.authentication:
        return 'Please log in again to continue.';
      case ErrorType.permission:
        return 'Permission denied. Please check your settings.';
      case ErrorType.storage:
        return 'Unable to save data. Please try again.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.permission:
        return Icons.security;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.unknown:
        return Icons.warning;
    }
  }

  Color get color {
    switch (type) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.validation:
        return AppColors.error;
      case ErrorType.authentication:
        return AppColors.primary;
      case ErrorType.permission:
        return AppColors.error;
      case ErrorType.storage:
        return AppColors.info;
      case ErrorType.unknown:
        return AppColors.error;
    }
  }
}

// Global error handler provider
final errorHandlerProvider =
    StateNotifierProvider<ErrorHandlerNotifier, List<AppError>>((ref) {
  return ErrorHandlerNotifier();
});

class ErrorHandlerNotifier extends StateNotifier<List<AppError>> {
  ErrorHandlerNotifier() : super([]);

  void addError(AppError error) {
    state = [error, ...state];

    // Keep only last 10 errors
    if (state.length > 10) {
      state = state.take(10).toList();
    }
  }

  void removeError(String errorId) {
    state =
        state.where((error) => error.timestamp.toString() != errorId).toList();
  }

  void clearAll() {
    state = [];
  }

  AppError? get latestError => state.isNotEmpty ? state.first : null;

  List<AppError> get networkErrors =>
      state.where((e) => e.type == ErrorType.network).toList();
  List<AppError> get validationErrors =>
      state.where((e) => e.type == ErrorType.validation).toList();
}

// Enhanced error dialog widget
class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            error.icon,
            color: error.color,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getTitle(),
              style: AppTextStyles.subtitle1.copyWith(
                color: error.color,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.userFriendlyMessage,
            style: AppTextStyles.body2,
          ),
          if (error.details != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Technical Details'),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.details!,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (onDismiss != null || onRetry == null)
          TextButton(
            onPressed: onDismiss ?? () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('Retry'),
          ),
      ],
    );
  }

  String _getTitle() {
    switch (error.type) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.validation:
        return 'Input Error';
      case ErrorType.authentication:
        return 'Authentication Required';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.storage:
        return 'Storage Error';
      case ErrorType.unknown:
        return 'Error';
    }
  }
}

// Enhanced snackbar for quick feedback
class ErrorSnackBar {
  static void show({
    required BuildContext context,
    required AppError error,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            error.icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (error.details != null)
                  Text(
                    error.details!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: error.color,
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// Success feedback widget
class SuccessSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    String? details,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (details != null)
                  Text(
                    details,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Form validation helper
class ValidationHelper {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static AppError validationError(String message) {
    return AppError.validation(
      message: message,
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }
}

// Network error recovery widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Please check your internet connection and try again.',
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Global error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: NetworkErrorWidget(
          message: 'An unexpected error occurred. Please restart the app.',
          onRetry: () {
            setState(() {
              _error = null;
              _stackTrace = null;
            });
          },
        ),
      );
    }

    return widget.child;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }
}
