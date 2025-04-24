
class TabletRegistration {
  final String activo;
  final String inventario;
  final String numeroSerie;
  final String? versionAndroid;
  final String? anioAdquisicion;
  final String? agencia;
  final String? proceso;
  final String? centroCosto; // Nuevo campo
  final String? rpeTrabajador;
  final String marcaChip;
  final String? numeroSerieChip;
  final String? ubicacionRegistro;
  final List<String> fotoPaths;
  final String? firmaPath;
  final List<Map<String, String>> fallas;
  final String asignadaPor;
  final DateTime timestamp;

  TabletRegistration({
    required this.activo,
    required this.inventario,
    required this.numeroSerie,
    required this.versionAndroid,
    required this.anioAdquisicion,
    required this.agencia,
    required this.proceso,
    this.centroCosto, // Nuevo parámetro
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

  Map<String, dynamic> toJson() {
    return {
      'activo': activo,
      'inventario': inventario,
      'numero_serie': numeroSerie,
      'version_android': versionAndroid,
      'anio_adquisicion': anioAdquisicion,
      'agencia': agencia,
      'proceso': proceso,
      'centro_costo': centroCosto, // Nuevo campo en JSON
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
  }

  factory TabletRegistration.fromJson(Map<String, dynamic> json) {
    return TabletRegistration(
      activo: json['activo'],
      inventario: json['inventario'],
      numeroSerie: json['numero_serie'],
      versionAndroid: json['version_android'],
      anioAdquisicion: json['anio_adquisicion'],
      agencia: json['agencia'],
      proceso: json['proceso'],
      centroCosto: json['centro_costo'], // Nuevo campo en fromJson
      rpeTrabajador: json['rpe_trabajador'],
      marcaChip: json['marca_chip'],
      numeroSerieChip: json['numero_serie_chip'],
      ubicacionRegistro: json['ubicacion_registro'],
      fotoPaths: List<String>.from(json['foto_paths']),
      firmaPath: json['firma_path'],
      fallas: List<Map<String, String>>.from(
        json['fallas'].map((f) => Map<String, String>.from(f)),
      ),
      asignadaPor: json['asignada_por'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}