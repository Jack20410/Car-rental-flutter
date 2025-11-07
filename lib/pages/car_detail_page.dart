import 'package:flutter/material.dart';
import '../models/car.dart';
import '../widgets/car_detail/index.dart';

class CarDetailPage extends StatelessWidget {
  final Car car;

  const CarDetailPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: CarImageGallery(car: car),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Add to favorites
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                },
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Share car
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
              ),
            ],
          ),

          // Car Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarHeader(car: car),
                  const SizedBox(height: 24),
                  CarSpecifications(car: car),
                  const SizedBox(height: 24),
                  CarFeatures(car: car),
                  const SizedBox(height: 24),
                  CarProviderInfo(car: car),
                  const SizedBox(height: 24),
                  CarLocationInfo(car: car),
                  const SizedBox(height: 100), // Space for bottom booking bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CarBookingSection(car: car),
    );
  }
}
