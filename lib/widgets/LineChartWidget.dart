import 'package:bold_portfolio/widgets/PredictionPopup.dart';
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
                const Spacer(),
                Switch(
                  value: isPredictionView,
                  onChanged: onToggleView,
                  activeColor: Colors.blue,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => PredictionPopup(), // This shows the popup
                    );
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.black), // Black border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Add Prediction',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                backgroundColor: Colors.transparent,
                plotAreaBorderWidth: 1.0,

                // Disable default tooltip, we’ll use trackball
                tooltipBehavior: TooltipBehavior(enable: false),

                // ✅ Trackball for crosshair + custom tooltip
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode:
                      ActivationMode.singleTap, // or .longPress, .doubleTap
                  lineType: TrackballLineType.vertical,
                  lineColor: Colors.grey,
                  lineWidth: 1,
                  markerSettings: const TrackballMarkerSettings(
                    markerVisibility: TrackballVisibilityMode.visible,
                  ),
                  tooltipSettings: const InteractiveTooltip(enable: true),
                  builder: (BuildContext context, TrackballDetails details) {
                    final int pointIndex = details.pointIndex ?? 0;
                    final dynamic series = details.series;
                    final List<dynamic> ds =
                        (series.dataSource ?? <dynamic>[]) as List<dynamic>;
                    final MetalInOunces dataPoint =
                        ds[pointIndex] as MetalInOunces;

                    final String date = DateFormat(
                      'MMM d, yyyy',
                    ).format(dataPoint.orderDate);
                    final double value = isTotalHoldingsView
                        ? dataPoint.totalOunces
                        : isGoldView
                        ? dataPoint.totalGoldOunces
                        : dataPoint.totalSilverOunces;
                    final String metalType = isTotalHoldingsView
                        ? "Total Holdings"
                        : (isGoldView ? "Gold" : "Silver");

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$metalType: \$${value.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 5,
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '\${value}',
                  majorGridLines: const MajorGridLines(width: 0.5),
                  minimum: minValue,
                  maximum: maxValue,
                  axisLabelFormatter: (AxisLabelRenderDetails args) {
                    return ChartAxisLabel(
                      '\$${args.value.toStringAsFixed(0)}',
                      args.textStyle,
                    );
                  },
                ),

                series: <CartesianSeries<MetalInOunces, DateTime>>[
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
                        : actualLineColor,
                    borderWidth: 2,
                    gradient: LinearGradient(
                      colors: [
                        (isTotalHoldingsView ? totalLineColor : actualLineColor)
                            .withOpacity(0.7),
                        (isTotalHoldingsView ? totalLineColor : actualLineColor)
                            .withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      color: isTotalHoldingsView
                          ? totalLineColor
                          : actualLineColor,
                      width: 1,
                      height: 1,
                    ),
                    name: isGoldView
                        ? 'Gold Holdings'
                        : isTotalHoldingsView
                        ? 'Total Holdings'
                        : 'Silver Holdings',
                  ),
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
                      color: predictionLineColor,
                      borderWidth: 2,
                      gradient: LinearGradient(
                        colors: [
                          predictionLineColor.withOpacity(0.7),
                          predictionLineColor.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color: predictionLineColor,
                        width: 1,
                        height: 1,
                      ),
                      name: isGoldView
                          ? 'Gold Predictions'
                          : isTotalHoldingsView
                          ? 'Total Predictions'
                          : 'Silver Predictions',
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
