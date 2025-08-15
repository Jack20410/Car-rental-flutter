// Example: How to use different environments in your app

import 'app_config.dart';

void demonstrateEnvironmentUsage() {
  print('=== Environment Configuration Demo ===\n');

  // 1. Development Environment (default)
  AppConfig.setEnvironment(AppEnvironment.development);
  print('1. Development Environment:');
  print('   Base URL: ${AppConfig.baseUrl}');
  print('   Image URL: ${AppConfig.imageBaseUrl}');
  print('   Debug Mode: ${AppConfig.enableDebugMode}');
  print('   API Logging: ${AppConfig.enableApiLogging}');
  print('   Vehicles URL: ${AppConfig.getVehiclesUrl()}');
  print(
    '   Vehicles with City: ${AppConfig.getVehiclesUrl(city: "Ho Chi Minh City")}',
  );
  print('   Ratings URL: ${AppConfig.getRatingsUrl("12345")}');
  print('');

  // 2. Staging Environment
  AppConfig.setEnvironment(AppEnvironment.staging);
  print('2. Staging Environment:');
  print('   Base URL: ${AppConfig.baseUrl}');
  print('   Image URL: ${AppConfig.imageBaseUrl}');
  print('   Debug Mode: ${AppConfig.enableDebugMode}');
  print('   API Logging: ${AppConfig.enableApiLogging}');
  print('');

  // 3. Production Environment
  AppConfig.setEnvironment(AppEnvironment.production);
  print('3. Production Environment:');
  print('   Base URL: ${AppConfig.baseUrl}');
  print('   Image URL: ${AppConfig.imageBaseUrl}');
  print('   Debug Mode: ${AppConfig.enableDebugMode}');
  print('   API Logging: ${AppConfig.enableApiLogging}');
  print('');

  // 4. Image URL examples
  AppConfig.setEnvironment(AppEnvironment.development);
  print('4. Image URL Examples:');
  print(
    '   Full URL: ${AppConfig.getImageUrl("https://example.com/image.jpg")}',
  );
  print('   Relative path: ${AppConfig.getImageUrl("/uploads/cars/car1.jpg")}');
  print(
    '   Local path: ${AppConfig.getImageUrl("assets/images/placeholder.jpg")}',
  );
  print('');

  print('=== Usage in Your Code ===');
  print('// In your API calls:');
  print(
    'final response = await http.get(Uri.parse(AppConfig.getVehiclesUrl()));',
  );
  print('');
  print('// For images:');
  print('CachedNetworkImage(imageUrl: AppConfig.getImageUrl(car.imagePath))');
  print('');
  print('// For debugging:');
  print('if (AppConfig.enableDebugMode) { print("Debug info"); }');
}

// Example of how to switch environments based on build type
class EnvironmentHelper {
  static void initializeForBuildType() {
    // You can determine environment based on:
    // 1. Build configuration
    // 2. Command line arguments
    // 3. Environment variables
    // 4. Configuration files

    const isProduction = bool.fromEnvironment('dart.vm.product');
    const buildType = String.fromEnvironment('BUILD_TYPE', defaultValue: 'dev');

    if (isProduction) {
      AppConfig.initialize(environment: AppEnvironment.production);
    } else if (buildType == 'staging') {
      AppConfig.initialize(environment: AppEnvironment.staging);
    } else {
      AppConfig.initialize(environment: AppEnvironment.development);
    }
  }
}
