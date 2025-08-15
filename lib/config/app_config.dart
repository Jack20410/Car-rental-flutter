import 'environment.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  static AppEnvironment _environment = AppEnvironment.development;

  // Current environment settings
  static String get baseUrl {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.baseUrl;
      case AppEnvironment.staging:
        return StagingEnvironment.baseUrl;
      case AppEnvironment.production:
        return ProdEnvironment.baseUrl;
    }
  }

  static String get imageBaseUrl {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.imageBaseUrl;
      case AppEnvironment.staging:
        return StagingEnvironment.imageBaseUrl;
      case AppEnvironment.production:
        return ProdEnvironment.imageBaseUrl;
    }
  }

  static bool get enableDebugMode {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.enableDebugMode;
      case AppEnvironment.staging:
        return StagingEnvironment.enableDebugMode;
      case AppEnvironment.production:
        return ProdEnvironment.enableDebugMode;
    }
  }

  static bool get enableApiLogging {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.enableApiLogging;
      case AppEnvironment.staging:
        return StagingEnvironment.enableApiLogging;
      case AppEnvironment.production:
        return ProdEnvironment.enableApiLogging;
    }
  }

  // Set environment
  static void setEnvironment(AppEnvironment environment) {
    _environment = environment;
  }

  // Get current environment
  static AppEnvironment get currentEnvironment => _environment;

  // Helper methods
  static String getApiUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$imageBaseUrl$imagePath';
  }

  static String getVehiclesUrl({String? city}) {
    String url = getApiUrl(Environment.vehiclesEndpoint);
    if (city != null && city.isNotEmpty) {
      url += '?city=${Uri.encodeComponent(city)}';
    }
    return url;
  }

  static String getRatingsUrl(String vehicleId) {
    return getApiUrl('${Environment.ratingsEndpoint}/$vehicleId');
  }

  // Initialize app configuration
  static void initialize({AppEnvironment? environment}) {
    if (environment != null) {
      setEnvironment(environment);
    }

    // Log current configuration in debug mode
    if (enableDebugMode) {
      print('🔧 App Configuration:');
      print('Environment: ${_environment.name}');
      print('Base URL: $baseUrl');
      print('Image URL: $imageBaseUrl');
      print('Debug Mode: $enableDebugMode');
      print('API Logging: $enableApiLogging');
    }
  }
}
