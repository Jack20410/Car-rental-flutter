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

  @override
  void initState() {
    super.initState();
    _fetchRatings();
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

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating % 1) != 0;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }

    return Row(children: stars);
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
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 140,
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
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.directions_car,
                              size: 48,
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
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBackgroundColor(widget.car.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.car.status,
                      style: TextStyle(
                        color: _getStatusColor(widget.car.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with car name and provider
                    SizedBox(
                      height: 40, // Fixed height for 2 lines of text
                      child: Text(
                        widget.car.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2, // Line height for better spacing
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rating section - always show stars, even for no ratings
                    if (!isLoadingRatings) ...[
                      Row(
                        children: [
                          _buildStars(averageRating),
                          const SizedBox(width: 4),
                          Text(
                            totalReviews > 0 ? '($totalReviews)' : '(0)',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    // Car specifications (compact)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            Icons.people,
                            '${widget.car.seats}',
                          ),
                        ),
                        Expanded(
                          child: _buildSpecItem(
                            Icons.local_gas_station,
                            widget.car.fuelType,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            Icons.settings,
                            widget.car.transmission,
                          ),
                        ),
                        Expanded(
                          child: _buildSpecItem(
                            Icons.directions_car,
                            widget.car.modelYear,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.car.carProvider != null)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 10,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    widget.car.carProvider!.fullName,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.car.rentalPricePerDay.toVNDCompact(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const Text(
                              '/day',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                          ],
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

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Theme.of(context).primaryColor),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
