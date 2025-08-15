import 'dart:convert';
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

  Future<void> _fetchProviderName() async {

    // Check if we have a provider ID to fetch
    if (widget.car.carProviderId == null || widget.car.carProviderId!.isEmpty) {
      // Use existing provider name if available
      if (widget.car.carProvider != null) {
        print(
          'Using existing provider object: ${widget.car.carProvider!.fullName}',
        );
        setState(() {
          providerName = widget.car.carProvider!.fullName;
        });
      } else {
        print('No carProviderId found for car: ${widget.car.id}');
        setState(() {
          providerName = 'No Provider';
        });
      }
      return;
    }

    try {
      setState(() {
        isLoadingProvider = true;
      });

      final url = Environment.getUserNameUrl(widget.car.carProviderId!);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response structures
        String? name;
        if (data is Map<String, dynamic>) {
          // Check if data is nested (has 'data' field)
          Map<String, dynamic> userData = data;
          if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            userData = data['data'] as Map<String, dynamic>;
          }

          // Try different possible field names for the user's full name
          name =
              userData['fullName']?.toString() ??
              userData['full_name']?.toString() ??
              userData['name']?.toString() ??
              userData['username']?.toString() ??
              userData['email']?.toString();

          // Handle firstName + lastName combination
          if (name == null || name.isEmpty) {
            final firstName = userData['firstName']?.toString() ?? '';
            final lastName = userData['lastName']?.toString() ?? '';
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              name = '$firstName $lastName'.trim();
            }
          }

        } else {
          print('Unexpected data format: ${data.runtimeType}');
        }

        // Ensure we have a valid name
        final finalName = (name != null && name.isNotEmpty)
            ? name
            : 'Unknown Provider';

        setState(() {
          providerName = finalName;
        });
      } else {
        print('Provider API failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        // Fallback to existing provider name or default
        setState(() {
          providerName = widget.car.carProvider?.fullName ?? 'Unknown Provider';
        });
      }
    } catch (e) {
      print(
        'Error fetching provider name for ID ${widget.car.carProviderId}: $e',
      );
      // Fallback to existing provider name if available
      setState(() {
        providerName = widget.car.carProvider?.fullName ?? 'Unknown Provider';
      });
    } finally {
      setState(() {
        isLoadingProvider = false;
      });
    }
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating % 1) != 0;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 14));
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 14));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 14));
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'rented':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green.shade50;
      case 'rented':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height:
                        140, // Reduced from 140 to give more space for content
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
                // Status badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBackgroundColor(widget.car.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.car.status,
                      style: TextStyle(
                        color: _getStatusColor(widget.car.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content section - Use Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Car name with flexible height
                    Flexible(
                      child: Text(
                        widget.car.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating section - compact layout
                    if (!isLoadingRatings) ...[
                      Row(
                        children: [
                          _buildStars(averageRating),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              totalReviews > 0 ? '($totalReviews)' : '(0)',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Car specifications - more compact layout
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            Icons.people_outline,
                            '${widget.car.seats}',
                          ),
                        ),
                        Expanded(
                          child: _buildSpecItem(
                            Icons.local_gas_station_outlined,
                            _truncateText(widget.car.fuelType, 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            Icons.settings_outlined,
                            _truncateText(widget.car.transmission, 6),
                          ),
                        ),
                        Expanded(
                          child: _buildSpecItem(
                            Icons.calendar_today_outlined,
                            widget.car.modelYear,
                          ),
                        ),
                      ],
                    ),

                    // Spacer to push price to bottom
                    const Spacer(),

                    // Price and provider section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Provider info - show loading or provider name
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 10,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: isLoadingProvider
                                    ? SizedBox(
                                        height: 8,
                                        width: 40,
                                        child: LinearProgressIndicator(
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.grey[400]!,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        providerName ?? 'Loading...',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ],
                          ),
                        ),

                        // Price section
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.car.rentalPricePerDay.toVNDCompact(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const Text(
                                '/day',
                                style: TextStyle(
                                  fontSize: 7,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
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

  // Helper method to truncate text if too long
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}..';
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 9, color: Theme.of(context).primaryColor),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
