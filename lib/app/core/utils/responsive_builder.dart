import 'package:flutter/material.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class ScreenSize {
  final double width;
  final double height;

  ScreenSize({
    required this.width,
    required this.height,
  });
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceScreenType deviceType,
    ScreenSize size,
  ) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenSize(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );
        return builder(context, _getDeviceType(size), size);
      },
    );
  }

  DeviceScreenType _getDeviceType(ScreenSize size) {
    double deviceWidth = size.width;

    if (deviceWidth > 1200) {
      return DeviceScreenType.desktop;
    }

    if (deviceWidth > 600) {
      return DeviceScreenType.tablet;
    }

    return DeviceScreenType.mobile;
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        // If we're on desktop and have a desktop widget, show it
        if (deviceType == DeviceScreenType.desktop && desktop != null) {
          return desktop!;
        }

        // If we're on tablet and have a tablet widget, show it
        if (deviceType == DeviceScreenType.tablet && tablet != null) {
          return tablet!;
        }

        // If we're on mobile and have a mobile widget, show it
        if (deviceType == DeviceScreenType.mobile && mobile != null) {
          return mobile!;
        }

        // If we don't have the right widget for the device type,
        // try to show the next best option
        if (deviceType == DeviceScreenType.desktop) {
          return tablet ?? mobile ?? const SizedBox();
        }

        if (deviceType == DeviceScreenType.tablet) {
          return mobile ?? const SizedBox();
        }

        return const SizedBox();
      },
    );
  }
}

