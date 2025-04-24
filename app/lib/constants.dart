import 'package:flutter/material.dart';

// Colores
class AppColors {
  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color logoutRed = Color(0xFFE53935);
  // Nuevo color para el mapa (opcional, para el fondo del contenedor)
  static const Color mapBackground = Color(0xFFE8F5E9); // Verde claro CFE
}

// Textos
class AppStrings {
  static const String appName = 'Bienvenido';
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
  static const String manageTablets = 'Registrar Tabletas';
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
    'En la pantalla principal, selecciona "Registrar Tabletas" en Acciones Rápidas.',
    'Ingresa los datos requeridos, como el número de activo, número de serie y RPE del trabajador.',
    'Captura las 4 fotos de evidencia: tableta, chip, número de serie visible y firma del trabajador.',
    'Revisa los datos y presiona "Registrar Tableta" para guardar. Verás una confirmación si todo es correcto.',
  ];
  static const String registerTabletTitle = '¿Cómo registrar una tableta?';
  static const String historyTitle = '¿Cómo consultar el historial?';
  static const List<String> historySteps = [
    'Presiona el botón "Historial" en Acciones Rápidas.',
    'Verás la lista de tabletas registradas.',
    'Usa el botón de actualizar si no ves registros recientes.',
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
  static const String signatureConfirmedButton = 'Confirmada';
  static const String signatureConfirmed = 'Firma confirmada correctamente';
  static const String signatureEmptyError =
      'Por favor, dibuje una firma antes de confirmar';
  static const String signatureNotConfirmedError =
      'Por favor, confirme la firma antes de registrar';

  static const String centroCostoLabel = 'Centro de Costo'; // Nueva constante

  // Nuevas constantes para la sección de ubicación
  static const String locationSection = 'Ubicación Actual';
  static const String noLocationAvailable = 'No se pudo obtener la ubicación';
  static const String coordinatesLabel = 'Coordenadas';
  static const String retryLocationButton = 'Reintentar Ubicación';
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
  static const List<String> centroCostoOptions = [
    // Nueva lista de opciones
    'D2910 - D096 Distrib Renac',
    'D2911 - D096 Dist El Treinta',
    'D2912 - D096 Dist San Marcos',
    'D2913 - D096 Distr San Luis',
    'D2914 - D096 Distri Ometepe',
    'D2915 - D096 Comer Renacimi',
    'D2916 - D096 Comer El Treint',
    'D2917 - D096 Com San Marc',
    'D2918 - D096 Com San Luis',
    'D2919 - D096 Serv Com Omete',
    'D2920 - D096 Cont y Con Rena',
    'D2921 - D096 Cont Con El Tre',
    'D2922 - D096 Cont Con San Ma',
    'D2923 - D096 Cont Con San Lu',
    'D2924 - D096 Cont y Con Omet',
    'D2890 - D096 Dirección',
    'D2891 - D096 Planeación',
    'D2892 - D096 Solicitudes y',
    'D2893 - D096 Proyectos y C',
    'D2894 - D096 Operación de',
    'D2895 - D096 Redes aéreas',
    'D2896 - D096 Redes subterr',
    'D2897 - D096 Subestaciones',
    'D2898 - D096 Protecc y Cal',
    'D2899 - D096 Comun y Contr',
    'D2900 - D096 Cont y conexi',
    'D2901 - D096 Aseg de la me',
    'D2902 - D096 Taller de med',
    'D2903 - D096 Integ de cons',
    'D2904 - D096 Comercial cam',
    'D2905 - D096 Finazas',
    'D2906 - D096 Administració',
    'D2907 - D096 Recursos Huma',
    'D2908 - D096 Tec de la inf',
    'D2909 - D096 Juridico',
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
