class Car {
  final String id;
  final String name;
  final String brand;
  final double rentalPricePerDay;
  final String status;
  final Location location;
  final List<String> images;
  final int seats;
  final String fuelType;
  final String transmission;
  final String modelYear;
  final List<String> features;
  final CarProvider? carProvider;
  final String? carProviderId; // Store the provider ID separately

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.rentalPricePerDay,
    required this.status,
    required this.location,
    required this.images,
    required this.seats,
    required this.fuelType,
    required this.transmission,
    required this.modelYear,
    required this.features,
    this.carProvider,
    this.carProviderId,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    try {
      // Handle images safely
      List<String> imageList = [];
      if (json['images'] != null) {
        if (json['images'] is List) {
          imageList = List<String>.from(
            json['images'].where(
              (img) => img != null && img.toString().isNotEmpty,
            ),
          );
        }
      }
      if (imageList.isEmpty &&
          json['image'] != null &&
          json['image'].toString().isNotEmpty) {
        imageList.add(json['image'].toString());
      }

      // Handle features safely
      List<String> featureList = [];
      if (json['features'] != null && json['features'] is List) {
        featureList = List<String>.from(
          json['features'].where((feature) => feature != null),
        );
      }

      // Handle car provider safely
      CarProvider? provider;
      String? providerId;

      if (json['car_providerId'] != null) {
        if (json['car_providerId'] is Map<String, dynamic>) {
          // If car_providerId is a populated object
          provider = CarProvider.fromJson(json['car_providerId']);
          providerId = provider.id;
        } else if (json['car_providerId'] is String) {
          // If car_providerId is just an ID string
          providerId = json['car_providerId'];
        }
      } else if (json['carProvider'] != null &&
          json['carProvider'] is Map<String, dynamic>) {
        // Alternative field name
        provider = CarProvider.fromJson(json['carProvider']);
        providerId = provider.id;
      }

      // Handle price with multiple possible fields
      double price = 0.0;
      if (json['rentalPricePerDay'] != null) {
        price = (json['rentalPricePerDay']).toDouble();
      } else if (json['price'] != null) {
        price = (json['price']).toDouble();
      } else if (json['pricePerDay'] != null) {
        price = (json['pricePerDay']).toDouble();
      }

      return Car(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed Vehicle',
        brand: json['brand']?.toString() ?? 'Unknown Brand',
        rentalPricePerDay: price,
        status: json['status']?.toString() ?? 'Available',
        location: Location.fromJson(
          json['location'] ?? {'city': 'Location not specified'},
        ),
        images: imageList,
        seats: json['seats']?.toInt() ?? 4,
        fuelType: json['fuelType']?.toString() ?? 'Gasoline',
        transmission: json['transmission']?.toString() ?? 'Manual',
        modelYear:
            json['modelYear']?.toString() ??
            json['year']?.toString() ??
            'Unknown',
        features: featureList,
        carProvider: provider,
        carProviderId: providerId,
      );
    } catch (e) {
      print('Error parsing Car from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class CarProvider {
  final String id;
  final String fullName;

  CarProvider({required this.id, required this.fullName});

  factory CarProvider.fromJson(Map<String, dynamic> json) {
    return CarProvider(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown Provider',
    );
  }
}

class Location {
  final String city;

  Location({required this.city});

  factory Location.fromJson(dynamic json) {
    if (json is String) {
      return Location(city: json);
    }
    if (json is Map<String, dynamic>) {
      return Location(city: json['city'] ?? 'Unknown Location');
    }
    return Location(city: 'Unknown Location');
  }
}
