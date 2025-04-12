import 'package:flutter/material.dart';
import '../api/tabletas_api.dart';
import '../constants.dart';
import 'historial_content.dart';

class HistorialScreen extends StatefulWidget {
  final String rpeRegistrador;

  const HistorialScreen({super.key, required this.rpeRegistrador});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<dynamic>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _historialFuture = TabletasApi.obtenerHistorialAsignaciones(
        widget.rpeRegistrador,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          AppStrings.historyScreenTitle,
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: AppStrings.refreshTooltip,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.cfeGreen,
        child: FutureBuilder<List<dynamic>>(
          future: _historialFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.cfeGreen),
              );
            }

            return HistorialContent(
              asignaciones: snapshot.data,
              error: snapshot.hasError ? snapshot.error.toString() : null,
              onRetry: _loadData,
            );
          },
        ),
      ),
    );
  }
}
