import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/restaurant_menu_page.dart';
import 'models/restaurant.dart';

/// Optional helper, just for testing your Firestore data.
Future<void> printCustomers() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('customers').get();

  for (var doc in snapshot.docs) {
    print('Customer ID: ${doc.id}');
    print('Email: ${doc['email']}');
    // add other fields if you have them, e.g.:
    // print('Name: ${doc['name']}');
    print('-------------------------');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // You can call this to debug your data if you want:
  // await printCustomers();

  runApp(const LuqmahApp());
}

class LuqmahApp extends StatelessWidget {
  const LuqmahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luqmah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        // for navigating to a restaurant menu:
        if (settings.name == '/restaurant' &&
            settings.arguments is Restaurant) {
          final restaurant = settings.arguments as Restaurant;
          return MaterialPageRoute(
            builder: (_) => RestaurantMenuPage(restaurant: restaurant),
          );
        }
        return null;
      },
    );
  }
}
