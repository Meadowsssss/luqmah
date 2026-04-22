import '../models/vendor.dart';

final List<VendorOrder> initialVendorOrders = <VendorOrder>[
  VendorOrder(
    id: '#546VSD32DSF65Q',
    customerName: 'Aalfred Sanderson',
    customerPhone: '+962 7 9000 1101',
    dateTime: DateTime(2026, 4, 22, 10, 14),
    paymentMethod: 'Cash On Delivery',
    status: VendorOrderStatus.accepted,
    items: const [
      VendorOrderItem(
        name: 'Veg Noodles With Market Veggies Combo',
        quantity: 1,
        price: 150,
        extras: ['Extra Toppings', 'Extra Sauce', 'Extra Vegetables'],
      ),
      VendorOrderItem(
        name: 'Choco Vanilla Thick Shake',
        quantity: 4,
        price: 70,
      ),
      VendorOrderItem(
        name: 'Thin Crust Italian Taste',
        quantity: 1,
        price: 110,
        extras: ['Extra Toppings', 'Extra Sauce', 'Extra Vegetables'],
      ),
    ],
    subtotal: 540,
    coupon: -162,
    total: 378,
  ),
  VendorOrder(
    id: '#987XYZ654ABC',
    customerName: 'Samantha Smith',
    customerPhone: '+962 7 9000 1102',
    dateTime: DateTime(2026, 4, 22, 11, 0),
    paymentMethod: 'Cash On Delivery',
    status: VendorOrderStatus.inProgress,
    items: const [
      VendorOrderItem(name: 'Veg Burger', quantity: 2, price: 120),
      VendorOrderItem(name: 'French Fries', quantity: 1, price: 80),
    ],
    subtotal: 320,
    coupon: 0,
    total: 320,
  ),
  VendorOrder(
    id: '#321LMN852PQR',
    customerName: 'Jessica Amenda',
    customerPhone: '+962 7 9000 1103',
    dateTime: DateTime(2026, 4, 21, 18, 42),
    paymentMethod: 'Cash On Delivery',
    status: VendorOrderStatus.completed,
    items: const [
      VendorOrderItem(
        name: 'Choco Vanilla Thick Shake',
        quantity: 2,
        price: 70,
      ),
      VendorOrderItem(
        name: 'Veg Noodles With Market Veggies Combo',
        quantity: 1,
        price: 150,
        extras: ['Extra Cheese'],
      ),
    ],
    subtotal: 290,
    coupon: -10,
    total: 280,
  ),
];

final List<VendorMenuItem> initialVendorMenuItems = <VendorMenuItem>[
  const VendorMenuItem(
    id: 'item_001',
    title: 'Veg Noodles',
    type: 'Veg',
    category: 'Vegetarian',
    ingredients: ['Noodles', 'Vegetables', 'Soy Sauce'],
    price: 150,
    image: '',
    customizations: ['Extra Veggies', 'Extra Sauce'],
  ),
  const VendorMenuItem(
    id: 'item_002',
    title: 'Choco Vanilla Thick Shake',
    type: 'Veg',
    category: 'Beverage',
    ingredients: ['Milk', 'Chocolate', 'Vanilla'],
    price: 70,
    image: '',
    customizations: ['Extra Chocolate'],
  ),
];
