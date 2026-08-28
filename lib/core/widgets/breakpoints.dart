import 'package:flutter/material.dart';

enum AppSizeClass { phone, tablet, desktop }

class Breakpoints {
  static const double tablet = 700;
  static const double desktop = 1100;

  static AppSizeClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return AppSizeClass.desktop;
    if (width >= tablet) return AppSizeClass.tablet;
    return AppSizeClass.phone;
  }

  static bool isPhone(BuildContext context) => of(context) == AppSizeClass.phone;
  static bool isTablet(BuildContext context) => of(context) == AppSizeClass.tablet;
  static bool isDesktop(BuildContext context) => of(context) == AppSizeClass.desktop;
  static bool useRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static double contentWidth(BuildContext context) {
    switch (of(context)) {
      case AppSizeClass.phone:
        return double.infinity;
      case AppSizeClass.tablet:
        return 840;
      case AppSizeClass.desktop:
        return 1120;
    }
  }

  static int libraryColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) return 3;
    if (width >= tablet) return 2;
    return 1;
  }
}
