import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'components/car_image.dart';
import 'components/car_rating.dart';
import 'components/car_specs.dart';
import 'components/car_provider.dart' as car_provider_widget;
import 'components/car_price.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;

  const CarCard({super.key, required this.car, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            CarImage(car: car),

            // Content section - Compact layout
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 32, // Fixed height for 2 lines
                    child: Text(
                      car.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rating section with improved styling
                  CarRating(carId: car.id),
                  const SizedBox(height: 6),

                  // Car specifications - compact version
                  CarSpecs(car: car),
                  const SizedBox(height: 8),

                  // Provider section - compact
                  car_provider_widget.CarProviderWidget(car: car),
                  const SizedBox(height: 4),

                  // Price section - simplified
                  CarPrice(car: car, onRentPressed: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
