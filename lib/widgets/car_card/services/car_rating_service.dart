import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/environment.dart';

class CarRatingData {
  final double averageRating;
  final int totalReviews;

  const CarRatingData({
    required this.averageRating,
    required this.totalReviews,
  });

  static const CarRatingData empty = CarRatingData(
    averageRating: 0.0,
    totalReviews: 0,
  );
}

class CarRatingService {
  static Future<CarRatingData> fetchRatings(String carId) async {
    try {
      // Use the more efficient average rating endpoint
      final response = await http.get(
        Uri.parse(Environment.getAverageRatingUrl(carId)),
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

          return CarRatingData(averageRating: avg, totalReviews: count);
        } else {
          // No data received
          return CarRatingData.empty;
        }
      } else if (response.statusCode == 404) {
        // No ratings found for this car
        return CarRatingData.empty;
      } else {
        // Other error responses
        return CarRatingData.empty;
      }
    } catch (e) {
      print('Error fetching ratings for car $carId: $e');
      // Handle errors by ensuring no ratings are shown
      return CarRatingData.empty;
    }
  }
}
