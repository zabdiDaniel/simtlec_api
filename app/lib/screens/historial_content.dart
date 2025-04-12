import 'package:flutter/material.dart';
import '../constants.dart';

class HistorialContent extends StatelessWidget {
  final List<dynamic>? asignaciones;
  final String? error;
  final VoidCallback onRetry;

  const HistorialContent({
    Key? key,
    this.asignaciones,
    this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _buildErrorWidget(error!);
    }

    if (asignaciones == null || asignaciones!.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: asignaciones!.length,
      itemBuilder: (context, index) {
        final asignacion = asignaciones![index];
        return _buildAsignacionCard(asignacion);
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: AppColors.errorColor),
          const SizedBox(height: 20),
          Text(
            AppStrings.errorLoadingHistory.replaceFirst('%s', error),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cfeGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.retryButton),
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
            AppStrings.noHistoryMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.cfeGreen),
            child: const Text(AppStrings.updateButton),
          ),
        ],
      ),
    );
  }

  Widget _buildAsignacionCard(Map<String, dynamic> asignacion) {
    final bool isActive = asignacion['fecha_fin'] == null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0), // Corregido a 'bottom'
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
                  '${AppStrings.tabletLabel} ${asignacion['activo']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.cfeDarkGreen,
                  ),
                ),
                Chip(
                  label: Text(
                    isActive ? AppStrings.activeLabel : AppStrings.finishedLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: isActive ? AppColors.cfeGreen : Colors.grey,
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFEEEEEE)),
            _buildInfoRow(AppStrings.assignedToLabel, asignacion['rpe_trabajador']),
            _buildInfoRow(AppStrings.startDateLabel, asignacion['fecha_inicio']),
            if (asignacion['fecha_fin'] != null)
              _buildInfoRow(AppStrings.endDateLabel, asignacion['fecha_fin']),
            if (asignacion['tipo_asignacion'] != null)
              _buildInfoRow(AppStrings.typeLabel, asignacion['tipo_asignacion']),
            if (asignacion['observaciones'] != null && asignacion['observaciones'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.observationsLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.cfeDarkGreen,
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
      padding: const EdgeInsets.only(bottom: 8.0), // Corregido a 'bottom'
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.cfeDarkGreen),
            ),
          ),
        ],
      ),
    );
  }
}