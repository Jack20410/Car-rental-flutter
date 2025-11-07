# Car Detail Components

This directory contains modular components for the car detail page, making the code more maintainable and reusable.

## Components

### 🖼️ CarImageGallery (`car_image_gallery.dart`)
- Displays car images in a swipeable gallery
- Shows image indicators for multiple images
- Handles image loading errors gracefully
- **Props**: `Car car`

### 📋 CarHeader (`car_header.dart`)
- Shows car name, brand, model year
- Displays availability status badge
- Shows rating and price per day
- **Props**: `Car car`

### ⚙️ CarSpecifications (`car_specifications.dart`)
- Displays car specifications in a grid layout
- Shows seats, transmission, fuel type, and year
- Uses icons for better visual representation
- **Props**: `Car car`

### ✨ CarFeatures (`car_features.dart`)
- Shows car features as chips with icons
- Automatically hides if no features available
- Maps feature names to appropriate icons
- **Props**: `Car car`

### 👤 CarProviderInfo (`car_provider_info.dart`)
- Displays car provider information
- Shows provider avatar, name, and rating
- Includes contact button (placeholder)
- Automatically hides if no provider data
- **Props**: `Car car`

### 📍 CarLocationInfo (`car_location_info.dart`)
- Shows car location information
- Includes "View on Map" button (placeholder)
- **Props**: `Car car`

### 💰 CarBookingSection (`car_booking_section.dart`)
- Handles date selection for rental period
- Calculates total price based on selected dates
- Includes booking button with validation
- **Props**: `Car car`

## Usage

### Individual Components
```dart
import '../widgets/car_detail/car_header.dart';

CarHeader(car: myCar)
```

### All Components (Recommended)
```dart
import '../widgets/car_detail/index.dart';

// Now you can use all components:
CarHeader(car: myCar)
CarSpecifications(car: myCar)
CarFeatures(car: myCar)
// ... etc
```

## Benefits of This Structure

1. **Maintainability**: Each component has a single responsibility
2. **Reusability**: Components can be used in other parts of the app
3. **Testability**: Each component can be tested independently
4. **Readability**: Smaller files are easier to understand and modify
5. **Team Collaboration**: Multiple developers can work on different components simultaneously

## File Structure
```
lib/widgets/car_detail/
├── index.dart                 # Exports all components
├── car_image_gallery.dart     # Image gallery component
├── car_header.dart           # Car header with name, status, rating
├── car_specifications.dart   # Car specs grid
├── car_features.dart         # Feature chips
├── car_provider_info.dart    # Provider information
├── car_location_info.dart    # Location display
├── car_booking_section.dart  # Booking form with date picker
└── README.md                 # This documentation
```

## Adding New Components

1. Create a new `.dart` file in this directory
2. Follow the naming convention: `car_[component_name].dart`
3. Export it in `index.dart`
4. Update this README with component documentation
