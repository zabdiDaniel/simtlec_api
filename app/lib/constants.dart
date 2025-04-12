import 'package:flutter/material.dart';

// Colores
class AppColors {
  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(
    0xFFD32F2F,
  ); // Actualizado de Colors.red
  static const Color textSecondary = Color(0xFF757575);
  static const Color logoutRed = Color(0xFFE53935);
}

// Textos
class AppStrings {
  static const String appName = 'SIMTLEC';
  static const String version = 'Ver. 1.0.0';
  static const String systemName = 'Sistema de Inventario de Tabletas CFE';
  static const String loginButton = 'Ingresar';
  static const String rpeLabel = 'RPE';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Contraseña';
  static const String connectionTesting = 'Probando conexión...';
  static const String connectionSuccess = '✅ Conexión exitosa';
  static const String connectionFailed = '❌ Sin conexión al servidor';
  static const String checkInternet = 'Verifica tu conexión a internet';
  static const String invalidEmail = 'Correo no válido';
  static const String emptyField = 'Este campo es obligatorio';
  static const String connectionTap = 'Presiona para probar conexión';
  static const String connectionError = '❌ Error: %s';
  static const String welcomeMessage = 'Bienvenido/a';
  static const String manageTablets = 'Administrar Tabletas';
  static const String quickActions = 'Acciones Rápidas';
  static const String profileLabel = 'Perfil';
  static const String historyLabel = 'Historial';
  static const String helpLabel = 'Ayuda';
  static const String logoutTitle = 'Cerrar Sesión';
  static const String logoutMessage =
      '¿Estás seguro de que deseas salir de la aplicación?';
  static const String cancelButton = 'Cancelar';
  static const String logoutButton = 'Salir';
  static const String locationError =
      'Por favor, activa los servicios de ubicación';
  static const String helpTitle = 'Ayuda';
  static const List<String> registerTabletSteps = [
    '1. Presiona el botón "Administrar Tabletas".',
    '2. Completa todos los campos obligatorios.',
    '3. Toma las 4 fotos de evidencia requeridas.',
    '4. Presiona "Registrar" para guardar los datos.',
  ];
  static const String registerTabletTitle = '¿Cómo registrar una tableta?';
  static const String historyTitle = '¿Cómo consultar el historial?';
  static const List<String> historySteps = [
    '1. Presiona el botón "Historial" en Acciones Rápidas.',
    '2. Verás la lista de tabletas registradas.',
    '3. Usa el botón de actualizar si no ves registros recientes.',
  ];
  static const String supportTitle = 'Soporte técnico';
  static const List<String> supportSteps = [
    'Para problemas con la app, contacta al área de TI:',
    'Correo: soporte-tecnico@cfe.mx',
    'Teléfono: 555-123-4567',
  ];
  static const String profileTitle = 'Mi Perfil';
  static const String errorLoadingProfile = 'Error al cargar perfil:\n%s';
  static const String retryButton = 'Reintentar';
  static const String noUserData = 'No se encontraron datos del usuario';
  static const String tryAgainButton = 'Intentar nuevamente';
  static const String emailTitle = 'Correo electrónico';
  static const String userTypeTitle = 'Tipo de usuario';
  static const String registerDateTitle = 'Fecha de registro';
  static const String notSpecified = 'No especificado';
  static const String historyScreenTitle = 'Historial de Asignaciones';
  static const String refreshTooltip = 'Actualizar';
  static const String errorLoadingHistory = 'Error al cargar el historial:\n%s';
  static const String noHistoryMessage =
      'No has registrado ninguna tableta todavía';
  static const String updateButton = 'Actualizar';
  static const String tabletLabel = 'Tableta:';
  static const String assignedToLabel = 'Asignada a:';
  static const String startDateLabel = 'Fecha inicio:';
  static const String endDateLabel = 'Fecha fin:';
  static const String typeLabel = 'Tipo:';
  static const String observationsLabel = 'Observaciones:';
  static const String activeLabel = 'Activa';
  static const String finishedLabel = 'Finalizada';
  // Nuevos para TabletRegistrationScreen
  static const String registrationTitle = 'Registro de Tableta';
  static const String fixedInfoSection = 'Información Fija';
  static const String detailsSection = 'Detalles';
  static const String chipInfoSection = 'Información del Chip';
  static const String photosSection = 'Evidencia Fotográfica';
  static const String assignmentSection = 'Asignación';
  static const String observationsSection = 'Observaciones';
  static const String brandLabel = 'Marca';
  static const String modelLabel = 'Modelo';
  static const String fixedBrand = 'NEWLAND';
  static const String fixedModel = 'NLS-NFT10';
  static const String assetNumberLabel = 'Número de Activo';
  static const String inventoryNumberLabel = 'Número de Inventario';
  static const String serialNumberLabel = 'Número de Serie';
  static const String androidVersionLabel = 'Versión Android';
  static const String acquisitionYearLabel = 'Año de Adquisición';
  static const String agencyLabel = 'Agencia';
  static const String processLabel = 'Proceso';
  static const String chipBrandLabel = 'Marca del Chip';
  static const String chipSerialNumberLabel = 'Número de Serie del Chip';
  static const String fixedChipBrand = 'Telcel';
  static const String workerRpeLabel = 'RPE del Trabajador';
  static const String searchButton = 'Buscar';
  static const String registerButton = 'Registrar Tableta';
  static const String requiredFieldError = 'Requerido';
  static const String assetNumberLengthError =
      'Debe tener exactamente 8 caracteres';
  static const String errorTakingPhoto = 'Error al tomar foto';
  static const String formValidationError =
      'Por favor, corrige los errores en el formulario';
  static const String missingPhotosError =
      'Debe tomar las 4 fotos de evidencia';
  static const String invalidWorkerRpeError = 'Verifique el RPE del trabajador';
  static const String emptyRpeError = 'Ingrese un RPE para buscar';
  static const String permissionDeniedError = 'Permiso de ubicación denegado';
  static const String permissionDeniedForeverError =
      'Permiso de ubicación denegado permanentemente';
  static const String locationFetchError = 'Error al obtener la ubicación';
  static const String registrationSuccess = 'Registro completo exitoso';
  static const String registrationPartialSuccess =
      'Tablet registrada pero algunas fotos no se subieron';
  static const String registrationError = 'Error en el registro: %s';
  static const String signatureSection = 'Firma del Trabajador';
  static const String signatureRequiredError =
      'Se requiere la firma del trabajador';
  static const String clearSignatureButton = 'Limpiar';
  static const String signatureUploadError = 'Error al subir la firma';
  static const String confirmSignatureButton = 'Confirmar';
  static const String signatureConfirmedButton = 'Confirmada'; // Nueva constante
  static const String signatureConfirmed = 'Firma confirmada correctamente';
  static const String signatureEmptyError = 'Por favor, dibuje una firma antes de confirmar';
  static const String signatureNotConfirmedError = 'Por favor, confirme la firma antes de registrar';
  // Opciones estáticas
  static const List<String> androidOptions = ['8.1', '11'];
  static const List<String> anioOptions = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
  ];
  static const List<String> agenciaOptions = [
    'EL TREINTA',
    'RENACIMIENTO',
    'SUBESTACIONES RENACIMIENTO',
    'GARITA',
    'CUAUHTEMOC',
    'VISTA ALEGRE',
    'EJIDO',
    'OFICINAS DE ZONA',
    'SUBESTACIONES ACAPULCO COSTA AZUL',
    'DIAMANTE - AMATES',
    'RENACIMIENTO SUR',
    'SAN MARCOS',
    'SAN LUIS ACATLAN',
    'OMETEPEC',
  ];
  static const List<String> procesoOptions = [
    'COMERCIAL',
    'ISC',
    'DISTRIBUCION',
    'MEDICION',
    'ADMINISTRACION',
    'TICS',
  ];
}

// Validaciones (actualizadas)
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emptyField;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? validateRpe(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emptyField;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emptyField;
    }
    return null;
  }

  static String? validateAssetNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    if (value.length != 8) {
      return AppStrings.assetNumberLengthError;
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredFieldError;
    }
    return null;
  }
}
