class ApiConfig {
  // Solo cambias esta línea cuando lleguen a la casa de tu amigo
  static const String baseUrl = "http://192.168.100.164:8000";

  // Rutas automáticas
  static const String loginUrl = "$baseUrl/login";
  static const String registroUrl = "$baseUrl/registro_animo";
  static const String historialUrl = "$baseUrl/historial_animo";
}
