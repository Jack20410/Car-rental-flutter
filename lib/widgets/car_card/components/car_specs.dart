import 'package:flutter/material.dart';
import '../../../models/car.dart';

class CarSpecs extends StatelessWidget {
  final Car car;

  const CarSpecs({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactSpecItem(context, Icons.people_outline, '${car.seats}'),
          _buildCompactSpecItem(
            context,
            Icons.local_gas_station_outlined,
            car.fuelType.substring(0, 3).toUpperCase(),
          ),
          _buildCompactSpecItem(
            context,
            Icons.settings_outlined,
            car.transmission.substring(0, 3).toUpperCase(),
          ),
          _buildCompactSpecItem(
            context,
            Icons.calendar_today_outlined,
            car.modelYear,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSpecItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).primaryColor),
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
