// lib/screens/pending_registrations_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/tablet_registration.dart';
import '../services/sync_service.dart';
import '../constants.dart';

class PendingRegistrationsScreen extends StatefulWidget {
  const PendingRegistrationsScreen({super.key});

  @override
  _PendingRegistrationsScreenState createState() =>
      _PendingRegistrationsScreenState();
}

class _PendingRegistrationsScreenState
    extends State<PendingRegistrationsScreen> {
  final SyncService _syncService = SyncService();
  List<TabletRegistration> _pendingRegistrations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRegistrations();
  }

  Future<void> _loadPendingRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pendingRegistrations') ?? [];
    setState(() {
      _pendingRegistrations =
          pending
              .map((json) => TabletRegistration.fromJson(jsonDecode(json)))
              .toList();
    });
  }

  Future<void> _syncNow() async {
    setState(() => _isLoading = true);
    await _syncService.syncPendingRegistrations(context);
    await _loadPendingRegistrations();
    setState(() => _isLoading = false);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: _isLoading ? null : _syncNow,
            tooltip: 'Sincronizar ahora',
          ),
        ],
      ),
      body: Stack(
        children: [
          _pendingRegistrations.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.cfeGreen.withOpacity(0.5),
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay registros pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingRegistrations.length,
                itemBuilder: (context, index) {
                  final registration = _pendingRegistrations[index];
                  return AnimatedOpacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tableta: ${registration.activo}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cfeDarkGreen,
                                  ),
                                ),
                                Text(
                                  '${registration.timestamp.day}/${registration.timestamp.month}/${registration.timestamp.year} '
                                  '${registration.timestamp.hour}:${registration.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No. Serie: ${registration.numeroSerie}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (registration.rpeTrabajador != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Asignada a RPE: ${registration.rpeTrabajador}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (registration.fotoPaths.isNotEmpty) ...[
                              SizedBox(
                                height: 80,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      registration.fotoPaths.asMap().entries.map((
                                        entry,
                                      ) {
                                        final photoPath = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child:
                                                File(photoPath).existsSync()
                                                    ? Image.file(
                                                      File(photoPath),
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            width: 80,
                                                            height: 80,
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            child: const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                    )
                                                    : Container(
                                                      width: 80,
                                                      height: 80,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (registration.firmaPath != null &&
                                File(registration.firmaPath!).existsSync()) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.draw,
                                    color: AppColors.cfeGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Firma registrada',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          if (_isLoading)
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
