import 'package:flutter/material.dart';
import '../api/tabletas_api.dart';

class HistorialScreen extends StatefulWidget {
  final String rpeRegistrador;

  const HistorialScreen({super.key, required this.rpeRegistrador});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<dynamic>> _historialFuture;
  final TabletasApi _tabletasApi = TabletasApi();

  // Paleta de colores CFE
  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _historialFuture = _tabletasApi.obtenerHistorialAsignaciones(
        widget.rpeRegistrador,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Historial de Asignaciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: cfeDarkGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<dynamic>>(
          future: _historialFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: cfeGreen),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }

            // Lista vacía (no es un error)
            if (snapshot.data?.isEmpty ?? true) {
              return _buildEmptyWidget(); // Muestra mensaje amigable
            }

            return _buildList(snapshot.data!);
          },
        ),
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
          Text(
            'Error al cargar el historial:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: cfeGreen,
              foregroundColor: Colors.white,
            ),
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
          const Icon(Icons.tablet_android, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No has registrado ninguna tableta todavía',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loadData,
            child: const Text('Actualizar', style: TextStyle(color: cfeGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> asignaciones) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: asignaciones.length,
      itemBuilder: (context, index) {
        final asignacion = asignaciones[index];
        return _buildAsignacionCard(asignacion);
      },
    );
  }

  Widget _buildAsignacionCard(Map<String, dynamic> asignacion) {
    final bool isActive = asignacion['fecha_fin'] == null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tableta: ${asignacion['activo']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: cfeDarkGreen,
                  ),
                ),
                Chip(
                  label: Text(
                    isActive ? 'Activa' : 'Finalizada',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: isActive ? cfeGreen : Colors.grey,
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFEEEEEE)),
            _buildInfoRow('Asignada a:', asignacion['rpe_trabajador']),
            _buildInfoRow('Fecha inicio:', asignacion['fecha_inicio']),
            if (asignacion['fecha_fin'] != null)
              _buildInfoRow('Fecha fin:', asignacion['fecha_fin']),
            if (asignacion['tipo_asignacion'] != null)
              _buildInfoRow('Tipo:', asignacion['tipo_asignacion']),
            if (asignacion['observaciones'] != null &&
                asignacion['observaciones'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Observaciones:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cfeDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asignacion['observaciones'],
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: cfeDarkGreen)),
          ),
        ],
      ),
    );
  }
}
