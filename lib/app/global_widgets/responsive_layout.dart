import 'package:flutter/material.dart';
import '../core/utils/responsive_builder.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        switch (deviceType) {
          case DeviceScreenType.mobile:
            return mobile;
          case DeviceScreenType.tablet:
            return tablet ?? desktop;
          case DeviceScreenType.desktop:
            return desktop;
          default:
            return desktop;
        }
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        int crossAxisCount;
        
        switch (deviceType) {
          case DeviceScreenType.mobile:
            crossAxisCount = mobileColumns;
            break;
          case DeviceScreenType.tablet:
            crossAxisCount = tabletColumns;
            break;
          case DeviceScreenType.desktop:
            crossAxisCount = desktopColumns;
            break;
          default:
            crossAxisCount = desktopColumns;
        }
        
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double mobileWidth;
  final double tabletWidth;
  final double desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Alignment? alignment;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.mobileWidth = double.infinity,
    this.tabletWidth = double.infinity,
    this.desktopWidth = double.infinity,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        double width;
        double? height;
        
        switch (deviceType) {
          case DeviceScreenType.mobile:
            width = mobileWidth;
            height = mobileHeight;
            break;
          case DeviceScreenType.tablet:
            width = tabletWidth;
            height = tabletHeight;
            break;
          case DeviceScreenType.desktop:
            width = desktopWidth;
            height = desktopHeight;
            break;
          default:
            width = desktopWidth;
            height = desktopHeight;
        }
        
        return Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: decoration,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool wrapOnMobile;
  final WrapAlignment wrapAlignment;
  final double spacing;
  final double runSpacing;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.wrapOnMobile = true,
    this.wrapAlignment = WrapAlignment.start,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        if (deviceType == DeviceScreenType.mobile && wrapOnMobile) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            alignment: wrapAlignment,
            children: children,
          );
        } else {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: children.map((child) {
              int index = children.indexOf(child);
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : spacing / 2,
                  right: index == children.length - 1 ? 0 : spacing / 2,
                ),
                child: child,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

