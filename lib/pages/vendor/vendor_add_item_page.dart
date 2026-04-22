import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../services/vendor_store.dart';
import '../../widgets/account_menu_button.dart';
import '../../widgets/vendor/vendor_access_guard.dart';
import '../../widgets/vendor/vendor_bottom_nav.dart';
import 'vendor_placeholder_page.dart';

class VendorAddItemPage extends StatefulWidget {
  const VendorAddItemPage({super.key});

  @override
  State<VendorAddItemPage> createState() => _VendorAddItemPageState();
}

class _VendorAddItemPageState extends State<VendorAddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _customizationCtrl = TextEditingController();

  String _selectedType = 'Veg';
  String _selectedCategory = 'Vegetarian';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _ingredientsCtrl.dispose();
    _priceCtrl.dispose();
    _customizationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = VendorMenuItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      ingredients: _ingredientsCtrl.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      price: double.parse(_priceCtrl.text.trim()),
      image: '',
      customizations: _customizationCtrl.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
    );

    VendorStore.addMenuItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} added to vendor products.')),
    );
    _formKey.currentState!.reset();
    _titleCtrl.clear();
    _ingredientsCtrl.clear();
    _priceCtrl.clear();
    _customizationCtrl.clear();
    setState(() {
      _selectedType = 'Veg';
      _selectedCategory = 'Vegetarian';
    });
  }

  @override
  Widget build(BuildContext context) {
    return VendorAccessGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        bottomNavigationBar: const VendorBottomNav(currentIndex: 2),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Expanded(
                      child: Text(
                        'Add New Item',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AccountMenuButton(
                      onProfileTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VendorPlaceholderPage(
                              title: 'Profile',
                              icon: Icons.storefront_rounded,
                              message:
                                  'Vendor profile settings will live here once the backend account data is connected.',
                              currentIndex: 3,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 88,
                            width: 88,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text(
                                'meAluq',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Image upload UI is ready for backend hookup.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              color: Color(0xFF0EC56D),
                            ),
                            label: const Text(
                              'Add Food Item Image',
                              style: TextStyle(color: Color(0xFF0EC56D)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _FieldLabel('Food Title'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _titleCtrl,
                        hintText: 'Enter Food Name',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Food title is required'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('Food Product Type'),
                      const SizedBox(height: 8),
                      _RoundedDropdown<String>(
                        value: _selectedType,
                        items: const ['Veg', 'Non-Veg', 'Drink', 'Dessert'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('Food Category'),
                      const SizedBox(height: 8),
                      _RoundedDropdown<String>(
                        value: _selectedCategory,
                        items: const [
                          'Vegetarian',
                          'Beverage',
                          'Pizza',
                          'Burger',
                          'Dessert',
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('Food Ingredients'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _ingredientsCtrl,
                        hintText: 'Add Food Ingredients',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Ingredients are required'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('Food Price'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _priceCtrl,
                        hintText: 'Enter Food Price',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }

                          if (double.tryParse(value.trim()) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF0EC56D),
                          ),
                          label: const Text(
                            'Add Customization Options',
                            style: TextStyle(color: Color(0xFF0EC56D)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _RoundedTextField(
                        controller: _customizationCtrl,
                        hintText: 'Extra cheese, Extra veggies, Extra sauce',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EC56D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Add This Item',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _RoundedTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _RoundedDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _RoundedDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(18),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    );
  }
}
