import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';

class TabletRegistrationContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController activoController;
  final TextEditingController inventarioController;
  final TextEditingController serieController;
  final TextEditingController trabajadorController;
  final TextEditingController chipSerieController;
  final String? selectedAndroid;
  final String? selectedAnio;
  final String? selectedAgencia;
  final String? selectedProceso;
  final Map<String, dynamic>? trabajadorAsignado;
  final List<File?> fotos;
  final String? selectedCategoriaFalla;
  final Map<String, Map<String, bool>> fallasPorCategoria;
  final SignatureController signatureController;
  final bool isSignatureConfirmed;
  final Function(String?) onAndroidChanged;
  final Function(String?) onAnioChanged;
  final Function(String?) onAgenciaChanged;
  final Function(String?) onProcesoChanged;
  final Function(int) onTakePhoto;
  final Function onSearchWorker;
  final Function(String?) onCategoriaFallaChanged;
  final Function(String, bool) onFallaChanged;
  final Function onRegister;
  final Function onClearSignature;
  final Function onConfirmSignature;
  final LatLng? currentLocation;
  final VoidCallback onRetryLocation;
  final bool isLocationLoading; // Nuevo parámetro para estado de carga

  const TabletRegistrationContent({
    Key? key,
    required this.formKey,
    required this.activoController,
    required this.inventarioController,
    required this.serieController,
    required this.trabajadorController,
    required this.chipSerieController,
    required this.selectedAndroid,
    required this.selectedAnio,
    required this.selectedAgencia,
    required this.selectedProceso,
    required this.trabajadorAsignado,
    required this.fotos,
    required this.selectedCategoriaFalla,
    required this.fallasPorCategoria,
    required this.signatureController,
    required this.isSignatureConfirmed,
    required this.onAndroidChanged,
    required this.onAnioChanged,
    required this.onAgenciaChanged,
    required this.onProcesoChanged,
    required this.onTakePhoto,
    required this.onSearchWorker,
    required this.onCategoriaFallaChanged,
    required this.onFallaChanged,
    required this.onRegister,
    required this.onClearSignature,
    required this.onConfirmSignature,
    this.currentLocation,
    required this.onRetryLocation,
    required this.isLocationLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(AppStrings.fixedInfoSection, _buildInfoFija()),
          const SizedBox(height: 20),
          _buildSection(AppStrings.detailsSection, _buildDetallesForm()),
          const SizedBox(height: 20),
          _buildSection(AppStrings.chipInfoSection, _buildChipForm()),
          const SizedBox(height: 20),
          _buildSection(AppStrings.photosSection, _buildFotosGrid()),
          const SizedBox(height: 20),
          _buildSection(AppStrings.assignmentSection, _buildAsignacionForm()),
          if (trabajadorAsignado != null) ...[
            const SizedBox(height: 20),
            _buildSection(AppStrings.signatureSection, _buildSignatureField()),
          ],
          const SizedBox(height: 20),
          _buildSection(AppStrings.locationSection, _buildLocationSection()),
          const SizedBox(height: 20),
          _buildSection(AppStrings.observationsSection, _buildObservacionesField()),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.cfeDarkGreen,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        ),
      ],
    );
  }

  Widget _buildInfoFija() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(AppStrings.brandLabel, AppStrings.fixedBrand),
        _buildInfoItem(AppStrings.modelLabel, AppStrings.fixedModel),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDetallesForm() {
    return Column(
      children: [
        _buildTextField(
          activoController,
          AppStrings.assetNumberLabel,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          inventarioController,
          AppStrings.inventoryNumberLabel,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          serieController,
          AppStrings.serialNumberLabel,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          AppStrings.androidVersionLabel,
          AppStrings.androidOptions,
          selectedAndroid,
          onAndroidChanged,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          AppStrings.acquisitionYearLabel,
          AppStrings.anioOptions,
          selectedAnio,
          onAnioChanged,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          AppStrings.agencyLabel,
          AppStrings.agenciaOptions,
          selectedAgencia,
          onAgenciaChanged,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          AppStrings.processLabel,
          AppStrings.procesoOptions,
          selectedProceso,
          onProcesoChanged,
          required: true,
        ),
      ],
    );
  }

  Widget _buildChipForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.chipBrandLabel,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.fixedChipBrand,
              style: const TextStyle(
                color: AppColors.cfeDarkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          chipSerieController,
          AppStrings.chipSerialNumberLabel,
          required: false,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cfeGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      inputFormatters: label == AppStrings.assetNumberLabel
          ? [LengthLimitingTextInputFormatter(8)]
          : null,
      autovalidateMode: label == AppStrings.assetNumberLabel
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: label == AppStrings.assetNumberLabel
          ? AppValidators.validateAssetNumber
          : (required ? AppValidators.validateRequired : null),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cfeGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? AppStrings.requiredFieldError : null
          : null,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildFotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onTakePhoto(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            image: fotos[index] != null
                ? DecorationImage(
                    image: FileImage(fotos[index]!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: fotos[index] == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto ${index + 1}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAsignacionForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                trabajadorController,
                AppStrings.workerRpeLabel,
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => onSearchWorker(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cfeGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                elevation: 0,
              ),
              child: const Text(
                AppStrings.searchButton,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        if (trabajadorAsignado != null) ...[
          const SizedBox(height: 16),
          _buildTrabajadorInfo(),
        ],
      ],
    );
  }

  Widget _buildTrabajadorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cfeGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cfeGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(
              'https://sistemascfe.com/cfe-api/uploads/perfiles/${trabajadorAsignado!['foto_perfil']}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trabajadorAsignado!['nombre'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RPE: ${trabajadorAsignado!['rpe']}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  trabajadorAsignado!['cargo'],
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  trabajadorAsignado!['agencia'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IgnorePointer(
            ignoring: isSignatureConfirmed,
            child: Signature(
              controller: signatureController,
              height: 200,
              backgroundColor: Colors.grey[100]!,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: isSignatureConfirmed ? null : () => onConfirmSignature(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cfeGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: Text(
                isSignatureConfirmed
                    ? AppStrings.signatureConfirmedButton
                    : AppStrings.confirmSignatureButton,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => onClearSignature(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                AppStrings.clearSignatureButton,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return AnimatedOpacity(
      opacity: isLocationLoading || currentLocation != null ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLocationLoading) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cfeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cfeGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.cfeGreen),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Obteniendo ubicación...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (currentLocation == null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.errorColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.noLocationAvailable,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetryLocation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cfeGreen,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cfeGreen.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.retryLocationButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            AnimatedSlide(
              offset: currentLocation != null ? Offset.zero : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cfeGreen.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.cfeGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lat: ${currentLocation!.latitude.toStringAsFixed(4)}, '
                      'Lon: ${currentLocation!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AnimatedOpacity(
                opacity: currentLocation != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.mapBackground,
                    border: Border.all(color: AppColors.cfeGreen, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: currentLocation ?? const LatLng(0, 0),
                      initialZoom: 14.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
                      ),
                      keepAlive: true,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        tileProvider: CachedTileProvider(),
                        maxZoom: 19,
                        errorTileCallback: (tile, error, stackTrace) {
                          print('Error loading tile: $error');
                        },
                      ),
                      MarkerLayer(
                        markers: [
                          if (currentLocation != null)
                            Marker(
                              point: currentLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: AppColors.cfeDarkGreen,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObservacionesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedCategoriaFalla,
          decoration: InputDecoration(
            labelText: 'Categoría de falla',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cfeGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: fallasPorCategoria.keys
              .map(
                (categoria) => DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria),
                ),
              )
              .toList(),
          onChanged: onCategoriaFallaChanged,
          hint: const Text('Seleccione una categoría'),
        ),
        if (selectedCategoriaFalla != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Fallas específicas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.cfeDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...fallasPorCategoria[selectedCategoriaFalla]!.entries.map((entry) {
            final falla = entry.key;
            final seleccionada = entry.value;
            return CheckboxListTile(
              title: Text(falla, style: const TextStyle(fontSize: 14)),
              value: seleccionada,
              onChanged: (bool? value) => onFallaChanged(falla, value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              dense: true,
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () => onRegister(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cfeGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
        elevation: 0,
      ),
      child: const Text(
        AppStrings.registerButton,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Proveedor de tiles con cacheo para optimizar rendimiento
class CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coord, TileLayer options) {
    return NetworkImage(getTileUrl(coord, options));
  }
}