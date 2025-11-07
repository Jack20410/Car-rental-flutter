import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/car.dart';
import '../models/popular_location.dart';
import '../widgets/car_card/car_card.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import 'cars_page.dart';
import 'login_page.dart';
import 'car_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PopularLocation> popularLocations =
      PopularLocation.getSampleLocations();
  List<Car> featuredCars = [];
  bool isLoading = true;
  String? error;
  int _currentIndex = 0;

  // Removed carousel controller due to package conflict
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFeaturedCars();
    _fetchCarCounts();
  }

  Future<void> _fetchCarCounts() async {
    for (var location in popularLocations) {
      try {
        final response = await http.get(
          Uri.parse(AppConfig.getVehiclesUrl(city: location.name)),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final availableCars =
              (data['data']?['vehicles'] as List?)
                  ?.where((car) => car['status'] == 'Available')
                  .length ??
              0;
          setState(() {
            location.carCount = '$availableCars cars available';
          });
        }
      } catch (e) {
        setState(() {
          location.carCount = 'No data available';
        });
      }
    }
  }

  Future<void> _fetchFeaturedCars() async {
    try {
      if (AppConfig.enableApiLogging) {
        print(
          'Fetching cars from: ${AppConfig.getVehiclesUrl(filters: {'limit': '100'})}',
        );
      }

      final response = await http
          .get(
            Uri.parse(AppConfig.getVehiclesUrl(filters: {'limit': '100'})),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: AppConfig.defaultTimeout));

      if (AppConfig.enableApiLogging) {
        print('Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response from server');
        }

        final data = json.decode(responseBody);
        print('Decoded data type: ${data.runtimeType}');
        print('Decoded data: $data');

        // Handle different response structures
        List<dynamic> vehicles = [];

        if (data is List) {
          // Direct array response
          vehicles = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data']?['vehicles'] != null) {
            vehicles = data['data']['vehicles'] as List<dynamic>;
          } else if (data['vehicles'] != null) {
            vehicles = data['vehicles'] as List<dynamic>;
          } else if (data['data'] != null && data['data'] is List) {
            vehicles = data['data'] as List<dynamic>;
          } else {
            print('Unexpected response structure: $data');
            throw Exception('Unexpected API response structure');
          }
        }

        print('Found ${vehicles.length} total vehicles');

        // Filter and parse vehicles with better error handling
        final List<Car> availableVehicles = [];
        for (int i = 0; i < vehicles.length; i++) {
          try {
            final vehicleData = vehicles[i];
            print('Processing vehicle $i: $vehicleData');

            if (vehicleData is Map<String, dynamic>) {
              final car = Car.fromJson(vehicleData);
              if (car.status.toLowerCase() == 'available') {
                availableVehicles.add(car);
              }
            } else {
              print('Vehicle $i is not a Map: ${vehicleData.runtimeType}');
            }
          } catch (e) {
            print('Error parsing vehicle $i: $e');
            print('Vehicle data: ${vehicles[i]}');
            // Continue processing other vehicles
          }
        }

        print('Found ${availableVehicles.length} available vehicles');

        // Get random cars
        availableVehicles.shuffle();
        setState(() {
          featuredCars = availableVehicles
              .take(AppConfig.maxFeaturedCars)
              .toList();
          isLoading = false;
          error = null; // Clear any previous errors
        });
      } else {
        throw Exception(
          'Failed to load cars: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Cars',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildCarsPage();
      case 2:
        return _buildUserPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          _buildPopularLocationsSection(),
          _buildFeaturedCarsSection(),
          _buildWhyChooseUsSection(),
        ],
      ),
    );
  }

  Widget _buildCarsPage() {
    return const CarsPage();
  }

  Widget _buildUserPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AuthService.isLoggedIn ? 'Profile' : 'Account'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: AuthService.isLoggedIn
          ? _buildLoggedInUserPage()
          : _buildGuestUserPage(),
    );
  }

  Widget _buildLoggedInUserPage() {
    final user = AuthService.currentUser;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    (user?['name'] ?? 'User').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?['name'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?['email'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Menu options
          _buildMenuOption(Icons.history, 'Rental History', () {
            print('Navigate to rental history');
          }),
          _buildMenuOption(Icons.favorite, 'Favorites', () {
            print('Navigate to favorites');
          }),
          _buildMenuOption(Icons.payment, 'Payment Methods', () {
            print('Navigate to payment methods');
          }),
          _buildMenuOption(Icons.settings, 'Settings', () {
            print('Navigate to settings');
          }),
          _buildMenuOption(Icons.help, 'Help & Support', () {
            print('Navigate to help');
          }),
          const Spacer(),
          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                setState(() {
                  // Refresh the UI after logout
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestUserPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Guest icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Car Rental',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to access your account, view rental history, manage favorites, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                if (result == true) {
                  setState(() {
                    // Refresh the UI after successful login
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: Colors.blue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Browse as guest
          TextButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0; // Navigate to home page
              });
            },
            child: Text(
              'Continue browsing as guest',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          // Features preview
          _buildFeatureRow(Icons.history, 'Track your rentals'),
          _buildFeatureRow(Icons.favorite, 'Save favorite cars'),
          _buildFeatureRow(Icons.payment, 'Manage payment methods'),
          _buildFeatureRow(Icons.notifications, 'Get rental updates'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?ixlib=rb-4.0.3',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 300, color: Colors.white),
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Find Your Perfect Rental Car',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for cars...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularLocationsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            'Popular Locations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose from our most popular rental locations',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: FlutterCarousel(
              items: popularLocations
                  .map((location) => _buildLocationCard(location))
                  .toList(),
              options: CarouselOptions(
                height: 200,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: Duration(
                  seconds: AppConfig.carouselAutoPlayInterval,
                ),
                showIndicator: true,
                slideIndicator: CircularStaticIndicator(),
                onPageChanged: (index, reason) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PopularLocation location) {
    return GestureDetector(
      onTap: () {
        // Navigate to cars list filtered by location
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: location.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 200, color: Colors.white),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      location.carCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            'Featured Cars',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover our most popular rental vehicles',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load cars',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        error = null;
                      });
                      _fetchFeaturedCars();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (featuredCars.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No cars available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check back later',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppConfig.gridCrossAxisCount,
                childAspectRatio: AppConfig.gridChildAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: featuredCars.length,
              itemBuilder: (context, index) {
                final car = featuredCars[index];
                return CarCard(
                  car: car,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailPage(car: car),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsSection() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            'Why Choose Us',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.access_time,
                  title: '24/7 Support',
                  description:
                      'Round-the-clock customer support for your convenience',
                ),
              ),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.verified,
                  title: 'Quality Guaranteed',
                  description:
                      'All our vehicles are regularly maintained and inspected',
                ),
              ),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.attach_money,
                  title: 'Best Rates',
                  description: 'Competitive pricing with no hidden charges',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
