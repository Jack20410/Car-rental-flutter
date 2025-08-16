import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/car_rating_service.dart';

class CarRating extends StatefulWidget {
  final String carId;

  const CarRating({super.key, required this.carId});

  @override
  State<CarRating> createState() => _CarRatingState();
}

class _CarRatingState extends State<CarRating> {
  CarRatingData ratingData = CarRatingData.empty;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    final data = await CarRatingService.fetchRatings(widget.carId);

    if (mounted) {
      setState(() {
        ratingData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingShimmer();
    }

    return Row(
      children: [
        _buildStars(ratingData.averageRating),
        const SizedBox(width: 6),
        Text(
          '${ratingData.averageRating.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${ratingData.totalReviews})',
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
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
    );
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating % 1) >= 0.5;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFA726), // Warmer amber color
            size: 14,
          ),
        );
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(
          const Icon(
            Icons.star_half_rounded,
            color: Color(0xFFFFA726),
            size: 14,
          ),
        );
      } else {
        stars.add(
          Icon(Icons.star_outline_rounded, color: Colors.grey[400], size: 14),
        );
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
