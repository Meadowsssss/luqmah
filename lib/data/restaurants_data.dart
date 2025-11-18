
import '../models/restaurant.dart';

const _shawarmaImage = 'https://images.pexels.com/photos/616409/pexels-photo-616409.jpeg';
const _burgerImage = 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg';
const _pizzaImage = 'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg';
const _saladImage = 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg';
const _pastaImage = 'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg';

const List<Restaurant> restaurants = <Restaurant>[
  Restaurant(
    id: 'al_salam_grill',
    name: 'Al-Salam Grill',
    description: 'Traditional Middle Eastern cuisine',
    image: _shawarmaImage,
    rating: '4.5',
    time: '15–20 min',
    tags: ['Shawarma', 'Grills', 'Salads'],
    menu: [
      MenuItem(
        id: 'chicken_shawarma',
        name: 'Chicken Shawarma',
        description: 'Grilled chicken with garlic sauce and pickles',
        price: 2.50,
        image: _shawarmaImage,
      ),
      MenuItem(
        id: 'beef_shawarma',
        name: 'Beef Shawarma',
        description: 'Tender beef with tahini sauce and vegetables',
        price: 3.00,
        image: _shawarmaImage,
      ),
      MenuItem(
        id: 'falafel_plate',
        name: 'Falafel Plate',
        description: 'Crispy falafel with hummus and tahini',
        price: 2.00,
        image: _saladImage,
      ),
      MenuItem(
        id: 'fattoush_salad',
        name: 'Fattoush Salad',
        description: 'Fresh vegetables with crispy bread and sumac',
        price: 1.50,
        image: _saladImage,
      ),
    ],
  ),
  Restaurant(
    id: 'campus_burger',
    name: 'Campus Burger',
    description: 'Fresh burgers and fast food',
    image: _burgerImage,
    rating: '4.3',
    time: '10–15 min',
    tags: ['Burgers', 'Fries', 'Drinks'],
    menu: [
      MenuItem(
        id: 'classic_burger',
        name: 'Classic Burger',
        description: 'Grilled beef patty with cheese and lettuce',
        price: 3.50,
        image: _burgerImage,
      ),
      MenuItem(
        id: 'chicken_burger',
        name: 'Crispy Chicken Burger',
        description: 'Crispy chicken fillet with mayo and pickles',
        price: 3.00,
        image: _burgerImage,
      ),
      MenuItem(
        id: 'fries',
        name: 'French Fries',
        description: 'Golden fries with house seasoning',
        price: 1.20,
        image: _burgerImage,
      ),
    ],
  ),
  Restaurant(
    id: 'hu_pizza',
    name: 'HU Pizza Corner',
    description: 'Freshly baked pizzas and pasta',
    image: _pizzaImage,
    rating: '4.7',
    time: '20–30 min',
    tags: ['Pizza', 'Pasta', 'Soft drinks'],
    menu: [
      MenuItem(
        id: 'margherita',
        name: 'Margherita Pizza',
        description: 'Tomato sauce, mozzarella and basil',
        price: 4.00,
        image: _pizzaImage,
      ),
      MenuItem(
        id: 'pepperoni',
        name: 'Pepperoni Pizza',
        description: 'Beef pepperoni, cheese and tomato sauce',
        price: 4.50,
        image: _pizzaImage,
      ),
      MenuItem(
        id: 'creamy_pasta',
        name: 'Creamy Chicken Pasta',
        description: 'Penne pasta with creamy chicken sauce',
        price: 3.75,
        image: _pastaImage,
      ),
    ],
  ),
];
