import 'dart:math';

import 'package:flutter/widgets.dart';

class Responsive extends StatelessWidget {
  static bool get disabled {
    return false;
  }

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (disabled) {
      return mobile;
    }
    Size size = MediaQuery.of(context).size;

    if (size.width < 700) {
      return mobile;
    }

    if (size.width < 900 && tablet != null) {
      return tablet;
    }

    if (size.width > 1200 && desktop != null) {
      return desktop;
    }

    if (tablet != null) {
      return tablet;
    }

    return mobile;

    /*double kTabletBreakpoint = 1.5 / 2;
    double kDesktopBreakpoint = 3 / 2;

    Size size = MediaQuery.of(context).size;
    double aspectRatio = size.aspectRatio;

    if (aspectRatio > kDesktopBreakpoint && desktop != null) {
      return desktop;
    }

    if (aspectRatio > kTabletBreakpoint && tablet != null) {
      return tablet;
    }*/

    //return mobile;
  }

  @override
  Widget build(BuildContext context) {
    return value<Widget>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  static double sh(BuildContext context, num value) {
    return _ResponsiveSizer(context).sh(value);
  }

  static double sw(BuildContext context, num value) {
    return _ResponsiveSizer(context).sw(value);
  }
}

class _ResponsiveSizer {
  static const Size designSize = Size(360, 690);

  final BuildContext context;
  late final MediaQueryData mediaQueryData;

  _ResponsiveSizer(this.context) {
    mediaQueryData = MediaQuery.of(context);
  }

  double get screenWidth {
    return mediaQueryData.size.width;
  }

  double get screenHeight {
    return mediaQueryData.size.height;
  }

  double get scaleWidth {
    return screenWidth / designSize.width;
  }

  double get scaleHeight {
    return screenWidth / designSize.width;
  }

  double get scaleText {
    // min(scaleWidth, scaleHeight)
    return scaleWidth;
  }

  double h(num value) {
    return value * scaleHeight;
  }

  double sh(num value) {
    return value * (screenHeight / 100);
  }

  double w(num value) {
    return value * scaleWidth;
  }

  double sw(num value) {
    return value * (screenWidth / 100);
  }

  double sp(num value) {
    return value * scaleText;
  }

  double r(num value) {
    return value * min(scaleWidth, scaleHeight);
  }
}
/*
extension SizeExtension on num {
  double h(BuildContext context) {
    if (Responsive.disabled) {
      return toDouble();
    }

    return _ResponsiveSizer(context).h(this);
  }

  double sh(BuildContext context) {
    return _ResponsiveSizer(context).sh(this);
  }

  double w(BuildContext context) {
    if (Responsive.disabled) {
      return toDouble();
    }
    return _ResponsiveSizer(context).w(this);
  }

  double sw(BuildContext context) {
    return _ResponsiveSizer(context).sw(this);
  }

  double r(BuildContext context) {
    if (Responsive.disabled) {
      return toDouble();
    }
    return _ResponsiveSizer(context).r(this);
  }

  double sp(BuildContext context) {
    if (Responsive.disabled) {
      return toDouble();
    }
    return _ResponsiveSizer(context).sp(this);
  }
}
*/