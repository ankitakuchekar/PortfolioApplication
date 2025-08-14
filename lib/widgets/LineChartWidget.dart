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
    final List<MetalInOunces> combinedData = isPredictionView
        ? [...actualData, ...predictionData]
        : actualData;

    final minValue = combinedData.isNotEmpty
        ? combinedData
              .map((data) => data.totalSilverOunces)
              .reduce((a, b) => a < b ? a : b)
        : 0.0;

    final maxValue = combinedData.isNotEmpty
        ? combinedData
              .map((data) => data.totalSilverOunces)
              .reduce((a, b) => a > b ? a : b)
        : 100.0;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Silver Holdings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
            Expanded(
              child: SfCartesianChart(
                backgroundColor:
                    Colors.transparent, // Set the plot area border color
                plotAreaBorderWidth: 1.0, // Set the plot area border width
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
                    return ChartAxisLabel(
                      '${args.value.toStringAsFixed(0)} oz',
                      args.textStyle,
                    );
                  },
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<MetalInOunces, DateTime>>[
                  // Area series for actual data with gradient
                  AreaSeries<MetalInOunces, DateTime>(
                    dataSource: actualData,
                    xValueMapper: (MetalInOunces data, _) => data.orderDate,
                    yValueMapper: (MetalInOunces data, _) =>
                        data.totalSilverOunces,
                    color: actualLineColor, // Line color
                    borderWidth: 2, // Border width for the area series
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade700,
                        Colors.grey.shade300,
                      ], // Gradient from dark gray to light gray
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: Colors.blue, // Marker color for actual data
                      width: 1,
                      height: 1,
                    ),
                    name: 'Silver Holdings',
                    enableTooltip: true, // Enable tooltip for actual data
                    enableTrackball:
                        true, // Enable trackball behavior for actual data
                  ),
                  // Area series for prediction data (only when prediction view is enabled)
                  if (isPredictionView)
                    AreaSeries<MetalInOunces, DateTime>(
                      dataSource: predictionData,
                      xValueMapper: (MetalInOunces data, _) => data.orderDate,
                      yValueMapper: (MetalInOunces data, _) =>
                          data.totalSilverOunces,
                      color: predictionLineColor, // Line color for predictions
                      borderWidth: 2, // Border width for the area series
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade500,
                          Colors.green.shade200,
                        ], // Gradient from dark green to light green
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color: Colors.green, // Marker color for predictions
                        width: 1,
                        height: 1,
                      ),
                      name: 'Market Analyst Predictions',
                      enableTooltip: true, // Enable tooltip for predictions
                      enableTrackball:
                          true, // Enable trackball behavior for predictions
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
