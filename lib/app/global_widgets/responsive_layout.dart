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
          case DeviceScreenType.desktop:
            return desktop;
          case DeviceScreenType.tablet:
            return tablet ?? mobile;
          case DeviceScreenType.mobile:
            return mobile;
          default:
            return mobile;
        }
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  
  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        int crossAxisCount;
        
        switch (deviceType) {
          case DeviceScreenType.desktop:
            crossAxisCount = desktopColumns;
            break;
          case DeviceScreenType.tablet:
            crossAxisCount = tabletColumns;
            break;
          case DeviceScreenType.mobile:
            crossAxisCount = mobileColumns;
            break;
          default:
            crossAxisCount = mobileColumns;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
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
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double spacing;
  
  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.spacing = 16,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, size) {
        if (deviceType == DeviceScreenType.mobile) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            textBaseline: textBaseline,
            children: _addSpacing(children, spacing, isVertical: true),
          );
        } else {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            textBaseline: textBaseline,
            children: _addSpacing(children, spacing, isVertical: false),
          );
        }
      },
    );
  }
  
  List<Widget> _addSpacing(List<Widget> widgets, double spacing, {required bool isVertical}) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return widgets;
    
    final List<Widget> result = [];
    
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      
      if (i < widgets.length - 1) {
        if (isVertical) {
          result.add(SizedBox(height: spacing));
        } else {
          result.add(SizedBox(width: spacing));
        }
      }
    }
    
    return result;
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
          case DeviceScreenType.desktop:
            width = desktopWidth;
            height = desktopHeight;
            break;
          case DeviceScreenType.tablet:
            width = tabletWidth;
            height = tabletHeight;
            break;
          case DeviceScreenType.mobile:
            width = mobileWidth;
            height = mobileHeight;
            break;
          default:
            width = mobileWidth;
            height = mobileHeight;
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

