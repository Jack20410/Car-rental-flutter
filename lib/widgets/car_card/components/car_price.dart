import 'package:flutter/material.dart';
import '../../../models/car.dart';
import '../../../utils/currency_formatter.dart';

class CarPrice extends StatelessWidget {
  final Car car;
  final VoidCallback? onRentPressed;

  const CarPrice({super.key, required this.car, this.onRentPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  car.rentalPricePerDay.toVNDCompact(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                '/day',
                style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onRentPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ],
    );
  }
}
