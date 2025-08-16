import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import '../utils/currency_formatter.dart';
import '../config/environment.dart';

class CarCard extends StatefulWidget {
  final Car car;
  final VoidCallback? onTap;

  const CarCard({super.key, required this.car, this.onTap});

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  double averageRating = 0.0;
  int totalReviews = 0;
  bool isLoadingRatings = true;
  String? providerName;
  bool isLoadingProvider = false;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
    _fetchProviderName();
  }

  Future<void> _fetchRatings() async {
    try {
      // Use the more efficient average rating endpoint
      final response = await http.get(
        Uri.parse(Environment.getAverageRatingUrl(widget.car.id)),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response structures from the rating service
        if (data != null) {
          double avg = 0.0;
          int count = 0;

          // Check for different possible response formats
          if (data is Map<String, dynamic>) {
            // Format: {"averageRating": 4.5, "totalReviews": 10}
            avg = (data['averageRating'] ?? data['average'] ?? 0).toDouble();
            count =
                (data['totalReviews'] ?? data['count'] ?? data['total'] ?? 0)
                    .toInt();
          } else if (data is List && data.isNotEmpty) {
            // Fallback: if still returns array, calculate average
            avg =
                data
                    .map((r) => (r['rating'] ?? 0).toDouble())
                    .reduce((a, b) => a + b) /
                data.length;
            count = data.length;
          }

          setState(() {
            averageRating = avg;
            totalReviews = count;
          });
        } else {
          // No data received
          setState(() {
            averageRating = 0.0;
            totalReviews = 0;
          });
        }
      } else if (response.statusCode == 404) {
        // No ratings found for this car
        setState(() {
          averageRating = 0.0;
          totalReviews = 0;
        });
      } else {
        // Other error responses
        setState(() {
          averageRating = 0.0;
          totalReviews = 0;
        });
      }
    } catch (e) {
      print('Error fetching ratings for car ${widget.car.id}: $e');
      // Handle errors by ensuring no ratings are shown
      setState(() {
        averageRating = 0.0;
        totalReviews = 0;
      });
    } finally {
      setState(() {
        isLoadingRatings = false;
      });
    }
  }

  /// Fetches provider name with clean error handling and fallback logic
  Future<void> _fetchProviderName() async {
    // Return early if provider info is already available
    if (_hasProviderInfo()) {
      _setProviderFromExistingData();
      return;
    }

    // Validate provider ID before making API call
    if (!_hasValidProviderId()) {
      _setDefaultProvider();
      return;
    }

    await _fetchProviderFromApi();
  }

  /// Checks if provider information is already available
  bool _hasProviderInfo() {
    return widget.car.carProvider != null &&
        widget.car.carProvider!.fullName.isNotEmpty;
  }

  /// Checks if we have a valid provider ID to fetch from API
  bool _hasValidProviderId() {
    return widget.car.carProviderId != null &&
        widget.car.carProviderId!.isNotEmpty;
  }

  /// Sets provider name from existing car provider data
  void _setProviderFromExistingData() {
    setState(() {
      providerName = widget.car.carProvider!.fullName;
    });
  }

  /// Sets default provider name when no data is available
  void _setDefaultProvider() {
    setState(() {
      providerName = 'No Provider';
    });
  }

  /// Fetches provider information from API
  Future<void> _fetchProviderFromApi() async {
    setState(() {
      isLoadingProvider = true;
    });

    try {
      final response = await _makeProviderApiCall();
      final extractedName = _extractProviderName(response);
      
      setState(() {
        providerName = extractedName;
      });
    } catch (e) {
      _handleProviderFetchError(e);
    } finally {
      setState(() {
        isLoadingProvider = false;
      });
    }
  }

  /// Makes the HTTP request to fetch provider data
  Future<http.Response> _makeProviderApiCall() async {
    final url = Environment.getUserNameUrl(widget.car.carProviderId!);
    
    return await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Provider API timeout'),
    );
  }

  /// Extracts provider name from API response
  String _extractProviderName(http.Response response) {
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
    final userData = data.containsKey('data') && data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    return _parseNameFromUserData(userData);
  }

  /// Parses name from user data (only checks for fullName field)
  String _parseNameFromUserData(Map<String, dynamic> userData) {
    final fullName = userData['fullName']?.toString();
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return 'Unknown Provider';
  }

  /// Handles errors during provider fetching
  void _handleProviderFetchError(dynamic error) {
    // Log error for debugging
    debugPrint('Provider fetch error for ${widget.car.carProviderId}: $error');
    
    // Set fallback provider name
    setState(() {
      providerName = widget.car.carProvider?.fullName ?? 'Unknown Provider';
    });
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating % 1) >= 0.5;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(const Icon(
          Icons.star_rounded,
          color: Color(0xFFFFA726), // Warmer amber color
          size: 14,
        ));
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(const Icon(
          Icons.star_half_rounded,
          color: Color(0xFFFFA726),
          size: 14,
        ));
      } else {
        stars.add(Icon(
          Icons.star_outline_rounded,
          color: Colors.grey[400],
          size: 14,
        ));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50); // Material Green
      case 'rented':
        return const Color(0xFF2196F3); // Material Blue
      case 'maintenance':
        return const Color(0xFFFF9800); // Material Orange
      case 'unavailable':
        return const Color(0xFFF44336); // Material Red
      default:
        return const Color(0xFF9E9E9E); // Material Grey
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFFE8F5E8); // Light green
      case 'rented':
        return const Color(0xFFE3F2FD); // Light blue
      case 'maintenance':
        return const Color(0xFFFFF3E0); // Light orange
      case 'unavailable':
        return const Color(0xFFFFEBEE); // Light red
      default:
        return const Color(0xFFF5F5F5); // Light grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with fixed height
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 100, // Further reduced to prevent overflow
                    width: double.infinity,
                    child:
                        widget.car.images.isNotEmpty &&
                            widget.car.images.first.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: Environment.getVehicleImageUrl(
                              widget.car.images.first,
                            ),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.directions_car,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Status badge with improved styling
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBackgroundColor(widget.car.status),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(widget.car.status).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.car.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(widget.car.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content section - Use Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10), // Further reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Car name - more compact
                    Text(
                      widget.car.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating section with improved styling
                    if (!isLoadingRatings) ...[
                      Row(
                        children: [
                          _buildStars(averageRating),
                          const SizedBox(width: 6),
                          Text(
                            '${averageRating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($totalReviews)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ] else ...[
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Car specifications - compact version
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCompactSpecItem(
                            Icons.people_outline,
                            '${widget.car.seats}',
                          ),
                          _buildCompactSpecItem(
                            Icons.local_gas_station_outlined,
                            widget.car.fuelType.substring(0, 3).toUpperCase(),
                          ),
                          _buildCompactSpecItem(
                            Icons.settings_outlined,
                            widget.car.transmission.substring(0, 3).toUpperCase(),
                          ),
                          _buildCompactSpecItem(
                            Icons.calendar_today_outlined,
                            widget.car.modelYear,
                          ),
                        ],
                      ),
                    ),

                    // Spacer to push bottom content down
                    const Spacer(),

                    // Provider section - compact
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: isLoadingProvider
                              ? Container(
                                  height: 8,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )
                              : Text(
                                  providerName ?? 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF888888),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),

                    // Price section - simplified
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.car.rentalPricePerDay.toVNDCompact(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                '/day',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Rent',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCompactSpecItem(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
