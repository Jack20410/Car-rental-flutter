import 'package:flutter/material.dart';
import '../../models/car.dart';

class CarProviderInfo extends StatelessWidget {
  final Car car;

  const CarProviderInfo({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    if (car.carProvider == null) return const SizedBox.shrink();

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
            'Car Provider',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProviderAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildProviderDetails()),
              _buildContactButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.blue.withOpacity(0.1),
      child: Text(
        car.carProvider!.fullName.isNotEmpty
            ? car.carProvider!.fullName[0].toUpperCase()
            : 'P',
        style: TextStyle(
          color: Colors.blue[700],
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildProviderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          car.carProvider!.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600], size: 16),
            const SizedBox(width: 4),
            const Text(
              '4.9',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Text(
              '(89 reviews)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: Contact provider
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact feature coming soon')),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
      ),
      child: const Text('Contact'),
    );
  }
}
