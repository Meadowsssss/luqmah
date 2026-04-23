import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../session/session_controller.dart';
import '../admin_repository.dart';
import '../admin_vendors_controller.dart';

class AdminVendorsPage extends ConsumerWidget {
  const AdminVendorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).snapshot;
    final vendors = ref.watch(adminVendorsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin vendors'),
        actions: [
          IconButton(
            onPressed: () => ref.read(sessionControllerProvider).logout(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/vendors/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add vendor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Provisioning desk', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  session.email.isEmpty
                      ? 'Create vendors, restaurants, and starter categories from one private workflow.'
                      : 'Signed in as ${session.email}. Create vendors, restaurants, and starter categories from one private workflow.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          vendors.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            )),
            error: (error, _) => AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load vendors',
              message: error.toString(),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'No vendors yet',
                  message: 'Create your first vendor account to start onboarding restaurants.',
                );
              }

              return Column(
                children: [
                  for (final vendor in items) ...[
                    _VendorCard(vendor: vendor),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});

  final AdminVendorRecord vendor;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vendor.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(vendor.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          for (final restaurant in vendor.restaurants) ...[
            Text(restaurant.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              restaurant.categories.isEmpty ? 'No categories yet' : restaurant.categories.join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (restaurant != vendor.restaurants.last) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}
