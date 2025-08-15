# 🚗 Car Rental Flutter App

A modern, feature-rich car rental mobile application built with Flutter, featuring Vietnamese currency formatting, responsive design, and a clean user interface.

## 📱 Features

### 🏠 **Homepage**
- **Hero Section** with search functionality
- **Popular Locations Carousel** with auto-play
- **Featured Cars Grid** with dynamic data
- **Why Choose Us** section
- **Bottom Navigation** (Home, Cars, User)

### 🚗 **Car Management**
- **Dynamic Car Cards** with ratings and specifications
- **Vietnamese Currency Formatting** (VND)
- **Real-time API Integration**
- **Image Caching** for optimal performance
- **Rating System** with star display

### 🌍 **Environment Configuration**
- **Multi-environment Support** (Development, Staging, Production)
- **Centralized Configuration Management**
- **Secure Environment Variables**
- **Easy Environment Switching**

### 📱 **User Interface**
- **Responsive Design** for various screen sizes
- **Material Design 3** components
- **Smooth Animations** and transitions
- **Touch-friendly Interface**
- **Loading States** and error handling

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js (API integration)
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Image Caching**: cached_network_image
- **UI Components**: 
  - flutter_carousel_widget
  - shimmer (loading effects)
  - intl (internationalization)

## 📋 Prerequisites

- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / VS Code
- Node.js backend server (for API)
- Android/iOS device or emulator

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/Jack20410/Car-rental-flutter
cd car-rental-flutter-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Setup
1. Configure your backend URLs in `lib/config/environment.dart`
2. Update the `.env` file with your settings:
```env
API_BASE_URL=http://10.0.2.2:3000
IMAGE_BASE_URL=http://10.0.2.2:3002
```

### 4. Run the App
```bash
# Development
flutter run

# Release
flutter run --release
```

## 📁 Project Structure

```
lib/
├── config/
│   ├── environment.dart          # Environment configurations
│   ├── app_config.dart           # App configuration management
│   └── environment_example.dart  # Usage examples
├── models/
│   ├── car.dart                  # Car data model
│   └── popular_location.dart     # Location data model
├── pages/
│   └── home_page.dart           # Main homepage
├── utils/
│   ├── currency_formatter.dart  # Vietnamese currency formatting
│   └── currency_example.dart    # Currency usage examples
├── widgets/
│   └── car_card.dart            # Reusable car card component
└── main.dart                    # App entry point
```

## 🔧 Configuration

### Environment Settings
The app supports multiple environments:

```dart
// Development
AppConfig.initialize(environment: AppEnvironment.development);

// Staging
AppConfig.initialize(environment: AppEnvironment.staging);

// Production
AppConfig.initialize(environment: AppEnvironment.production);
```

### API Configuration
Update your API endpoints in `lib/config/environment.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
static const String imageBaseUrl = 'http://10.0.2.2:3002';
```

## 💰 Currency Formatting

The app includes comprehensive Vietnamese currency formatting:

```dart
// Usage examples
800000.toVNDCompact()        // "800K ₫"
1500000.toVND()              // "1.500.000 ₫"
price.toCarRentalPrice()     // "800.000 ₫/day"
```

## 📚 API Integration

### Required API Endpoints
- `GET /vehicles` - Fetch all vehicles
- `GET /vehicles?city={city}` - Fetch vehicles by city
- `GET /ratings/{vehicleId}` - Fetch vehicle ratings

### Sample API Response
```json
{
  "success": true,
  "message": "Vehicles retrieved successfully",
  "data": {
    "vehicles": [
      {
        "_id": "12345",
        "name": "Mercedes-Benz C300",
        "brand": "Mercedes",
        "rentalPricePerDay": 800000,
        "status": "Available",
        "images": ["/uploads/cars/car1.jpg"],
        "seats": 4,
        "fuelType": "Gasoline",
        "transmission": "Automatic",
        "modelYear": "2023",
        "features": ["Sunroof", "GPS", "USB Port"],
        "location": {
          "city": "Ho Chi Minh City"
        },
        "car_providerId": {
          "fullName": "Car Provider Name"
        }
      }
    ]
  }
}
```

## 🎨 Customization

### Themes
Modify the theme in `lib/main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
),
```

### Grid Layout
Adjust card sizing in `lib/pages/home_page.dart`:
```dart
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: 0.75,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
),
```

## 🐛 Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Ensure backend server is running
   - Check network connectivity
   - Verify API URLs in environment config

2. **Images Not Loading**
   - Check image server accessibility
   - Verify image URLs in API response
   - Ensure proper CORS configuration

3. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart SDK versions
   - Verify all dependencies are compatible

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Happy Coding!** 🚀
