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
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed Vehicle',
      brand: json['brand'] ?? 'Unknown Brand',
      rentalPricePerDay: (json['rentalPricePerDay'] ?? json['price'] ?? 0)
          .toDouble(),
      status: json['status'] ?? 'Available',
      location: Location.fromJson(
        json['location'] ?? {'city': 'Location not specified'},
      ),
      images: List<String>.from(json['images'] ?? [json['image'] ?? '']),
      seats: json['seats'] ?? 4,
      fuelType: json['fuelType'] ?? 'Gasoline',
      transmission: json['transmission'] ?? 'Manual',
      modelYear: json['modelYear']?.toString() ?? 'Unknown',
      features: List<String>.from(json['features'] ?? []),
      carProvider: json['car_providerId'] != null
          ? CarProvider.fromJson(json['car_providerId'])
          : null,
    );
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
