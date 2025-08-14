import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // For DateFormat
import '../models/portfolio_model.dart'; // Adjust the path accordingly

class SilverHoldingsLineChart extends StatelessWidget {
  final List<MetalInOunces> metalInOuncesData;
  final ValueChanged<bool> onToggleView; // Callback for the toggle button
  final bool isPredictionView; // To determine the current view

  const SilverHoldingsLineChart({
    super.key,
    required this.metalInOuncesData,
    required this.onToggleView,
    required this.isPredictionView,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = metalInOuncesData;

    // Check if data is being passed correctly
    print(chartData);

    // Calculate dynamic min and max for Y-axis
    final minValue = chartData
        .map((data) => data.totalSilverOunces)
        .reduce((a, b) => a < b ? a : b);
    final maxValue = chartData
        .map((data) => data.totalSilverOunces)
        .reduce((a, b) => a > b ? a : b);

    // This formatter function is now part of the widget
    String formatYValue(num value) {
      if (value.abs() >= 1e9) {
        return '\$${(value / 1e9).toStringAsFixed(1)}B';
      } else if (value.abs() >= 1e6) {
        return '\$${(value / 1e6).toStringAsFixed(1)}M';
      } else if (value.abs() >= 1e3) {
        return '\$${(value / 1e3).toStringAsFixed(1)}K';
      } else {
        return '\$${value.toStringAsFixed(0)}';
      }
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Header for the Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Silver Holdings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Custom Toggle with Text
                Row(
                  children: [
                    Text(
                      isPredictionView ? 'View Prediction' : 'View Historical',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isPredictionView,
                      onChanged: onToggleView,
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // The chart itself
            Expanded(
              child: SfCartesianChart(
                backgroundColor: Colors.transparent,
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 5,
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '{value} oz',
                  majorGridLines: const MajorGridLines(width: 0.5),
                  minimum: minValue,
                  maximum: maxValue,
                  axisLabelFormatter: (AxisLabelRenderDetails args) {
                    // Correctly return a ChartAxisLabel with the formatted string
                    return ChartAxisLabel(
                      formatYValue(args.value),
                      args.textStyle,
                    );
                  },
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<MetalInOunces, DateTime>>[
                  LineSeries<MetalInOunces, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (MetalInOunces data, _) => data.orderDate,
                    yValueMapper: (MetalInOunces data, _) =>
                        data.totalSilverOunces,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.blue,
                    name: 'Silver Holdings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
