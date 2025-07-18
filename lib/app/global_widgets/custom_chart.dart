import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/values/app_colors.dart';

enum ChartType {
  bar,
  line,
  pie,
  donut,
}

class ChartData {
  final String label;
  final double value;
  final Color? color;
  
  ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class CustomChart extends StatelessWidget {
  final ChartType type;
  final List<ChartData> data;
  final String title;
  final String? subtitle;
  final double height;
  final bool showLegend;
  final bool showLabels;
  final bool showValues;
  final bool showGrid;
  final bool animate;
  
  const CustomChart({
    Key? key,
    required this.type,
    required this.data,
    this.title = '',
    this.subtitle,
    this.height = 300,
    this.showLegend = true,
    this.showLabels = true,
    this.showValues = true,
    this.showGrid = true,
    this.animate = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLightColor,
                    ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildChart(context),
          ),
          if (showLegend) ...[
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChart(BuildContext context) {
    switch (type) {
      case ChartType.bar:
        return _buildBarChart(context);
      case ChartType.line:
        return _buildLineChart(context);
      case ChartType.pie:
        return _buildPieChart(context);
      case ChartType.donut:
        return _buildDonutChart(context);
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildBarChart(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce(math.max);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth / (data.length * 2);
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.map((item) {
            final barHeight = (item.value / maxValue) * constraints.maxHeight;
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showValues) ...[
                  Text(
                    item.value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: item.color ?? _getRandomColor(data.indexOf(item)),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                if (showLabels) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            );
          }).toList(),
        );
      },
    );
  }
  
  Widget _buildLineChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: LineChartPainter(
            data: data,
            showGrid: showGrid,
            showLabels: showLabels,
            showValues: showValues,
          ),
        );
      },
    );
  }
  
  Widget _buildPieChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: PieChartPainter(
                data: data,
                showLabels: showLabels,
                showValues: showValues,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDonutChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: DonutChartPainter(
                data: data,
                showLabels: showLabels,
                showValues: showValues,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.color ?? _getRandomColor(data.indexOf(item)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }
  
  Color _getRandomColor(int index) {
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
      AppColors.gateEntryColor,
      AppColors.weighbridgeColor,
      AppColors.billingColor,
      AppColors.reportsColor,
    ];
    
    return colors[index % colors.length];
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final bool showGrid;
  final bool showLabels;
  final bool showValues;
  
  LineChartPainter({
    required this.data,
    this.showGrid = true,
    this.showLabels = true,
    this.showValues = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = data.map((e) => e.value).reduce(math.max);
    final minValue = data.map((e) => e.value).reduce(math.min);
    
    final xStep = size.width / (data.length - 1);
    final yStep = size.height / (maxValue - minValue);
    
    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..strokeWidth = 1;
      
      // Horizontal grid lines
      for (var i = 0; i <= 5; i++) {
        final y = size.height - (i * size.height / 5);
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
      
      // Vertical grid lines
      for (var i = 0; i < data.length; i++) {
        final x = i * xStep;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          gridPaint,
        );
      }
    }
    
    // Draw line
    final linePaint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    for (var i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i].value - minValue) * yStep);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, linePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    
    final pointStrokePaint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (var i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i].value - minValue) * yStep);
      
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      canvas.drawCircle(Offset(x, y), 6, pointStrokePaint);
      
      // Draw labels
      if (showLabels) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: data[i].label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height + 5),
        );
      }
      
      // Draw values
      if (showValues) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: data[i].value.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - 20),
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final bool showLabels;
  final bool showValues;
  
  PieChartPainter({
    required this.data,
    this.showLabels = true,
    this.showValues = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final total = data.map((e) => e.value).reduce((a, b) => a + b);
    var startAngle = -math.pi / 2;
    
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = item.color ?? _getRandomColor(i)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Draw labels and values
      if (showLabels || showValues) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7;
        final x = center.dx + labelRadius * math.cos(midAngle);
        final y = center.dy + labelRadius * math.sin(midAngle);
        
        final percentage = (item.value / total * 100).toStringAsFixed(1);
        final text = showLabels && showValues
            ? '${item.label}: $percentage%'
            : showLabels
                ? item.label
                : '$percentage%';
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
      
      startAngle += sweepAngle;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
  Color _getRandomColor(int index) {
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
      AppColors.gateEntryColor,
      AppColors.weighbridgeColor,
      AppColors.billingColor,
      AppColors.reportsColor,
    ];
    
    return colors[index % colors.length];
  }
}

class DonutChartPainter extends CustomPainter {
  final List<ChartData> data;
  final bool showLabels;
  final bool showValues;
  
  DonutChartPainter({
    required this.data,
    this.showLabels = true,
    this.showValues = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.6;
    
    final total = data.map((e) => e.value).reduce((a, b) => a + b);
    var startAngle = -math.pi / 2;
    
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = item.color ?? _getRandomColor(i)
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + outerRadius * math.cos(startAngle),
          center.dy + outerRadius * math.sin(startAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();
      
      canvas.drawPath(path, paint);
      
      // Draw inner circle (hole)
      final holePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, innerRadius, holePaint);
      
      // Draw labels and values
      if (showLabels || showValues) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = (outerRadius + innerRadius) / 2;
        final x = center.dx + labelRadius * math.cos(midAngle);
        final y = center.dy + labelRadius * math.sin(midAngle);
        
        final percentage = (item.value / total * 100).toStringAsFixed(1);
        final text = showLabels && showValues
            ? '${item.label}: $percentage%'
            : showLabels
                ? item.label
                : '$percentage%';
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: _isColorDark(item.color ?? _getRandomColor(i))
                  ? Colors.white
                  : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
      
      startAngle += sweepAngle;
    }
    
    // Draw center text (total)
    if (showValues) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: total.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
  Color _getRandomColor(int index) {
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
      AppColors.gateEntryColor,
      AppColors.weighbridgeColor,
      AppColors.billingColor,
      AppColors.reportsColor,
    ];
    
    return colors[index % colors.length];
  }
  
  bool _isColorDark(Color color) {
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }
}

