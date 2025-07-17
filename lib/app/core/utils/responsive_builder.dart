import 'package:flutter/material.dart';
import '../values/app_constants.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceScreenType deviceType,
    Size size,
  ) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = MediaQuery.of(context).size;
      DeviceScreenType deviceType = _getDeviceType(size);
      return builder(context, deviceType, size);
    });
  }

  DeviceScreenType _getDeviceType(Size size) {
    double width = size.width;
    
    if (width < AppConstants.mobileBreakpoint) {
      return DeviceScreenType.mobile;
    }
    
    if (width < AppConstants.tabletBreakpoint) {
      return DeviceScreenType.tablet;
    }
    
    return DeviceScreenType.desktop;
  }
}

// Extension method to make it easier to access screen type
extension DeviceScreenTypeExtension on BuildContext {
  DeviceScreenType get deviceScreenType {
    final size = MediaQuery.of(this).size;
    double width = size.width;
    
    if (width < AppConstants.mobileBreakpoint) {
      return DeviceScreenType.mobile;
    }
    
    if (width < AppConstants.tabletBreakpoint) {
      return DeviceScreenType.tablet;
    }
    
    return DeviceScreenType.desktop;
  }
  
  bool get isMobile => deviceScreenType == DeviceScreenType.mobile;
  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;
  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;
}

