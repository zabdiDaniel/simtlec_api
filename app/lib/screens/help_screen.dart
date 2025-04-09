import 'package:flutter/material.dart';
import 'home_screen.dart'; // Para acceder a los colores de CFE

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeScreen.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ayuda',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: HomeScreen.cfeDarkGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpSection(
              title: '¿Cómo registrar una tableta?',
              steps: [
                '1. Presiona el botón "Administrar Tabletas".',
                '2. Completa todos los campos obligatorios.',
                '3. Toma las 4 fotos de evidencia requeridas.',
                '4. Presiona "Registrar" para guardar los datos.',
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: '¿Cómo consultar el historial?',
              steps: [
                '1. Presiona el botón "Historial" en Acciones Rápidas.',
                '2. Verás la lista de tabletas registradas.',
                '3. Usa el botón de actualizar si no ves registros recientes.',
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpSection(
              title: 'Soporte técnico',
              steps: [
                'Para problemas con la app, contacta al área de TI:',
                'Correo: soporte-tecnico@cfe.mx',
                'Teléfono: 555-123-4567',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required List<String> steps,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HomeScreen.cfeDarkGreen,
              ),
            ),
            const SizedBox(height: 10),
            ...steps
                .map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      step,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}
