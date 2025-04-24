import 'package:flutter/material.dart';
import '../constants.dart';
import 'help_content.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          AppStrings.helpTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.cfeDarkGreen,
        elevation: 0, // Sin sombra para minimalismo
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
      ),
      body: const HelpContent(),
      // FAB comentado para futura implementación
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contactando soporte...')),
          );
        },
        backgroundColor: AppColors.cfeGreen,
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
      */
    );
  }
}