import 'package:flutter/material.dart';

/// Canvas701 Renk Paleti
/// Premium, sade, galeri hissi
class Canvas701Colors {
  Canvas701Colors._();

  // Ana Renkler
  static const Color primary = Color(0xFF79C47A); // Yeşil
  static const Color secondary = Color(0xFF515455); // Koyu Gri
  static const Color accent = Color(0xFF79C47A); // Yeşil (vurgu)

  // Arka Plan
  static const Color background = Color(0xFFFAFAFA); // Çok açık gri
  static const Color surface = Color(0xFFFFFFFF); // Beyaz
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Açık gri

  // Metin
  static const Color textPrimary = Color(0xFF515455);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);

  // Durum Renkleri
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1976D2);

  // Özel Renkler
  static const Color favorite = Color(0xFFE91E63);
  static const Color price = Color(0xFF515455);
  static const Color discount = Color(0xFFD32F2F);
  static const Color badge = Color(0xFF79C47A);
}

/// Canvas701 Tipografi
class Canvas701Typography {
  Canvas701Typography._();

  // Font Family
  static const String fontFamily = 'SF Pro Display';
  static const String fontFamilyBody = 'SF Pro Text';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.textPrimary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Canvas701Colors.textSecondary,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: Canvas701Colors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Canvas701Colors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Canvas701Colors.textTertiary,
  );

  // Özel Stiller
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Canvas701Colors.price,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Canvas701Colors.price,
  );

  static const TextStyle discountPrice = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Canvas701Colors.textTertiary,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Canvas701Colors.textOnPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

/// Canvas701 Spacing (8pt grid system)
class Canvas701Spacing {
  Canvas701Spacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Sayfa padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pageVerticalPadding = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

/// Canvas701 Border Radius
class Canvas701Radius {
  Canvas701Radius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(full));
}

/// Canvas701 Shadows
class Canvas701Shadows {
  Canvas701Shadows._();

  static const BoxShadow subtle = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow elevated = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}
