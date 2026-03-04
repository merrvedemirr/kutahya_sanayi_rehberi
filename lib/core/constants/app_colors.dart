import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ana renkler
  static const Color bg = Color(0xFF0E0F0F);
  static const Color surface = Color(0xFF161818);
  static const Color surface2 = Color(0xFF1E2020);
  static const Color border = Color(0xFF2A2D2D);
  static const Color accent = Color(0xFFF5A623);
  static const Color accentDark = Color(0xFFE8420A);
  static const Color textPrimary = Color(0xFFE8E6E1);
  static const Color textMuted = Color(0xFF7A7D7D);

  // Durum renkleri
  static const Color open = Color(0xFF4CAF50);
  static const Color closed = Color(0xFF7A7D7D);

  // Kategori renkleri
  static const Color metal = Color(0xFF8EB4E3);
  static const Color elektrik = Color(0xFFF5E642);
  static const Color boya = Color(0xFFE87D42);
  static const Color otomotiv = Color(0xFFA8E842);
  static const Color insaat = Color(0xFFE842B0);
  static const Color ahsap = Color(0xFFD4A574);
  static const Color hidrolik = Color(0xFF42E8D4);
  static const Color diger = Color(0xFF7A7D7D);

  static Color categoryColor(String kategori) {
    switch (kategori) {
      case 'Metal İşleme':
        return metal;
      case 'Elektrik':
        return elektrik;
      case 'Boya':
        return boya;
      case 'Otomotiv':
        return otomotiv;
      case 'İnşaat':
        return insaat;
      case 'Ahşap':
        return ahsap;
      case 'Hidrolik':
        return hidrolik;
      default:
        return diger;
    }
  }
}
