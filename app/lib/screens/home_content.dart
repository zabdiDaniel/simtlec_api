import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../constants.dart';
import 'profile_screen.dart';
import 'historial_screen.dart';
import 'help_screen.dart';

class HomeContent extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onManageTablets;

  const HomeContent({
    Key? key,
    required this.userData,
    required this.onManageTablets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      backgroundColor: AppColors.cfeGreen,
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
                            color: AppColors.cfeGreen,
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
                    AppStrings.welcomeMessage,
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  Text(
                    'Tipo: ${userData['tipo_usuario']}',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
      label: Text(
        AppStrings.manageTablets,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: onManageTablets,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cfeGreen,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return Text(
      AppStrings.quickActions,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.cfeDarkGreen,
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
          AppStrings.profileLabel,
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
          AppStrings.historyLabel,
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
          AppStrings.helpLabel,
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
            Icon(icon, size: 30, color: AppColors.cfeDarkGreen),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.cfeDarkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}