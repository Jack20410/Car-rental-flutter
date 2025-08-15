import 'environment.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  static AppEnvironment _environment = AppEnvironment.development;

  // ==========================================
  // ENVIRONMENT-SPECIFIC SERVICE URLS
  // ==========================================

  static String get apiUserService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiUserService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiUserService;
      case AppEnvironment.production:
        return Environment.apiUserService;
    }
  }

  static String get apiChatService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiChatService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiChatService;
      case AppEnvironment.production:
        return Environment.apiChatService;
    }
  }

  static String get apiPaymentService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiPaymentService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiPaymentService;
      case AppEnvironment.production:
        return Environment.apiPaymentService;
    }
  }

  static String get apiAdminService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiAdminService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiAdminService;
      case AppEnvironment.production:
        return Environment.apiAdminService;
    }
  }

  static String get apiRentalService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiRentalService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiRentalService;
      case AppEnvironment.production:
        return Environment.apiRentalService;
    }
  }

  static String get apiRatingService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiRatingService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiRatingService;
      case AppEnvironment.production:
        return Environment.apiRatingService;
    }
  }

  static String get apiVehicleService {
    switch (_environment) {
      case AppEnvironment.development:
        return DevEnvironment.apiVehicleService;
      case AppEnvironment.staging:
        return StagingEnvironment.apiVehicleService;
      case AppEnvironment.production:
        return Environment.apiVehicleService;
    }
  }

  // ==========================================
  // DEBUG & MONITORING SETTINGS
  // ==========================================

  static bool get enableDebugMode {
    switch (_environment) {
      case AppEnvironment.development:
        return Environment.enableDebugMode;
      case AppEnvironment.staging:
        return StagingEnvironment.enableDebugMode;
      case AppEnvironment.production:
        return ProdEnvironment.enableDebugMode;
    }
  }

  static bool get enableApiLogging {
    switch (_environment) {
      case AppEnvironment.development:
        return Environment.enableApiLogging;
      case AppEnvironment.staging:
        return StagingEnvironment.enableApiLogging;
      case AppEnvironment.production:
        return ProdEnvironment.enableApiLogging;
    }
  }

  static bool get enablePerformanceMonitoring {
    switch (_environment) {
      case AppEnvironment.development:
        return Environment.enablePerformanceMonitoring;
      case AppEnvironment.staging:
        return StagingEnvironment.enablePerformanceMonitoring;
      case AppEnvironment.production:
        return ProdEnvironment.enablePerformanceMonitoring;
    }
  }

  // ==========================================
  // ENVIRONMENT MANAGEMENT
  // ==========================================

  /// Set the current environment
  static void setEnvironment(AppEnvironment environment) {
    _environment = environment;
  }

  /// Get current environment
  static AppEnvironment get currentEnvironment => _environment;

  // ==========================================
  // VEHICLE SERVICE API METHODS
  // ==========================================

  /// Get vehicles URL with optional filtering
  static String getVehiclesUrl({String? city, Map<String, String>? filters}) {
    String url = '$apiVehicleService/vehicles';
    List<String> queryParams = [];

    if (city != null && city.isNotEmpty) {
      queryParams.add('city=${Uri.encodeComponent(city)}');
    }

    if (filters != null) {
      filters.forEach((key, value) {
        queryParams.add(
          '${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}',
        );
      });
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    return url;
  }

  /// Get specific vehicle URL
  static String getVehicleUrl(String vehicleId) {
    return '$apiVehicleService/vehicles/$vehicleId';
  }

  /// Get ratings URL for a vehicle
  static String getRatingsUrl(String vehicleId) {
    return '$apiRatingService/ratings/$vehicleId';
  }

  /// Get vehicle image URL
  static String getVehicleImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Handle relative image paths from vehicle service
    if (imagePath.startsWith('/')) {
      return '$apiVehicleService$imagePath';
    }

    return '$apiVehicleService/uploads/vehicles/$imagePath';
  }

  // ==========================================
  // OTHER SERVICE API METHODS
  // ==========================================

  /// Get auth URL
  static String getAuthUrl() {
    return '$apiUserService/auth';
  }

  /// Get users URL
  static String getUsersUrl() {
    return '$apiUserService/users';
  }

  /// Get chat URL
  static String getChatUrl() {
    return '$apiChatService/chat';
  }

  /// Get payment URL
  static String getPaymentUrl() {
    return '$apiPaymentService/payment';
  }

  /// Get admin URL
  static String getAdminUrl() {
    return '$apiAdminService/admin';
  }

  /// Get rental URL
  static String getRentalUrl() {
    return '$apiRentalService/rental';
  }

  // ==========================================
  // LEGACY COMPATIBILITY METHODS
  // ==========================================

  /// Legacy method for backward compatibility
  @Deprecated('Use getVehicleImageUrl instead')
  static String getImageUrl(String imagePath) {
    return getVehicleImageUrl(imagePath);
  }

  // ==========================================
  // APP INITIALIZATION
  // ==========================================

  /// Initialize app configuration
  static void initialize({AppEnvironment? environment}) {
    if (environment != null) {
      setEnvironment(environment);
    }

    // Log current configuration in debug mode
    if (enableDebugMode) {
      print('🔧 App Configuration Initialized:');
      print('Environment: ${_environment.name}');
      print('Vehicle Service: $apiVehicleService');
      print('User Service: $apiUserService');
      print('Rating Service: $apiRatingService');
      print('Debug Mode: $enableDebugMode');
      print('API Logging: $enableApiLogging');
      print('Performance Monitoring: $enablePerformanceMonitoring');
    }
  }

  // ==========================================
  // APP CONSTANTS
  // ==========================================

  /// Get app name
  static String get appName => Environment.appName;

  /// Get app version
  static String get appVersion => Environment.appVersion;

  /// Get default timeout
  static int get defaultTimeout => Environment.defaultTimeout;

  /// Get max featured cars
  static int get maxFeaturedCars => Environment.maxFeaturedCars;

  /// Get grid cross axis count
  static int get gridCrossAxisCount => Environment.gridCrossAxisCount;

  /// Get grid child aspect ratio
  static double get gridChildAspectRatio => Environment.gridChildAspectRatio;

  /// Get carousel auto play interval
  static int get carouselAutoPlayInterval =>
      Environment.carouselAutoPlayInterval;

  /// Get currency symbol
  static String get currencySymbol => Environment.currencySymbol;

  /// Get currency code
  static String get currencyCode => Environment.currencyCode;

  /// Get price unit
  static String get priceUnit => Environment.priceUnit;
}
