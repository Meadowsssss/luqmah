import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/restaurant_menu_page.dart';
import 'models/restaurant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3ABF7C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          centerTitle: false,
        ),
      ),
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/restaurant' && settings.arguments is Restaurant) {
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
