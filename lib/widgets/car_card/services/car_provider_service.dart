import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config/environment.dart';
import '../../../models/car.dart';

class CarProviderService {
  /// Fetches provider name with clean error handling and fallback logic
  static Future<String> fetchProviderName(Car car) async {
    // Return early if provider info is already available
    if (_hasProviderInfo(car)) {
      return car.carProvider!.fullName;
    }

    // Validate provider ID before making API call
    if (!_hasValidProviderId(car)) {
      return 'No Provider';
    }

    return await _fetchProviderFromApi(car.carProviderId!);
  }

  /// Checks if provider information is already available
  static bool _hasProviderInfo(Car car) {
    return car.carProvider != null && car.carProvider!.fullName.isNotEmpty;
  }

  /// Checks if we have a valid provider ID to fetch from API
  static bool _hasValidProviderId(Car car) {
    return car.carProviderId != null && car.carProviderId!.isNotEmpty;
  }

  /// Fetches provider information from API
  static Future<String> _fetchProviderFromApi(String providerId) async {
    try {
      final response = await _makeProviderApiCall(providerId);
      return _extractProviderName(response);
    } catch (e) {
      return _handleProviderFetchError(e, providerId);
    }
  }

  /// Makes the HTTP request to fetch provider data
  static Future<http.Response> _makeProviderApiCall(String providerId) async {
    final url = Environment.getUserNameUrl(providerId);

    return await http
        .get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Provider API timeout'),
        );
  }

  /// Extracts provider name from API response
  static String _extractProviderName(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'API returned ${response.statusCode}: ${response.body}',
      );
    }

    final data = json.decode(response.body);

    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format: ${data.runtimeType}');
    }

    // Extract user data (handle nested 'data' field)
    final userData =
        data.containsKey('data') && data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    return _parseNameFromUserData(userData);
  }

  /// Parses name from user data (only checks for fullName field)
  static String _parseNameFromUserData(Map<String, dynamic> userData) {
    final fullName = userData['fullName']?.toString();

    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    return 'Unknown Provider';
  }

  /// Handles errors during provider fetching
  static String _handleProviderFetchError(dynamic error, String providerId) {
    // Log error for debugging
    debugPrint('Provider fetch error for $providerId: $error');

    // Return fallback provider name
    return 'Unknown Provider';
  }
}
