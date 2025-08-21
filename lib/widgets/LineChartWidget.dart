import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // For DateFormat
import '../models/portfolio_model.dart'; // Adjust the path accordingly

class MetalHoldingsLineChart extends StatelessWidget {
  final List<MetalInOunces> metalInOuncesData;
  final ValueChanged<bool> onToggleView;
  final bool isPredictionView;
  final bool isGoldView; // Flag to distinguish between gold and silver
  final bool isTotalHoldingsView; // Flag for total holdings
  final String selectedTab;

  const MetalHoldingsLineChart({
    super.key,
    required this.metalInOuncesData,
    required this.onToggleView,
    required this.isPredictionView,
    required this.isGoldView, // Flag to determine if it's gold or silver
    required this.isTotalHoldingsView, // Flag to handle total holdings
    required this.selectedTab, // Selected tab for dynamic label
  });

  // Helper function to build the legend circle
  Widget _buildLegendDot({required Color color}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on 'type'
    final List<MetalInOunces> actualData = metalInOuncesData
        .where((data) => data.type == 'Actual')
        .toList();
    final List<MetalInOunces> predictionData = metalInOuncesData
        .where((data) => data.type == 'Prediction')
        .toList();

    // Calculate dynamic min and max for Y-axis based on selected metal (gold or silver)
    final List<MetalInOunces> combinedData = isPredictionView
        ? [...actualData, ...predictionData]
        : actualData;

    final minValue = combinedData.isNotEmpty
        ? combinedData
              .map(
                (data) => isTotalHoldingsView
                    ? data.totalOunces
                    : isGoldView
                    ? data.totalGoldOunces
                    : data.totalSilverOunces,
              )
              .reduce((a, b) => a < b ? a : b)
        : 0.0;

    final maxValue = combinedData.isNotEmpty
        ? combinedData
              .map(
                (data) => isTotalHoldingsView
                    ? data.totalOunces
                    : isGoldView
                    ? data.totalGoldOunces
                    : data.totalSilverOunces,
              )
              .reduce((a, b) => a > b ? a : b)
        : 100.0;

    // Define colors based on the selected metal type
    Color predictionLineColor = const Color(
      0xFF97FF00,
    ); // Green for predictions
    Color actualLineColor = isGoldView
        ? Colors.orangeAccent
        : const Color(0xFF808080); // Gray for actual data
    Color totalLineColor = const Color(0xFF0000FF); // Blue for total holdings

    // Define the text and color for each label based on the selected tab
    String labelText = '';
    Color labelColor = Colors.white;

    switch (selectedTab) {
      case 'Gold Holdings':
        labelText = 'Gold';
        labelColor = Colors.orangeAccent; // Color for gold
        break;
      case 'Silver Holdings':
        labelText = 'Silver';
        labelColor = const Color(0xFF808080); // Color for silver
        break;
      case 'Total Holdings':
        labelText =
            'Silver & Gold'; // Default label for total holdings (adjust as needed)
        labelColor = const Color(0xFF0000FF); // Color for total holdings (blue)
        break;
      default:
        labelText = ''; // No label for other tabs
        labelColor = Colors.white;
    }

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
                Text(
                  isTotalHoldingsView
                      ? 'Total Holdings'
                      : isGoldView
                      ? 'Gold Holdings'
                      : 'Silver Holdings',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Metal type label
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: labelColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(labelText, style: TextStyle(fontWeight: FontWeight.w500)),
                // Market Analyst Predictions label (only shown when the toggle is on)
                if (isPredictionView) ...[
                  const SizedBox(width: 16), // Add spacing between labels
                  _buildLegendDot(color: predictionLineColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Market Analyst Predictions",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
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
                  // Area series for actual data with gray color for gold/silver
                  AreaSeries<MetalInOunces, DateTime>(
                    dataSource: actualData,
                    xValueMapper: (MetalInOunces data, _) => data.orderDate,
                    yValueMapper: (MetalInOunces data, _) => isTotalHoldingsView
                        ? data.totalOunces
                        : isGoldView
                        ? data.totalGoldOunces
                        : data.totalSilverOunces,
                    color: isTotalHoldingsView
                        ? totalLineColor
                        : actualLineColor, // Line color
                    borderWidth: 2, // Border width for the area series
                    gradient: LinearGradient(
                      colors: [
                        (isTotalHoldingsView ? totalLineColor : actualLineColor)
                            .withOpacity(0.7),
                        (isTotalHoldingsView ? totalLineColor : actualLineColor)
                            .withOpacity(0.3),
                      ], // Gradient color for actual data
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: isTotalHoldingsView
                          ? totalLineColor
                          : actualLineColor, // Marker color for actual data
                      width: 1,
                      height: 1,
                    ),
                    name: isGoldView
                        ? 'Gold Holdings'
                        : isTotalHoldingsView
                        ? 'Total Holdings'
                        : 'Silver Holdings',
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
                          isTotalHoldingsView
                          ? data.totalOunces
                          : isGoldView
                          ? data.totalGoldOunces
                          : data.totalSilverOunces,
                      color: predictionLineColor, // Green for prediction
                      borderWidth: 2, // Border width for the area series
                      gradient: LinearGradient(
                        colors: [
                          predictionLineColor.withOpacity(0.7),
                          predictionLineColor.withOpacity(0.3),
                        ], // Gradient color for predictions
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color:
                            predictionLineColor, // Marker color for predictions
                        width: 1,
                        height: 1,
                      ),
                      name: isGoldView
                          ? 'Gold Predictions'
                          : isTotalHoldingsView
                          ? 'Total Predictions'
                          : 'Silver Predictions',
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
