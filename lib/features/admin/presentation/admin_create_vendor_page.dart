import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../admin_vendors_controller.dart';

class AdminCreateVendorPage extends ConsumerStatefulWidget {
  const AdminCreateVendorPage({super.key});

  @override
  ConsumerState<AdminCreateVendorPage> createState() => _AdminCreateVendorPageState();
}

class _AdminCreateVendorPageState extends ConsumerState<AdminCreateVendorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantTitleController = TextEditingController();
  final _restaurantDescriptionController = TextEditingController();
  final _restaurantAddressController = TextEditingController();
  final _coverImageController = TextEditingController();
  final _categoriesController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _restaurantTitleController.dispose();
    _restaurantDescriptionController.dispose();
    _restaurantAddressController.dispose();
    _coverImageController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final categories = _categoriesController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

      await ref.read(adminVendorsControllerProvider.notifier).createVendor(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        restaurantTitle: _restaurantTitleController.text.trim(),
        restaurantDescription: _restaurantDescriptionController.text.trim(),
        restaurantAddress: _restaurantAddressController.text.trim(),
        coverImage: _coverImageController.text.trim(),
        categories: categories,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor created successfully.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create vendor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vendor account', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Vendor name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Vendor email'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Temporary password'),
                    validator: (value) => value == null || value.trim().length < 8
                        ? 'Minimum 8 characters'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Restaurant setup', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _restaurantTitleController,
                    decoration: const InputDecoration(labelText: 'Restaurant title'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _restaurantDescriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _restaurantAddressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _coverImageController,
                    decoration: const InputDecoration(labelText: 'Cover image URL'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _categoriesController,
                    decoration: const InputDecoration(
                      labelText: 'Categories',
                      hintText: 'Burgers, Drinks, Desserts',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'At least one category is required'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create vendor'),
            ),
          ],
        ),
      ),
    );
  }
}
