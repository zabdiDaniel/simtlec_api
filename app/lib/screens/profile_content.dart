import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../constants.dart';

class ProfileContent extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const ProfileContent({
    Key? key,
    required this.userData,
    required this.onRetry,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(context, userData),
          const SizedBox(height: 20),
          _buildUserInfoSection(userData),
          const SizedBox(height: 40),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    return FutureBuilder<String>(
      future: AuthApi().obtenerFotoPerfil(userData['rpe']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProfilePlaceholder(userData);
        }

        final nombreFoto = snapshot.data ?? 'default.jpg';
        final urlFoto = 'https://sistemascfe.com/cfe-api/uploads/perfiles/$nombreFoto';

        precacheImage(NetworkImage(urlFoto), context);

        return Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(urlFoto),
                onBackgroundImageError: (_, __) => null,
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
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfilePlaceholder(Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            userData['nombre'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'RPE: ${userData['rpe']}',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(Map<String, dynamic> userData) {
    final items = [
      {'title': AppStrings.emailTitle, 'value': userData['correo']},
      {'title': AppStrings.userTypeTitle, 'value': userData['tipo_usuario']},
      {'title': AppStrings.registerDateTitle, 'value': userData['fecha_registro']},
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
                  item['value']?.toString() ?? AppStrings.notSpecified,
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
        Text(
          title,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.logoutRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => _showLogoutConfirmation(context),
        child: const Text(
          AppStrings.logoutButton,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            onPressed: onLogout,
            child: const Text(
              AppStrings.logoutButton,
              style: TextStyle(color: AppColors.logoutRed),
            ),
          ),
        ],
      ),
    );
  }
}