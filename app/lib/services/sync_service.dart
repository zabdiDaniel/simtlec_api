// lib/services/sync_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../api/tabletas_api.dart';
import '../models/tablet_registration.dart';
import '../constants.dart';

class SyncService {
  Future<void> saveRegistrationLocally(TabletRegistration registration) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pending = prefs.getStringList('pendingRegistrations') ?? [];
    pending.add(jsonEncode(registration.toJson()));
    await prefs.setStringList('pendingRegistrations', pending);
  }

  Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('pendingRegistrations') ?? []).length;
  }

  Future<void> syncPendingRegistrations(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('Sin conexión, esperando...');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> pending = prefs.getStringList('pendingRegistrations') ?? [];
    if (pending.isEmpty) return;

    List<String> stillPending = [];
    for (String json in pending) {
      final registration = TabletRegistration.fromJson(jsonDecode(json));
      try {
        final success = await _sendRegistration(registration);
        if (success) {
          // Limpiar archivos locales
          for (String path in registration.fotoPaths) {
            try {
              await File(path).delete();
            } catch (e) {
              debugPrint('Error al eliminar foto $path: $e');
            }
          }
          if (registration.firmaPath != null) {
            try {
              await File(registration.firmaPath!).delete();
            } catch (e) {
              debugPrint('Error al eliminar firma: $e');
            }
          }
        } else {
          stillPending.add(json);
        }
      } catch (e) {
        debugPrint('Error sincronizando registro: $e');
        stillPending.add(json);
      }
    }

    await prefs.setStringList('pendingRegistrations', stillPending);
    if (stillPending.length < pending.length && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registros sincronizados exitosamente'),
          backgroundColor: AppColors.cfeGreen,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<bool> _sendRegistration(TabletRegistration registration) async {
    // Registrar tableta
    final datosTableta = {
      'activo': registration.activo,
      'inventario': registration.inventario,
      'numero_serie': registration.numeroSerie,
      'version_android': registration.versionAndroid,
      'anio_adquisicion': registration.anioAdquisicion,
      'agencia': registration.agencia,
      'proceso': registration.proceso,
      'rpe_trabajador': registration.rpeTrabajador,
      'marca_chip': registration.marcaChip,
      'numero_serie_chip': registration.numeroSerieChip,
      'ubicacion_registro': registration.ubicacionRegistro,
    };

    int retries = 3;
    int delay = 2;

    for (int i = 0; i < retries; i++) {
      try {
        final success = await TabletasApi.registrarTableta(datosTableta);
        if (!success) throw Exception('Error al registrar tableta');
        break;
      } catch (e) {
        if (i < retries - 1) {
          await Future.delayed(Duration(seconds: delay));
          delay *= 2;
        } else {
          throw e;
        }
      }
    }

    // Subir fotos
    bool todasSubidas = true;
    for (int i = 0; i < registration.fotoPaths.length; i++) {
      if (registration.fotoPaths[i].isNotEmpty) {
        for (int j = 0; j < retries; j++) {
          try {
            final fotoSubida = await TabletasApi.subirFoto(
              tabletaId: registration.activo,
              foto: File(registration.fotoPaths[i]),
              fotoIndex: i + 1,
            );
            if (!fotoSubida) todasSubidas = false;
            break;
          } catch (e) {
            if (j < retries - 1) {
              await Future.delayed(Duration(seconds: delay));
              delay *= 2;
            } else {
              todasSubidas = false;
            }
          }
        }
      }
    }

    // Registrar historial y firma si hay trabajador
    if (registration.rpeTrabajador != null) {
      String? firmaRuta;
      if (registration.firmaPath != null) {
        for (int i = 0; i < retries; i++) {
          try {
            firmaRuta =
                'firmas/${registration.activo}_${registration.rpeTrabajador}.png';
            final firmaSubida = await TabletasApi.subirFirma(
              tabletaId: registration.activo,
              rpeTrabajador: registration.rpeTrabajador!,
              firma: File(registration.firmaPath!),
            );
            if (!firmaSubida) throw Exception('Error al subir firma');
            break;
          } catch (e) {
            if (i < retries - 1) {
              await Future.delayed(Duration(seconds: delay));
              delay *= 2;
            } else {
              throw e;
            }
          }
        }
      }

      int historialId = 0;
      for (int i = 0; i < retries; i++) {
        try {
          historialId = await TabletasApi.registrarHistorial(
            activo: registration.activo,
            rpeTrabajador: registration.rpeTrabajador!,
            tipoAsignacion: 'Asignación inicial',
            asignadaPor: registration.asignadaPor,
            firmaRuta: firmaRuta,
          );
          break;
        } catch (e) {
          if (i < retries - 1) {
            await Future.delayed(Duration(seconds: delay));
            delay *= 2;
          } else {
            throw e;
          }
        }
      }

      if (registration.fallas.isNotEmpty) {
        for (var falla in registration.fallas) {
          for (int i = 0; i < retries; i++) {
            try {
              await TabletasApi.registrarFallaHistorial(
                historialId: historialId,
                categoria: falla['categoria']!,
                falla: falla['falla']!,
              );
              break;
            } catch (e) {
              if (i < retries - 1) {
                await Future.delayed(Duration(seconds: delay));
                delay *= 2;
              } else {
                throw e;
              }
            }
          }
        }
      }
    }

    return todasSubidas;
  }
}