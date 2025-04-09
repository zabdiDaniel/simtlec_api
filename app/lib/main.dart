import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tablet_registration_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMTLEC',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      initialRoute: '/',
      routes: _buildRoutes(),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (context) => LoginScreen(), // Aquí se eliminó el `const`
      '/home': (context) {
        final userData =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HomeScreen(userData: userData);
      },
      '/tablet-registration': (context) => const TabletRegistrationScreen(),
    };
  }
}
