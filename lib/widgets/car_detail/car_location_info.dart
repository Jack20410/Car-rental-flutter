import 'package:flutter/material.dart';
import '../../models/car.dart';

class CarLocationInfo extends StatelessWidget {
  final Car car;

  const CarLocationInfo({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
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
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[400], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  car.location.city,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              _buildMapButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        // TODO: Show on map
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Map feature coming soon')),
        );
      },
      icon: const Icon(Icons.map),
      label: const Text('View on Map'),
    );
  }
}
