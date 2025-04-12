import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'login_screen.dart';
import '../constants.dart';
import 'home_content.dart';
import 'tablet_registration_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  // Verifica si los servicios de ubicación están habilitados
  Future<bool> _checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Muestra un SnackBar con mensaje
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppColors.errorColor : AppColors.cfeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Navega a TabletRegistrationScreen si la ubicación está habilitada
  void _navigateToTabletRegistration(BuildContext context) async {
    bool locationEnabled = await _checkLocationService();
    if (locationEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabletRegistrationScreen(userData: userData),
        ),
      );
    } else {
      _showSnackBar(context, AppStrings.locationError, isError: true);
    }
  }

  // Muestra el diálogo de confirmación para cerrar sesión
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(AppStrings.logoutTitle),
        content: const Text(AppStrings.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.cancelButton,
              style: TextStyle(color: AppColors.cfeGreen),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            ),
            child: const Text(
              AppStrings.logoutButton,
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            AppStrings.appName,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.cfeDarkGreen,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.tablet_android, color: Colors.white),
              tooltip: AppStrings.manageTablets,
              onPressed: () => _navigateToTabletRegistration(context),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: AppStrings.logoutButton,
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
        body: HomeContent(
          userData: userData,
          onManageTablets: () => _navigateToTabletRegistration(context),
        ),
      ),
    );
  }
}