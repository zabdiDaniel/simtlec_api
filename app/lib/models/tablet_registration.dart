
class TabletRegistration {
  final String activo;
  final String inventario;
  final String numeroSerie;
  final String? versionAndroid;
  final String? anioAdquisicion;
  final String? agencia;
  final String? proceso;
  final String? rpeTrabajador;
  final String marcaChip;
  final String? numeroSerieChip;
  final String? ubicacionRegistro; // Lat,lon
  final List<String> fotoPaths; // Rutas locales de las fotos
  final String? firmaPath; // Ruta local de la firma
  final List<Map<String, String>> fallas; // Lista de {categoria, falla}
  final String asignadaPor; // RPE del registrador
  final DateTime timestamp;

  TabletRegistration({
    required this.activo,
    required this.inventario,
    required this.numeroSerie,
    this.versionAndroid,
    this.anioAdquisicion,
    this.agencia,
    this.proceso,
    this.rpeTrabajador,
    required this.marcaChip,
    this.numeroSerieChip,
    this.ubicacionRegistro,
    required this.fotoPaths,
    this.firmaPath,
    required this.fallas,
    required this.asignadaPor,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'activo': activo,
        'inventario': inventario,
        'numero_serie': numeroSerie,
        'version_android': versionAndroid,
        'anio_adquisicion': anioAdquisicion,
        'agencia': agencia,
        'proceso': proceso,
        'rpe_trabajador': rpeTrabajador,
        'marca_chip': marcaChip,
        'numero_serie_chip': numeroSerieChip,
        'ubicacion_registro': ubicacionRegistro,
        'foto_paths': fotoPaths,
        'firma_path': firmaPath,
        'fallas': fallas,
        'asignada_por': asignadaPor,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TabletRegistration.fromJson(Map<String, dynamic> json) =>
      TabletRegistration(
        activo: json['activo'],
        inventario: json['inventario'],
        numeroSerie: json['numero_serie'],
        versionAndroid: json['version_android'],
        anioAdquisicion: json['anio_adquisicion'],
        agencia: json['agencia'],
        proceso: json['proceso'],
        rpeTrabajador: json['rpe_trabajador'],
        marcaChip: json['marca_chip'],
        numeroSerieChip: json['numero_serie_chip'],
        ubicacionRegistro: json['ubicacion_registro'],
        fotoPaths: List<String>.from(json['foto_paths']),
        firmaPath: json['firma_path'],
        fallas: List<Map<String, String>>.from(
            json['fallas'].map((x) => Map<String, String>.from(x))),
        asignadaPor: json['asignada_por'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}