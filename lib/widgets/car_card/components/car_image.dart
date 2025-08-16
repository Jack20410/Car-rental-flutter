import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/environment.dart';
import '../../../models/car.dart';

class CarImage extends StatelessWidget {
  final Car car;
  final double height;

  const CarImage({super.key, required this.car, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: car.images.isNotEmpty && car.images.first.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: Environment.getVehicleImageUrl(car.images.first),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(car.status),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor(car.status).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              car.status.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(car.status),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
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
}
