// lib/screens/pending_registrations_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/tablet_registration.dart';
import '../services/sync_service.dart';
import '../constants.dart';

class PendingRegistrationsScreen extends StatefulWidget {
  const PendingRegistrationsScreen({super.key});

  @override
  _PendingRegistrationsScreenState createState() =>
      _PendingRegistrationsScreenState();
}

class _PendingRegistrationsScreenState extends State<PendingRegistrationsScreen> {
  final SyncService _syncService = SyncService();
  List<TabletRegistration> _pendingRegistrations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRegistrations();
  }

  Future<void> _loadPendingRegistrations() async {
    setState(() => _isLoading = true);
    final pending = await _syncService.getPendingRegistrations();
    if (mounted) {
      setState(() {
        _pendingRegistrations = pending;
        _isLoading = false;
      });
    }
  }

  Future<void> _syncRegistrations() async {
    setState(() => _isLoading = true);
    final results = await _syncService.syncPendingRegistrations(context);
    if (!mounted) return;

    int successes = results.where((r) => r.success).length;
    int failures = results.where((r) => !r.success).length;

    if (successes > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successes registro${successes > 1 ? 's' : ''} enviado${successes > 1 ? 's' : ''} correctamente'),
          backgroundColor: AppColors.cfeGreen,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
    if (failures > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$failures registro${failures > 1 ? 's' : ''} no pudo${failures > 1 ? 'ron' : ''} enviarse'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    await _loadPendingRegistrations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Registros Pendientes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.cfeDarkGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_pendingRegistrations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _syncRegistrations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cfeGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                      elevation: 0,
                    ),
                    child: Text(
                      _isLoading ? 'Enviando...' : 'Enviar Todos',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading && _pendingRegistrations.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cfeGreen,
                        ),
                      )
                    : _pendingRegistrations.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay registros pendientes',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _pendingRegistrations.length,
                            itemBuilder: (context, index) {
                              final registration =
                                  _pendingRegistrations[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Activo: ${registration.activo}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.cfeDarkGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Inventario: ${registration.inventario}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        'Serie: ${registration.numeroSerie}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        'Fotos: ${registration.fotoPaths.length}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (registration.firmaPath != null)
                                        const Text(
                                          'Firma: Incluida',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      Text(
                                        'Fecha: ${registration.timestamp.toLocal().toString().split('.')[0]}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (registration.fallas.isNotEmpty)
                                        Text(
                                          'Fallas: ${registration.fallas.length}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      if (registration.fotoPaths.isNotEmpty)
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                registration.fotoPaths.length,
                                            itemBuilder: (context, fotoIndex) {
                                              final file = File(
                                                  registration
                                                      .fotoPaths[fotoIndex]);
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.file(
                                                    file,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                          size: 80,
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          if (_isLoading && _pendingRegistrations.isNotEmpty)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.cfeGreen),
              ),
            ),
        ],
      ),
    );
  }
}