import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/customer/presentation/cart_page.dart';
import '../../features/customer/presentation/customer_settings_page.dart';
import '../../features/customer/presentation/order_history_page.dart';
import '../../features/customer/presentation/customer_shell.dart';
import '../../features/customer/presentation/restaurant_menu_page.dart';
import '../../features/customer/presentation/restaurants_page.dart';
import '../../features/admin/presentation/admin_create_vendor_page.dart';
import '../../features/admin/presentation/admin_login_page.dart';
import '../../features/admin/presentation/admin_vendors_page.dart';
import '../../features/session/session_controller.dart';
import '../../features/vendor/presentation/vendor_insights_page.dart';
import '../../features/vendor/presentation/vendor_order_details_page.dart';
import '../../features/vendor/presentation/vendor_orders_page.dart';
import '../../features/vendor/presentation/vendor_product_form_page.dart';
import '../../features/vendor/presentation/vendor_products_page.dart';
import '../../features/vendor/presentation/vendor_profile_page.dart';
import '../../features/vendor/presentation/vendor_restaurant_edit_page.dart';
import '../../features/vendor/presentation/vendor_shell.dart';
import '../../shared/widgets/app_loading_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/verify_email_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _customerShellKey = GlobalKey<NavigatorState>();
final _vendorShellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.read(sessionControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: session,
    redirect: (context, state) {
      final snapshot = session.snapshot;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isVerifyRoute = location == '/verify-email';
      final isLoadingRoute = location == '/loading';
      final isVendorRoute = location.startsWith('/vendor');
      final isAdminRoute = location.startsWith('/admin');
      final isAdminLoginRoute = location == '/admin/login';

      if (snapshot.isLoading) {
        return isLoadingRoute ? null : '/loading';
      }

      if (!snapshot.isSignedIn) {
        return (isAuthRoute || isAdminLoginRoute) ? null : '/login';
      }

      if (!snapshot.isAdminSurface &&
          !snapshot.isVendorSurface &&
          !snapshot.isEmailVerified) {
        return isVerifyRoute ? null : '/verify-email';
      }

      if (snapshot.isAdminSurface) {
        if (isLoadingRoute || isAuthRoute || isVerifyRoute || !isAdminRoute) {
          return '/admin/vendors';
        }
        return null;
      }

      if (snapshot.isVendorSurface) {
        if (isLoadingRoute ||
            isAuthRoute ||
            isVerifyRoute ||
            isAdminRoute ||
            !isVendorRoute) {
          return '/vendor/orders';
        }
        return null;
      }

      if (isVendorRoute ||
          isAdminRoute ||
          isAuthRoute ||
          isVerifyRoute ||
          isLoadingRoute) {
        return '/restaurants';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const AppLoadingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/admin/vendors',
        builder: (context, state) => const AdminVendorsPage(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const AdminCreateVendorPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _customerShellKey,
            routes: [
              GoRoute(
                path: '/restaurants',
                builder: (context, state) => const RestaurantsPage(),
                routes: [
                  GoRoute(
                    path: ':restaurantId',
                    builder: (context, state) {
                      final restaurantId =
                          state.pathParameters['restaurantId']!;
                      return RestaurantMenuPage(restaurantId: restaurantId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const CustomerSettingsPage(),
                routes: [
                  GoRoute(
                    path: 'orders',
                    builder: (context, state) => const OrderHistoryPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return VendorShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _vendorShellKey,
            routes: [
              GoRoute(
                path: '/vendor/orders',
                builder: (context, state) => const VendorOrdersPage(),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      return VendorOrderDetailsPage(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/products',
                builder: (context, state) => const VendorProductsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const VendorProductFormPage(),
                  ),
                  GoRoute(
                    path: ':itemId/edit',
                    builder: (context, state) {
                      final itemId = state.pathParameters['itemId']!;
                      return VendorProductFormPage(itemId: itemId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/insights',
                builder: (context, state) => const VendorInsightsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/profile',
                builder: (context, state) => const VendorProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        const VendorRestaurantEditPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
