import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
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
        ],
      ),
    ],
  );
});
