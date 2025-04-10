import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart'; // Añadir geolocator
import 'login_screen.dart';
import '../api/auth_api.dart';
import 'tablet_registration_screen.dart';
import 'profile_screen.dart';
import 'historial_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Método para verificar si los servicios de ubicación están habilitados
  Future<bool> _checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Método para mostrar un SnackBar
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : cfeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Método para manejar la navegación a TabletRegistrationScreen
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
      _showSnackBar(context, 'Por favor, activa los servicios de ubicación para registrar tabletas', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return WillPopScope(
      onWillPop: () async => false,
      child: Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(primary: cfeGreen),
        ),
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 30),
                _buildMainButton(context),
                const SizedBox(height: 30),
                _buildQuickActionsTitle(),
                const SizedBox(height: 15),
                _buildQuickActionsGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'SIMTLEC',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: cfeDarkGreen,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.tablet_android, color: Colors.white),
          tooltip: 'Administrar tabletas',
          onPressed: () => _navigateToTabletRegistration(context), // Usar el método nuevo
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Cerrar sesión',
          onPressed: () => _showLogoutConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            FutureBuilder<String>(
              future: AuthApi().obtenerFotoPerfil(userData['rpe']),
              builder: (context, snapshot) {
                final nombreFoto = snapshot.data ?? 'default.jpg';
                final urlFoto =
                    'https://sistemascfe.com/cfe-api/uploads/perfiles/$nombreFoto';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    urlFoto,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => CircleAvatar(
                      radius: 40,
                      backgroundColor: cfeGreen,
                      child: Text(
                        userData['nombre']
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cfeGreen,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido/a',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['nombre'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RPE: ${userData['rpe']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Tipo: ${userData['tipo_usuario']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.tablet_android, size: 24, color: Colors.white),
      label: const Text(
        'Administrar Tabletas',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: () => _navigateToTabletRegistration(context), // Usar el método nuevo
      style: ElevatedButton.styleFrom(
        backgroundColor: cfeGreen,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return const Text(
      'Acciones Rápidas',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: cfeDarkGreen,
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        _buildActionButton(
          context,
          Icons.person,
          'Perfil',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(rpe: userData['rpe']),
            ),
          ),
        ),
        _buildActionButton(
          context,
          Icons.history,
          'Historial',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistorialScreen(rpeRegistrador: userData['rpe']),
            ),
          ),
        ),
        _buildActionButton(
          context,
          Icons.help,
          'Ayuda',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: cfeDarkGreen),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: cfeDarkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que deseas salir de la aplicación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: cfeGreen),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            ),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}