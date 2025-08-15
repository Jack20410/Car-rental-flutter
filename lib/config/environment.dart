/// Environment configuration for the Car Rental App
///
/// This file contains all environment-specific configurations including
/// API endpoints, app settings, and environment overrides for development,
/// staging, and production.
library;

class Environment {
  // ==========================================
  // MICROSERVICE API CONFIGURATIONS
  // ==========================================

  /// Production API Service URLs
  static const String apiUserService =
      'https://car-rental-user-service-m84z.onrender.com';
  static const String apiChatService =
      'https://car-rental-chat-service-m84z.onrender.com';
  static const String apiPaymentService =
      'https://car-rental-payment-service-m84z.onrender.com';
  static const String apiAdminService =
      'https://car-rental-admin-service-m84z.onrender.com';
  static const String apiRentalService =
      'https://car-rental-rental-service-m84z.onrender.com';
  static const String apiRatingService =
      'https://car-rental-rating-service-m84z.onrender.com';
  static const String apiVehicleService =
      'https://car-rental-vehicle-service-m84z.onrender.com';

  // ==========================================
  // APPLICATION METADATA
  // ==========================================

  static const String appName = 'Car Rental App';
  static const String appVersion = '1.0.0';

  // ==========================================
  // API & NETWORK SETTINGS
  // ==========================================

  /// Default timeout for API requests in seconds
  static const int defaultTimeout = 30;

  // ==========================================
  // UI & DISPLAY SETTINGS
  // ==========================================

  /// Carousel auto-play interval in seconds
  static const int carouselAutoPlayInterval = 3;

  /// Maximum number of featured cars to display
  static const int maxFeaturedCars = 6;

  /// Grid layout configuration
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;

  // ==========================================
  // LOCALIZATION & CURRENCY
  // ==========================================

  /// Vietnamese currency configuration
  static const String currencySymbol = '₫';
  static const String currencyCode = 'VND';
  static const String priceUnit = '/day';

  // ==========================================
  // IMAGE & MEDIA SETTINGS
  // ==========================================

  /// Image quality for uploads (1-100)
  static const int imageQuality = 80;

  /// Maximum image cache size in MB
  static const int maxImageCacheSize = 100;

  // ==========================================
  // DEBUG & MONITORING
  // ==========================================

  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true;
  static const bool enablePerformanceMonitoring = false;

  // ==========================================
  // VEHICLE SERVICE API METHODS
  // ==========================================

  /// Get all vehicles with optional filtering
  ///
  /// [city] Filter by city name
  /// [filters] Additional query parameters for filtering
  ///
  /// Returns: Complete URL for vehicles endpoint
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

  /// Get specific vehicle by ID
  static String getVehicleUrl(String vehicleId) {
    return '$apiVehicleService/vehicles/$vehicleId';
  }

  /// Create new vehicle endpoint
  static String getCreateVehicleUrl() {
    return '$apiVehicleService/vehicles';
  }

  /// Update vehicle endpoint
  static String getUpdateVehicleUrl(String vehicleId) {
    return '$apiVehicleService/vehicles/$vehicleId';
  }

  /// Update vehicle status endpoint
  static String getUpdateVehicleStatusUrl(String vehicleId) {
    return '$apiVehicleService/vehicles/$vehicleId/status';
  }

  /// Delete vehicle endpoint
  static String getDeleteVehicleUrl(String vehicleId) {
    return '$apiVehicleService/vehicles/$vehicleId';
  }

  /// Delete vehicle image endpoint
  static String getDeleteVehicleImageUrl(String vehicleId) {
    return '$apiVehicleService/vehicles/$vehicleId/images';
  }

  /// Build proper image URL from various path formats
  ///
  /// Handles:
  /// - Full HTTP URLs (returned as-is)
  /// - Relative paths starting with '/' (prefixed with service URL)
  /// - Image filenames (routed to uploads/vehicles/)
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

  /// Rating service endpoints
  static String getRatingsUrl(String vehicleId) {
    return '$apiRatingService/ratings/$vehicleId';
  }

  /// Get average rating for a vehicle (more efficient)
  static String getAverageRatingUrl(String vehicleId) {
    return '$apiRatingService/$vehicleId/average';
  }

  /// Get all ratings for a vehicle
  static String getAllVehicleRatingsUrl(String vehicleId) {
    return '$apiRatingService/$vehicleId';
  }

  /// Submit new rating
  static String getSubmitRatingUrl() {
    return '$apiRatingService';
  }

  /// Get ratings by user
  static String getUserRatingsUrl(String userId) {
    return '$apiRatingService/user/$userId';
  }

  /// Get ratings by provider
  static String getProviderRatingsUrl(String providerId) {
    return '$apiRatingService/by-provider/$providerId';
  }

  /// Get rating for specific rental
  static String getRentalRatingUrl(String rentalId) {
    return '$apiRatingService/by-rental/$rentalId';
  }

  /// User service endpoints
  static String getUsersUrl() {
    return '$apiUserService/users';
  }

  static String getAuthUrl() {
    return '$apiUserService/auth';
  }

  /// Chat service endpoints
  static String getChatUrl() {
    return '$apiChatService/chat';
  }

  /// Payment service endpoints
  static String getPaymentUrl() {
    return '$apiPaymentService/payment';
  }

  /// Admin service endpoints
  static String getAdminUrl() {
    return '$apiAdminService/admin';
  }

  /// Rental service endpoints
  static String getRentalUrl() {
    return '$apiRentalService/rental';
  }
}

// ==========================================
// ENVIRONMENT OVERRIDES
// ==========================================

/// Development Environment Configuration
///
/// Override URLs for local development with Android emulator
class DevEnvironment extends Environment {
  // Local development service URLs (Android emulator)
  static const String apiUserService = 'http://10.0.2.2:3001';
  static const String apiChatService = 'http://10.0.2.2:3002';
  static const String apiPaymentService = 'http://10.0.2.2:3003';
  static const String apiAdminService = 'http://10.0.2.2:3004';
  static const String apiRentalService = 'http://10.0.2.2:3005';
  static const String apiRatingService = 'http://10.0.2.2:3006';
  static const String apiVehicleService = 'http://10.0.2.2:3000';
}

/// Production Environment Configuration
///
/// Uses production URLs with optimized settings
class ProdEnvironment extends Environment {
  // Production-optimized settings
  static const bool enableDebugMode = false;
  static const bool enableApiLogging = false;
  static const bool enablePerformanceMonitoring = true;
}

/// Staging Environment Configuration
///
/// Staging environment with debug capabilities enabled
class StagingEnvironment extends Environment {
  // Staging service URLs
  static const String apiUserService =
      'https://staging-car-rental-user-service.onrender.com';
  static const String apiChatService =
      'https://staging-car-rental-chat-service.onrender.com';
  static const String apiPaymentService =
      'https://staging-car-rental-payment-service.onrender.com';
  static const String apiAdminService =
      'https://staging-car-rental-admin-service.onrender.com';
  static const String apiRentalService =
      'https://staging-car-rental-rental-service.onrender.com';
  static const String apiRatingService =
      'https://staging-car-rental-rating-service.onrender.com';
  static const String apiVehicleService =
      'https://staging-car-rental-vehicle-service.onrender.com';

  // Staging-specific settings
  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true;
  static const bool enablePerformanceMonitoring = true;
}
