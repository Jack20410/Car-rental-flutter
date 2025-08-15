import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Vietnamese Dong formatter
  static final NumberFormat _vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  // Simple VND formatter without locale dependency
  static final NumberFormat _simpleVndFormatter = NumberFormat('#,###');

  /// Format amount to Vietnamese Dong with symbol
  /// Example: 800000 -> "800.000 ₫"
  static String formatVND(double amount) {
    try {
      return _vndFormatter.format(amount);
    } catch (e) {
      // Fallback formatting if locale is not available
      return '${_simpleVndFormatter.format(amount)} ₫';
    }
  }

  /// Format amount to Vietnamese Dong with custom symbol
  /// Example: 800000 -> "800.000 VND"
  static String formatVNDWithCustomSymbol(
    double amount, {
    String symbol = 'VND',
  }) {
    return '${_simpleVndFormatter.format(amount)} $symbol';
  }

  /// Format amount to Vietnamese Dong without symbol
  /// Example: 800000 -> "800.000"
  static String formatVNDWithoutSymbol(double amount) {
    return _simpleVndFormatter.format(amount);
  }

  /// Format amount with compact notation for large numbers
  /// Example: 1500000 -> "1,5M ₫"
  static String formatVNDCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(0)}B ₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    } else {
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }

  /// Format price per day specifically for car rental
  /// Example: 800000 -> "800.000 ₫/ngày"
  static String formatCarRentalPrice(double amount) {
    return '${formatVND(amount)}/day';
  }

  /// Parse VND string back to double (remove formatting)
  /// Example: "800.000 ₫" -> 800000.0
  static double parseVND(String formattedAmount) {
    // Remove currency symbols and spaces
    String cleanAmount = formattedAmount
        .replaceAll('₫', '')
        .replaceAll('VND', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '');

    return double.tryParse(cleanAmount) ?? 0.0;
  }
}

// Extension method for easy usage on numbers
extension CurrencyExtension on num {
  /// Convert number to VND format
  String toVND() => CurrencyFormatter.formatVND(toDouble());

  /// Convert number to VND format without symbol
  String toVNDWithoutSymbol() =>
      CurrencyFormatter.formatVNDWithoutSymbol(toDouble());

  /// Convert number to compact VND format
  String toVNDCompact() => CurrencyFormatter.formatVNDCompact(toDouble());

  /// Convert number to car rental price format
  String toCarRentalPrice() =>
      CurrencyFormatter.formatCarRentalPrice(toDouble());
}
