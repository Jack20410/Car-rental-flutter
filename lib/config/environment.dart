class Environment {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String imageBaseUrl = 'http://10.0.2.2:3002';

  // API Endpoints
  static const String vehiclesEndpoint = '/vehicles';
  static const String ratingsEndpoint = '/ratings';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';

  // App Configuration
  static const String appName = 'Car Rental App';
  static const String appVersion = '1.0.0';

  // Default Settings
  static const int defaultTimeout = 30; // seconds
  static const int carouselAutoPlayInterval = 3; // seconds
  static const int maxFeaturedCars = 6;
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;

  // Vietnamese Currency Settings
  static const String currencySymbol = '₫';
  static const String currencyCode = 'VND';
  static const String priceUnit = '/day';

  // Image Settings
  static const int imageQuality = 80;
  static const int maxImageCacheSize = 100; // MB

  // Debug Settings
  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true;
  static const bool enablePerformanceMonitoring = false;

  // Build full API URLs
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
    String url = getApiUrl(vehiclesEndpoint);
    if (city != null && city.isNotEmpty) {
      url += '?city=${Uri.encodeComponent(city)}';
    }
    return url;
  }

  static String getRatingsUrl(String vehicleId) {
    return getApiUrl('$ratingsEndpoint/$vehicleId');
  }
}

// Development Environment
class DevEnvironment extends Environment {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String imageBaseUrl = 'http://10.0.2.2:3002';
  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true;
}

// Production Environment
class ProdEnvironment extends Environment {
  static const String baseUrl = 'https://your-api-domain.com';
  static const String imageBaseUrl = 'https://your-image-domain.com';
  static const bool enableDebugMode = false;
  static const bool enableApiLogging = false;
  static const bool enablePerformanceMonitoring = true;
}

// Staging Environment
class StagingEnvironment extends Environment {
  static const String baseUrl = 'https://staging-api-domain.com';
  static const String imageBaseUrl = 'https://staging-image-domain.com';
  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true;
  static const bool enablePerformanceMonitoring = true;
}
