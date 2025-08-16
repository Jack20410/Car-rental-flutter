/// Car brands constants for the rental application
class CarBrands {
  static const List<String> popularBrands = [
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Toyota',
    'Honda',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Volkswagen',
    'Ford',
    'Chevrolet',
    'Lexus',
    'Tesla',
  ];

  static const List<String> luxuryBrands = [
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Lexus',
    'Infiniti',
    'Acura',
    'Porsche',
    'Jaguar',
    'Land Rover',
    'Volvo',
    'Cadillac',
    'Genesis',
    'Tesla',
    'Bentley',
    'Rolls-Royce',
    'Maserati',
    'Ferrari',
    'Lamborghini',
    'McLaren',
    'Aston Martin',
  ];

  static const List<String> economyBrands = [
    'Toyota',
    'Honda',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Mitsubishi',
    'Suzuki',
    'Daihatsu',
    'Chevrolet',
    'Ford',
    'Volkswagen',
    'Skoda',
    'Seat',
  ];

  static const List<String> electricBrands = [
    'Tesla',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Volkswagen',
    'Nissan',
    'Hyundai',
    'Kia',
    'Volvo',
    'Polestar',
    'Lucid',
    'Rivian',
    'Ford',
    'Chevrolet',
    'BYD',
    'NIO',
    'Xpeng',
    'Li Auto',
  ];

  /// All available car brands sorted alphabetically
  static const List<String> allBrands = [
    'BMW',
    'VinFast',
    'Ford',
    'Honda',
    'Kia',
    'Lexus',
    'Mazda',
    'Mercedes',
    'Mitsubishi',
    'Toyota',
  ];

  /// Get brands by category
  static List<String> getBrandsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'popular':
        return popularBrands;
      case 'luxury':
        return luxuryBrands;
      case 'economy':
        return economyBrands;
      case 'electric':
        return electricBrands;
      default:
        return allBrands;
    }
  }

  /// Check if a brand exists
  static bool isValidBrand(String brand) {
    return allBrands.contains(brand);
  }

  /// Get brand suggestions for search
  static List<String> searchBrands(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return allBrands
        .where((brand) => brand.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
