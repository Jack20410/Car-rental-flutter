import 'package:flutter/material.dart';
import '../../models/car.dart';

class CarFeatures extends StatelessWidget {
  final Car car;

  const CarFeatures({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    if (car.features.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: car.features.map((feature) {
              return _buildFeatureChip(feature);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getFeatureIcon(feature), size: 16, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Text(
            feature,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'gps':
      case 'navigation':
        return Icons.navigation;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'usb port':
        return Icons.usb;
      case 'airbags':
        return Icons.security;
      case 'reverse camera':
      case '360 camera':
        return Icons.camera_alt;
      case 'sunroof':
        return Icons.wb_sunny;
      case 'entertainment':
        return Icons.music_note;
      case 'spare tire':
        return Icons.tire_repair;
      case 'etc':
        return Icons.toll;
      case 'impact sensor':
        return Icons.sensors;
      case 'head up display':
        return Icons.dashboard;
      case 'tire pressure monitoring system':
        return Icons.speed;
      default:
        return Icons.check_circle;
    }
  }
}
