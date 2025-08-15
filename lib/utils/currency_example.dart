// Example usage of Vietnamese Currency Formatter
// This file demonstrates how to use the CurrencyFormatter utility

import 'currency_formatter.dart';

void demonstrateCurrencyFormatter() {
  // Sample car rental prices in VND
  double price1 = 800000; // 800,000 VND
  double price2 = 1500000; // 1,500,000 VND
  double price3 = 2750000; // 2,750,000 VND
  double price4 = 500000; // 500,000 VND

  print('=== Vietnamese Currency Formatter Examples ===\n');

  // Standard VND formatting
  print('1. Standard VND Format:');
  print('${price1.toInt()} -> ${CurrencyFormatter.formatVND(price1)}');
  print('${price2.toInt()} -> ${CurrencyFormatter.formatVND(price2)}');
  print('${price3.toInt()} -> ${CurrencyFormatter.formatVND(price3)}');
  print('${price4.toInt()} -> ${CurrencyFormatter.formatVND(price4)}');
  print('');

  // Compact VND formatting (better for mobile UI)
  print('2. Compact VND Format (for mobile UI):');
  print('${price1.toInt()} -> ${price1.toVNDCompact()}');
  print('${price2.toInt()} -> ${price2.toVNDCompact()}');
  print('${price3.toInt()} -> ${price3.toVNDCompact()}');
  print('${price4.toInt()} -> ${price4.toVNDCompact()}');
  print('');

  // Car rental specific formatting
  print('3. Car Rental Price Format:');
  print('${price1.toInt()} -> ${price1.toCarRentalPrice()}');
  print('${price2.toInt()} -> ${price2.toCarRentalPrice()}');
  print('${price3.toInt()} -> ${price3.toCarRentalPrice()}');
  print('${price4.toInt()} -> ${price4.toCarRentalPrice()}');
  print('');

  // Without symbol
  print('4. Without Currency Symbol:');
  print('${price1.toInt()} -> ${price1.toVNDWithoutSymbol()}');
  print('${price2.toInt()} -> ${price2.toVNDWithoutSymbol()}');
  print('');

  // Custom symbol
  print('5. Custom Symbol:');
  print(
    '${price1.toInt()} -> ${CurrencyFormatter.formatVNDWithCustomSymbol(price1, symbol: 'VNĐ')}',
  );
  print(
    '${price2.toInt()} -> ${CurrencyFormatter.formatVNDWithCustomSymbol(price2, symbol: 'đồng')}',
  );
  print('');

  // Parse back to number
  print('6. Parse Formatted Currency Back to Number:');
  String formatted = price1.toVND();
  double parsed = CurrencyFormatter.parseVND(formatted);
  print('$formatted -> ${parsed.toInt()}');
  print('');

  print('=== Usage in Flutter Widgets ===');
  print('Text(car.rentalPricePerDay.toVNDCompact())');
  print('Text(car.rentalPricePerDay.toCarRentalPrice())');
  print('Text(CurrencyFormatter.formatVND(totalAmount))');
}
