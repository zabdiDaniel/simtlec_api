import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String rpe;

  const ProfileScreen({Key? key, required this.rpe}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  final AuthApi _authApi = AuthApi();

  // Paleta de colores
  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color logoutRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userDataFuture = _authApi.obtenerDatosRegistrador(widget.rpe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: cfeDarkGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyWidget();
          }

          return _buildProfileContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Error al cargar perfil:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadUserData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No se encontraron datos del usuario',
            style: TextStyle(fontSize: 16),
          ),
          TextButton(
            onPressed: _loadUserData,
            child: const Text('Intentar nuevamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(userData),
          const SizedBox(height: 20),
          _buildUserInfoSection(userData),
          const SizedBox(height: 40),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return FutureBuilder<String>(
      future: _authApi.obtenerFotoPerfil(userData['rpe']),
      builder: (context, snapshot) {
        // Mientras carga, mostrar placeholder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProfilePlaceholder(userData);
        }

        final nombreFoto = snapshot.data ?? 'default.jpg';
        final urlFoto =
            'https://sistemascfe.com/cfe-api/uploads/perfiles/$nombreFoto';

        // Precargar la imagen en caché
        precacheImage(NetworkImage(urlFoto), context);

        return Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(urlFoto),
                onBackgroundImageError: (_, __) => null,
                child: null,
              ),
              const SizedBox(height: 16),
              Text(
                userData['nombre'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'RPE: ${userData['rpe']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para el estado de carga
  Widget _buildProfilePlaceholder(Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300], // Fondo gris claro
            child: null,
          ),
          const SizedBox(height: 16),
          Text(
            userData['nombre'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'RPE: ${userData['rpe']}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(Map<String, dynamic> userData) {
    final items = [
      {'title': 'Correo electrónico', 'value': userData['correo']},
      {'title': 'Tipo de usuario', 'value': userData['tipo_usuario']},
      {'title': 'Fecha de registro', 'value': userData['fecha_registro']},
    ];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                if (index > 0) const Divider(height: 20),
                _buildInfoItem(
                  item['title']!,
                  item['value']?.toString() ?? 'No especificado',
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: logoutRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _showLogoutConfirmation,
        child: const Text(
          'Cerrar sesión',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                onPressed:
                    () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    ),
                child: const Text('Salir', style: TextStyle(color: logoutRed)),
              ),
            ],
          ),
    );
  }
}
