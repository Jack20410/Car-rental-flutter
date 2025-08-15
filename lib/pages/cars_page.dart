import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import '../widgets/car_card.dart';
import '../config/environment.dart';
import '../utils/currency_formatter.dart';

class CarsPage extends StatefulWidget {
  final String? initialCity;
  final String? startDate;
  final String? endDate;

  const CarsPage({super.key, this.initialCity, this.startDate, this.endDate});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  // Data
  List<Car> cars = [];
  List<Car> filteredCars = [];
  bool isLoading = true;
  String? error;

  // Search and Filters
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriceRange = '';
  String _selectedCarType = '';
  String _selectedTransmission = '';
  String _selectedFuelType = '';
  String _selectedSeats = '';
  List<String> _selectedFeatures = [];

  // Sorting and Pagination
  String _sortBy = 'recommended';
  int _currentPage = 1;
  final int _pageSize = 8;

  // UI State
  bool _isFilterOpen = false;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http
          .get(
            Uri.parse(
              Environment.getVehiclesUrl(
                city: widget.initialCity,
                filters: {'limit': '100'},
              ),
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: Environment.defaultTimeout));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response from server');
        }

        final data = json.decode(responseBody);

        // Handle different response structures
        List<dynamic> vehicles = [];
        if (data is List) {
          vehicles = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data']?['vehicles'] != null) {
            vehicles = data['data']['vehicles'] as List<dynamic>;
          } else if (data['vehicles'] != null) {
            vehicles = data['vehicles'] as List<dynamic>;
          } else if (data['data'] != null && data['data'] is List) {
            vehicles = data['data'] as List<dynamic>;
          }
        }

        // Parse vehicles with error handling
        final List<Car> loadedCars = [];
        for (int i = 0; i < vehicles.length; i++) {
          try {
            final vehicleData = vehicles[i];
            if (vehicleData is Map<String, dynamic>) {
              final car = Car.fromJson(vehicleData);
              loadedCars.add(car);
            }
          } catch (e) {
            print('Error parsing vehicle $i: $e');
          }
        }

        setState(() {
          cars = loadedCars;
          _applyFilters();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Car> filtered = List.from(cars);

    // Filter by search term
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((car) {
        return car.name.toLowerCase().contains(searchTerm) ||
            car.brand.toLowerCase().contains(searchTerm) ||
            car.location.city.toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Filter by status (only show available cars)
    filtered = filtered
        .where((car) => car.status.toLowerCase() == 'available')
        .toList();

    // Price Range Filter
    if (_selectedPriceRange.isNotEmpty) {
      final parts = _selectedPriceRange.split('-');
      final min = double.tryParse(parts[0]) ?? 0;
      final max = parts.length > 1 ? double.tryParse(parts[1]) : null;

      filtered = filtered.where((car) {
        final price = car.rentalPricePerDay;
        return price >= min && (max == null || price <= max);
      }).toList();
    }

    // Car Type Filter
    if (_selectedCarType.isNotEmpty) {
      filtered = filtered
          .where((car) => car.brand == _selectedCarType)
          .toList();
    }

    // Transmission Filter
    if (_selectedTransmission.isNotEmpty) {
      filtered = filtered
          .where((car) => car.transmission == _selectedTransmission)
          .toList();
    }

    // Fuel Type Filter
    if (_selectedFuelType.isNotEmpty) {
      filtered = filtered
          .where((car) => car.fuelType == _selectedFuelType)
          .toList();
    }

    // Seats Filter
    if (_selectedSeats.isNotEmpty) {
      final seatCount = int.tryParse(_selectedSeats) ?? 0;
      filtered = filtered.where((car) {
        if (_selectedSeats == '7') {
          return car.seats >= 7;
        }
        return car.seats == seatCount;
      }).toList();
    }

    // Features Filter
    if (_selectedFeatures.isNotEmpty) {
      filtered = filtered.where((car) {
        return _selectedFeatures.every(
          (feature) => car.features.contains(feature),
        );
      }).toList();
    }

    // Apply sorting
    _applySorting(filtered);

    setState(() {
      filteredCars = filtered;
      _currentPage = 1; // Reset to first page when filters change
    });
  }

  void _applySorting(List<Car> cars) {
    switch (_sortBy) {
      case 'price-low':
        cars.sort((a, b) => a.rentalPricePerDay.compareTo(b.rentalPricePerDay));
        break;
      case 'price-high':
        cars.sort((a, b) => b.rentalPricePerDay.compareTo(a.rentalPricePerDay));
        break;
      case 'newest':
        cars.sort((a, b) {
          final aYear = int.tryParse(a.modelYear) ?? 0;
          final bYear = int.tryParse(b.modelYear) ?? 0;
          return bYear.compareTo(aYear);
        });
        break;
      default:
        // Keep original order for 'recommended'
        break;
    }
  }

  List<Car> get _paginatedCars {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    if (startIndex >= filteredCars.length) return [];
    return filteredCars.sublist(
      startIndex,
      endIndex > filteredCars.length ? filteredCars.length : endIndex,
    );
  }

  int get _totalPages => (filteredCars.length / _pageSize).ceil();

  int get _activeFilterCount {
    int count = 0;
    if (_selectedPriceRange.isNotEmpty) count++;
    if (_selectedCarType.isNotEmpty) count++;
    if (_selectedTransmission.isNotEmpty) count++;
    if (_selectedFuelType.isNotEmpty) count++;
    if (_selectedSeats.isNotEmpty) count++;
    count += _selectedFeatures.length;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPriceRange = '';
      _selectedCarType = '';
      _selectedTransmission = '';
      _selectedFuelType = '';
      _selectedSeats = '';
      _selectedFeatures.clear();
      _searchController.clear();
    });
    _applyFilters();
  }

  void _toggleFeature(String feature) {
    setState(() {
      if (_selectedFeatures.contains(feature)) {
        _selectedFeatures.remove(feature);
      } else {
        _selectedFeatures.add(feature);
      }
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cars'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for cars...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (value) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Mobile Filter Button (always visible on mobile)
                    if (MediaQuery.of(context).size.width <= 768)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isFilterOpen = true),
                        icon: const Icon(Icons.filter_list),
                        label: _activeFilterCount > 0
                            ? Text('$_activeFilterCount')
                            : const Text('Filters'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MediaQuery.of(context).size.width > 768
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Desktop Filter Panel
                            SizedBox(width: 280, child: _buildFilterPanel()),
                            const SizedBox(width: 16),
                            // Results Section
                            Expanded(child: _buildResultsSection()),
                          ],
                        )
                      : _buildResultsSection(),
                ),
              ),
            ],
          ),

          // Mobile Filter Overlay
          if (_isFilterOpen && MediaQuery.of(context).size.width <= 768)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _isFilterOpen = false),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildFilterPanel()),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _isFilterOpen = false),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_activeFilterCount > 0)
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Range Filter
            _buildFilterSection(
              'Price Range',
              DropdownButton<String>(
                value: _selectedPriceRange.isEmpty ? null : _selectedPriceRange,
                hint: const Text('Any Price'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: '', child: Text('Any Price')),
                  DropdownMenuItem(
                    value: '0-1000000',
                    child: Text('Under ${1000000.toVNDCompact()}'),
                  ),
                  DropdownMenuItem(
                    value: '1000000-2000000',
                    child: Text(
                      '${1000000.toVNDCompact()} - ${2000000.toVNDCompact()}',
                    ),
                  ),
                  DropdownMenuItem(
                    value: '2000000-3000000',
                    child: Text(
                      '${2000000.toVNDCompact()} - ${3000000.toVNDCompact()}',
                    ),
                  ),
                  DropdownMenuItem(
                    value: '3000000-999999999',
                    child: Text('${3000000.toVNDCompact()}+'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedPriceRange = value ?? '');
                  _applyFilters();
                },
              ),
            ),

            // Transmission Filter
            _buildFilterSection(
              'Transmission',
              Row(
                children: ['Automatic', 'Manual'].map((type) {
                  final isSelected = _selectedTransmission == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTransmission = isSelected ? '' : type;
                          });
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                : null,
                          ),
                          child: Text(
                            type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Fuel Type Filter
            _buildFilterSection(
              'Fuel Type',
              DropdownButton<String>(
                value: _selectedFuelType.isEmpty ? null : _selectedFuelType,
                hint: const Text('Any Fuel Type'),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: '', child: Text('Any Fuel Type')),
                  DropdownMenuItem(value: 'Gasoline', child: Text('Gasoline')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                  DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFuelType = value ?? '');
                  _applyFilters();
                },
              ),
            ),

            // Seats Filter
            _buildFilterSection(
              'Seats',
              Row(
                children: ['2', '4', '5', '7'].map((seats) {
                  final isSelected = _selectedSeats == seats;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSeats = isSelected ? '' : seats;
                          });
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                : null,
                          ),
                          child: Text(
                            seats == '7' ? '7+' : seats,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Features Filter
            _buildFilterSection(
              'Features',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'Entertainment',
                      'Spare Tire',
                      'Navigation',
                      'ETC',
                      'Impact Sensor',
                      '360 Camera',
                      'Airbags',
                      'Reverse Camera',
                      'USB Port',
                      'GPS',
                      'Bluetooth',
                      'Sunroof',
                    ].map((feature) {
                      final isSelected = _selectedFeatures.contains(feature);
                      return GestureDetector(
                        onTap: () => _toggleFeature(feature),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                : null,
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        // Sort and Results Count
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredCars.length} cars found',
                style: const TextStyle(color: Colors.grey),
              ),
              Row(
                children: [
                  const Text('Sort by: ', style: TextStyle(fontSize: 14)),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(
                        value: 'recommended',
                        child: Text('Recommended'),
                      ),
                      DropdownMenuItem(
                        value: 'price-low',
                        child: Text('Price: Low to High'),
                      ),
                      DropdownMenuItem(
                        value: 'price-high',
                        child: Text('Price: High to Low'),
                      ),
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('Newest First'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value ?? 'recommended');
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cars Grid
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCars,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _paginatedCars.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No cars found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Try adjusting your filters'),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Environment.gridCrossAxisCount,
                    childAspectRatio: Environment.gridChildAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _paginatedCars.length,
                  itemBuilder: (context, index) {
                    final car = _paginatedCars[index];
                    return CarCard(
                      car: car,
                      onTap: () {
                        // Navigate to car details
                        print('Tapped on car: ${car.name}');
                      },
                    );
                  },
                ),
        ),

        // Pagination
        if (_totalPages > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              for (int i = 1; i <= _totalPages; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _currentPage = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        i.toString(),
                        style: TextStyle(
                          color: _currentPage == i
                              ? Colors.white
                              : Colors.black,
                          fontWeight: _currentPage == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
