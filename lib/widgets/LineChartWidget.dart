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

  // Helper function to build a legend item (dot + text)
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendDot(color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
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

    // Create a new list for prediction data that connects to the actual data.
    final List<MetalInOunces> connectedPredictionData = List.from(
      predictionData,
    );
    if (actualData.isNotEmpty && connectedPredictionData.isNotEmpty) {
      // Insert the last actual point at the beginning of the prediction data to join the charts.
      connectedPredictionData.insert(0, actualData.last);
    }

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
        labelColor = Colors.orangeAccent;
        break;
      case 'Silver Holdings':
        labelText = 'Silver';
        labelColor = const Color(0xFF808080);
        break;
      case 'Total Holdings':
        labelText = 'Silver & Gold';
        labelColor = const Color(0xFF0000FF);
        break;
      default:
        labelText = '';
        labelColor = Colors.white;
    }

    // Calculate dynamic min and max for Y-axis based on selected metal (gold or silver)
    final List<MetalInOunces> combinedData = isPredictionView
        ? [...actualData, ...predictionData]
        : actualData;

    // Assume 'dataKey' is a String, for example:
    // final String dataKey = 'Silver';

    // Assume 'processedData' is your list of data, for example:
    // final List<Map<String, dynamic>> processedData = [{'totalSilverWorstPrediction': 96.0}, ...];

    // 1. Define the dynamic keys using string interpolation
    // final String dataKey = isGoldView ? 'Silver' : 'Gold';
    // final String worstPredictionDataKey = 'total${dataKey}WorstPrediction';
    // final String optimalPredictionDataKey = 'total${dataKey}OptimalPrediction';

    // No need to build string keys anymore.

    final bool shouldRenderWorstPrediction = combinedData.any((item) {
      // Use a nullable number to hold the value
      num? value;

      if (isGoldView) {
        // Access the gold property directly
        value = item.totalGoldWorstPrediction;
      } else {
        // Access the silver property directly
        value = item.totalSilverWorstPrediction;
      }

      // The value is null if the property doesn't exist or is not set
      return value != null && value != 0 && value > 0;
    });

    final bool shouldRenderOptimalPrediction = combinedData.any((item) {
      num? value;

      if (isGoldView) {
        value = item.totalGoldOptimalPrediction;
      } else {
        value = item.totalSilverOptimalPrediction;
      }

      return value != null && value != 0 && value > 0;
    });

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(4.0),
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
                  activeThumbColor: Colors.blue,
                ),
                const Spacer(),
                if (!isTotalHoldingsView)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => PredictionPopup(),
                      );
                    },
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
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

            // Comprehensive legend for prediction view
            if (isPredictionView && !isGoldView && !isTotalHoldingsView)
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem(const Color(0xFF808080), 'Silver'),
                  _buildLegendItem(predictionLineColor, 'Market Analyst'),
                  _buildLegendItem(Colors.blue, 'Silver Worst'),
                  _buildLegendItem(Colors.red, 'Silver Optimal'),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLegendDot(color: labelColor),
                  const SizedBox(width: 8),
                  Text(
                    labelText,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            Expanded(
              child: SfCartesianChart(
                backgroundColor: Colors.transparent,
                plotAreaBorderWidth: 1.0,

                tooltipBehavior: TooltipBehavior(enable: false),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
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

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
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
                          if (!isPredictionView) ...[
                            Text(
                              "Silver: \$${dataPoint.totalSilverOunces.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (isPredictionView) ...[
                            Text(
                              "Market Analyst Predictions: \$${dataPoint.totalSilverOunces.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.lightGreen,
                                fontSize: 12,
                              ),
                            ),
                            if (shouldRenderOptimalPrediction)
                              Text(
                                "Silver Worst: \$${dataPoint.totalSilverWorstPrediction.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            if (shouldRenderWorstPrediction)
                              Text(
                                "Silver Optimal: \$${dataPoint.totalSilverOptimalPrediction.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                // Vertical dotted line. Ensure your syncfusion_flutter_charts package is up-to-date for this to work.
                annotations: <CartesianChartAnnotation>[
                  // if (isPredictionView && actualData.isNotEmpty)
                  //   VerticalLineAnnotation(
                  //     x1: actualData.last.orderDate,
                  //     text: '',
                  //     lineDashArray: <double>[5, 5], // Dotted line
                  //     borderColor: Colors.grey.shade700,
                  //     borderWidth: 1,
                  //   )
                ],

                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.auto,
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),

                // primaryYAxis: NumericAxis(
                //   numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                //   majorGridLines: const MajorGridLines(width: 0.5),
                // ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                  majorGridLines: const MajorGridLines(width: 0.5),
                  minimum:
                      [
                        ...combinedData.map((d) => d.totalSilverOunces),
                        ...predictionData.map(
                          (d) =>
                              d.totalSilverWorstPrediction ??
                              d.totalSilverOunces,
                        ),
                      ].reduce((a, b) => a < b ? a : b) -
                      1,

                  maximum:
                      [
                        ...combinedData.map((d) => d.totalSilverOunces),
                        ...predictionData.map(
                          (d) =>
                              d.totalSilverOptimalPrediction ??
                              d.totalSilverOunces,
                        ),
                      ].reduce((a, b) => a > b ? a : b) +
                      1,
                ),

                series: <CartesianSeries<MetalInOunces, DateTime>>[
                  // Actual Silver
                  AreaSeries<MetalInOunces, DateTime>(
                    key: ValueKey(selectedTab),
                    dataSource: actualData,
                    xValueMapper: (MetalInOunces data, _) => data.orderDate,
                    yValueMapper: (MetalInOunces data, _) => isTotalHoldingsView
                        ? data.totalOunces
                        : isGoldView
                        ? data.totalGoldOunces
                        : data.totalSilverOunces,
                    color: (isTotalHoldingsView
                        ? totalLineColor
                        : actualLineColor),
                    borderWidth: 2,
                    gradient: LinearGradient(
                      colors: [
                        (isTotalHoldingsView ? totalLineColor : actualLineColor)
                            .withOpacity(0.7),
                        (isTotalHoldingsView ? totalLineColor : actualLineColor)
                            .withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.clamp,
                    ),
                    name: isGoldView
                        ? 'Gold Holdings'
                        : isTotalHoldingsView
                        ? 'Total Holdings'
                        : 'Silver Holdings',
                  ),

                  if (isPredictionView) ...[
                    // Green Area Fill (Market to Worst)
                    AreaSeries<MetalInOunces, DateTime>(
                      dataSource: connectedPredictionData,
                      xValueMapper: (d, _) => d.orderDate,
                      yValueMapper: (d, _) => isTotalHoldingsView
                          ? d.totalOunces
                          : isGoldView
                          ? d.totalGoldOunces
                          : d.totalSilverOunces,
                      // lowValueMapper: (d, _) => d.totalSilverWorstPrediction,
                      color: predictionLineColor.withOpacity(0.4),
                      gradient: LinearGradient(
                        colors: [
                          predictionLineColor.withOpacity(0.7),
                          predictionLineColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.clamp,
                      ),
                      borderWidth: 0, // No border on the fill itself
                    ),

                    LineSeries<MetalInOunces, DateTime>(
                      dataSource: connectedPredictionData,
                      xValueMapper: (d, _) => d.orderDate,
                      yValueMapper: (d, _) => d.totalSilverOunces,
                      color: predictionLineColor,
                      width: 1.5,
                      name: 'Market Analyst Predictions',
                    ),
                  ],

                  if (shouldRenderWorstPrediction && isPredictionView) ...[
                    // Red Area Fill (Optimal to Market)
                    AreaSeries<MetalInOunces, DateTime>(
                      dataSource: connectedPredictionData,
                      xValueMapper: (d, _) => d.orderDate,
                      yValueMapper: (d, _) => d.totalSilverOptimalPrediction,
                      // lowValueMapper: (d, _) => d.totalSilverOunces,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.7),
                          Colors.red.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.clamp,
                      ),
                      borderWidth: 0, // No border on the fill itself
                    ),
                    LineSeries<MetalInOunces, DateTime>(
                      dataSource: connectedPredictionData,
                      xValueMapper: (d, _) => d.orderDate,
                      yValueMapper: (d, _) => d.totalSilverOptimalPrediction,
                      color: Colors.red,
                      width: 1.5,
                      name: 'Silver Optimal',
                    ),
                  ],
                  if (shouldRenderOptimalPrediction && isPredictionView) ...[
                    AreaSeries<MetalInOunces, DateTime>(
                      dataSource: connectedPredictionData,
                      xValueMapper: (d, _) => d.orderDate,
                      yValueMapper: (d, _) => d.totalSilverWorstPrediction,
                      // lowValueMapper: (d, _) => d.totalSilverOunces,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.7),
                          Colors.blue.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.clamp,
                      ),
                      borderWidth: 0, // No border on the fill itself
                    ),
                    LineSeries<MetalInOunces, DateTime>(
                      dataSource: connectedPredictionData,
                      xValueMapper: (d, _) => d.orderDate,
                      yValueMapper: (d, _) => d.totalSilverWorstPrediction,
                      color: Colors.blue,
                      width: 1.5,
                      name: 'Silver Worst',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
