import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../providers/product_providers.dart';
import '../models/models.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/customer/presentation/screens/customer_dashboard.dart';
import '../../features/customer/presentation/screens/product_list_screen.dart';
import '../../features/customer/presentation/screens/product_detail_screen.dart';
import '../../features/customer/presentation/screens/cart_screen.dart';
import '../../features/customer/presentation/screens/checkout_screen.dart';
import '../../features/customer/presentation/screens/order_tracking_screen.dart';
import '../../features/worker/presentation/screens/worker_dashboard.dart';
import '../../features/worker/presentation/screens/live_orders_screen.dart';
import '../../features/worker/presentation/screens/worker_inventory_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/admin/presentation/screens/admin_inventory_screen.dart';
import '../../features/admin/presentation/screens/analytics_screen.dart';
import '../../features/admin/presentation/screens/user_management_screen.dart';
import '../../features/admin/presentation/screens/excel_import_screen.dart';
import '../../features/customer/presentation/screens/customer_profile_screen.dart';
import '../../features/worker/presentation/screens/worker_profile_screen.dart';
import '../../features/admin/presentation/screens/admin_profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: _getInitialLocation(authState),
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final onboardingCompleted = authState.onboardingCompleted;
      final currentLocation = state.matchedLocation;

      // If not onboarded, always go to onboarding (except if already there)
      if (!onboardingCompleted && currentLocation != '/onboarding') {
        return '/onboarding';
      }

      // If onboarded but not logged in, go to login (except if on auth pages)
      if (onboardingCompleted && !isLoggedIn) {
        if (currentLocation != '/login' && 
            currentLocation != '/signup' && 
            currentLocation != '/otp-verification') {
          return '/login';
        }
      }

      // If trying to access onboarding or auth pages while logged in, redirect to dashboard
      if (isLoggedIn &&
          (currentLocation == '/onboarding' ||
              currentLocation == '/login' ||
              currentLocation == '/signup' ||
              currentLocation == '/otp-verification')) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          switch (user.role) {
            case UserRole.customer:
              return '/customer';
            case UserRole.worker:
              return '/worker';
            case UserRole.admin:
              return '/admin';
          }
        }
        return '/customer'; // Default fallback
      }

      return null; // No redirect needed
    },
    routes: [
      // Onboarding and Auth Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            name: extra?['name'] ?? '',
            phoneNumber: extra?['phoneNumber'] ?? '',
            selectedLanguage: extra?['selectedLanguage'] ?? '',
            isRegistration: extra?['isRegistration'] ?? false,
          );
        },
      ),

      // Customer Routes
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerDashboard(),
        routes: [
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: 'product/:id',
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: 'checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: 'orders/:id',
            builder: (context, state) => OrderTrackingScreen(
              orderId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
        ],
      ),

      // Worker Routes
      GoRoute(
        path: '/worker',
        builder: (context, state) => const WorkerDashboard(),
        routes: [
          GoRoute(
            path: 'orders',
            builder: (context, state) => const LiveOrdersScreen(),
          ),
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const WorkerInventoryScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const WorkerProfileScreen(),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const AdminInventoryScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'import',
            builder: (context, state) => const ExcelImportScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const AdminProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

// Helper function to determine initial location based on auth state
String _getInitialLocation(AuthState authState) {
  if (!authState.onboardingCompleted) {
    return '/onboarding';
  }

  if (!authState.isLoggedIn) {
    return '/login';
  }

  // User is logged in, but we can't access the user object directly here
  // The redirect function will handle proper routing based on user role
  return '/customer'; // This will be corrected by redirect logic
}
