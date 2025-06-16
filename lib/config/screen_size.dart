import 'package:flutter/cupertino.dart';

class ResponsiveScreenSize {
  static const int desktopScreenSize = 1366;
  static const int tabletScreenSize = 786;
  static const int mobileScreenSize = 360;

  bool isDesktopScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopScreenSize;
  }

  bool isTabletScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletScreenSize && MediaQuery.of(context).size.width < desktopScreenSize;
  }

  bool isMobileScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width < tabletScreenSize;
  }
}