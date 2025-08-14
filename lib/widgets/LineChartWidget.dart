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
    // Filter data based on 'type'
    final List<MetalInOunces> actualData = metalInOuncesData
        .where((data) => data.type == 'Actual')
        .toList();
    final List<MetalInOunces> predictionData = metalInOuncesData
        .where((data) => data.type == 'Prediction')
        .toList();

    // Check if data is being passed correctly
    print("Actual Data: $actualData");
    print("Prediction Data: $predictionData");

    // Calculate dynamic min and max for Y-axis
    // Combine actual and prediction data to calculate the min and max values if prediction view is on.
    final List<MetalInOunces> combinedData = isPredictionView
        ? [...actualData, ...predictionData]
        : actualData;

    // Calculate dynamic min and max for Y-axis from the combined data
    final minValue = combinedData.isNotEmpty
        ? combinedData
              .map((data) => data.totalSilverOunces)
              .reduce((a, b) => a < b ? a : b)
        : 0.0; // Default value if no data

    final maxValue = combinedData.isNotEmpty
        ? combinedData
              .map((data) => data.totalSilverOunces)
              .reduce((a, b) => a > b ? a : b)
        : 100.0; // Default value if no data

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

    // Line colors for prediction and actual data
    Color predictionLineColor = const Color(
      0xFF97FF00,
    ); // Green for predictions
    Color actualLineColor = const Color(
      0xFF808080,
    ); // Gray for actual silver holdings

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
                      isPredictionView ? 'View Historical' : 'View Prediction',
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
                      '${args.value.toStringAsFixed(0)} oz',
                      args.textStyle,
                    );
                  },
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<MetalInOunces, DateTime>>[
                  // Always display "Silver Holdings" line (actual data)
                  LineSeries<MetalInOunces, DateTime>(
                    dataSource: actualData,
                    xValueMapper: (MetalInOunces data, _) => data.orderDate,
                    yValueMapper: (MetalInOunces data, _) =>
                        data.totalSilverOunces,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: actualLineColor,
                    name: 'Silver Holdings',
                    width: 2,
                  ),
                  // Display "Market Analyst Predictions" line (prediction data) only when toggle is on
                  if (isPredictionView)
                    LineSeries<MetalInOunces, DateTime>(
                      dataSource: predictionData,
                      xValueMapper: (MetalInOunces data, _) => data.orderDate,
                      yValueMapper: (MetalInOunces data, _) =>
                          data.totalSilverOunces, // Prediction data
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: predictionLineColor,
                      name: 'Market Analyst Predictions',
                      width: 2,
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
