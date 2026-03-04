enum ImageItems { homebanner, mapicon, clockicon, phoneicon, open, calendar }

extension ImageItemsExtension on ImageItems {
  String _imagePath() {
    switch (this) {
      case ImageItems.homebanner:
        return 'banner_bg';
      case ImageItems.mapicon:
        return 'location';
      case ImageItems.clockicon:
        return 'working-time';
      case ImageItems.phoneicon:
        return 'mobile';
      case ImageItems.open:
        return 'open';
      case ImageItems.calendar:
        return 'calendar';
    }
  }

  String get imagePath => "assets/png/${_imagePath()}.png";
}
