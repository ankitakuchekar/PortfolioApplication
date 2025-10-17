import 'dart:math';

import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/widgets/PredictionPopup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  double getCurrentValue(MetalInOunces data) {
    if (isTotalHoldingsView) {
      return data.totalOunces;
    } else if (isGoldView) {
      return data.totalGoldOunces;
    } else {
      return data.totalSilverOunces;
    }
  }

  double getPrediction(MetalInOunces data) {
    if (isPredictionView) {
      if (isTotalHoldingsView) {
        return data.totalOunces;
      } else if (isGoldView) {
        final totalSilver = data.totalGoldOunces;
        final totalSilverWorst = data.totalGoldWorstPrediction;
        final totalSilverOptimal = data.totalGoldOptimalPrediction;
        final maxGold = max(
          totalSilver,
          max(totalSilverWorst, totalSilverOptimal),
        );
        return maxGold;
      } else {
        final totalSilver = data.totalSilverOunces;
        final totalSilverWorst = data.totalSilverWorstPrediction;
        final totalSilverOptimal = data.totalSilverOptimalPrediction;
        final maxSilver = max(
          totalSilver,
          max(totalSilverWorst, totalSilverOptimal),
        );
        return maxSilver;
      }
    } else {
      if (isTotalHoldingsView) {
        return data.totalOunces;
      } else if (isGoldView) {
        return data.totalGoldOunces;
      } else {
        return data.totalSilverOunces;
      }
    }
  }

  double getMinY(
    List<MetalInOunces> combinedData,
    List<MetalInOunces> predictionData,
  ) {
    final allValues = [
      ...combinedData.map((d) => getCurrentValue(d)),
      ...predictionData.map((d) => getPrediction(d)),
    ].where((value) => value > 0).toList(); // Filter only positive values

    final minValue = allValues.reduce(min);
    print("minvalye ${minValue - 1} ${minValue < 0}");
    return minValue - 1;
  }

  double getMaxY(
    List<MetalInOunces> actualData,
    List<MetalInOunces> predictionData,
  ) {
    final List<double> allValues;
    print(" $isPredictionView");
    if (isPredictionView) {
      allValues = [
        // ...actualData.map((d) => getCurrentValue(d)),
        ...predictionData.map((d) => getPrediction(d)),
      ];
    } else {
      allValues = [...actualData.map((d) => getCurrentValue(d))];
    }
    print(" ${allValues.reduce(max)}");

    return allValues.reduce(max) + 1;
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

    Color predictionLineColor = const Color(
      0xFF97FF00,
    ); // Green for predictions
    Color actualLineColor = isGoldView
        ? Colors.orangeAccent
        : const Color(0xFF808080); // Gray for actual data
    Color totalLineColor = const Color(0xFF0000FF); // Blue for total holdings

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

    String formatValue(num value) {
      final absValue = value.abs();

      if (absValue >= 1e9) {
        return '${(value / 1e9).toStringAsFixed(1)}B';
      } else if (absValue >= 1e6) {
        return '${(value / 1e6).toStringAsFixed(1)}M';
      } else if (absValue >= 1e3) {
        return '${(value / 1e3).toStringAsFixed(1)}K';
      } else {
        return '${value.toStringAsFixed(0)}';
      }
    }

    String formatPrice(num price) {
      final format = NumberFormat.simpleCurrency(locale: 'en_US');
      return format.format(price);
    }

    // Calculate dynamic min and max for Y-axis based on selected metal (gold or silver)
    final List<MetalInOunces> combinedData = isPredictionView
        ? [...actualData, ...predictionData]
        : actualData;

    final bool shouldRenderWorstPrediction = combinedData.any((item) {
      num? value;
      if (item.type == 'Prediction') {
        if (isGoldView) {
          value = item.totalGoldWorstPrediction;
        } else {
          value = item.totalSilverWorstPrediction;
        }
      }
      return value != null && value != 0 && value > 0;
    });

    final bool shouldRenderOptimalPrediction = combinedData.any((item) {
      num? value;
      if (item.type == 'Prediction') {
        if (isGoldView) {
          value = item.totalGoldOptimalPrediction;
        } else {
          value = item.totalSilverOptimalPrediction;
        }
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
            if (isPredictionView && !isTotalHoldingsView)
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem(const Color(0xFF808080), 'Silver'),
                  if (isPredictionView)
                    _buildLegendItem(
                      predictionLineColor,
                      'Market Analyst Prediction',
                    ),
                  if (shouldRenderWorstPrediction)
                    _buildLegendItem(Colors.red, 'Silver Worst'),
                  if (shouldRenderOptimalPrediction)
                    _buildLegendItem(Colors.blue, 'Silver Optimal'),
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
              child: combinedData.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SfCartesianChart(
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
                        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                        builder: (BuildContext context, TrackballDetails details) {
                          final groupingInfo = details.groupingModeInfo;
                          if (groupingInfo == null) return const SizedBox();

                          final List<dynamic>? visibleSeriesList =
                              groupingInfo.visibleSeriesList;
                          final List<CartesianChartPoint<dynamic>> points =
                              groupingInfo.points;

                          if (visibleSeriesList == null ||
                              visibleSeriesList.length != points.length) {
                            return const SizedBox();
                          }

                          // Map of seriesName -> dataPoint
                          final Map<String, MetalInOunces> seriesToData = {};

                          for (int i = 0; i < visibleSeriesList.length; i++) {
                            final seriesObj = visibleSeriesList[i];
                            final point = points[i];
                            final String? seriesName =
                                seriesObj.name as String?;
                            final List<dynamic>? ds = seriesObj.dataSource;

                            if (seriesName != null &&
                                ds != null &&
                                point.x != null) {
                              MetalInOunces? dp;
                              try {
                                dp =
                                    ds.firstWhere((e) => e.orderDate == point.x)
                                        as MetalInOunces;
                              } catch (_) {
                                dp = ds.isNotEmpty
                                    ? ds.first as MetalInOunces
                                    : null;
                              }

                              if (dp != null) {
                                seriesToData[seriesName] = dp;
                              }
                            }
                          }

                          if (seriesToData.isEmpty) return const SizedBox();
                          final provider = Provider.of<PortfolioProvider>(
                            context,
                            listen: false,
                          );

                          final MetalInOunces firstDp =
                              seriesToData.values.first;
                          final String date = provider.frequency == '1D'
                              ? DateFormat(
                                  'MMM dd hh:mm a',
                                ).format(firstDp.orderDate)
                              : DateFormat(
                                  'MMM d, yyyy',
                                ).format(firstDp.orderDate);

                          final List<Widget> content = [
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ];

                          const TextStyle baseStyle = TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          );
                          seriesToData.forEach((seriesName, dp) {
                            if (seriesName == 'Silver Holdings') {
                              content.add(
                                Text(
                                  "Silver: ${formatPrice(dp.totalSilverOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Gold Holdings') {
                              content.add(
                                Text(
                                  "Gold: ${formatPrice(dp.totalGoldOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Total Holdings') {
                              content.add(
                                Text(
                                  "Total: ${formatPrice(dp.totalOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Market Prediction') {
                              content.add(
                                Text(
                                  "Market Prediction: \$${(isTotalHoldingsView
                                      ? dp.totalOunces
                                      : isGoldView
                                      ? dp.totalGoldOunces
                                      : dp.totalSilverOunces)}",
                                  style: const TextStyle(
                                    color: Colors.lightGreen,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            } else if (seriesName == 'Worst Prediction') {
                              content.add(
                                Text(
                                  "${isGoldView ? 'Gold' : 'Silver'} Worst: \$${isGoldView ? dp.totalGoldWorstPrediction : dp.totalSilverWorstPrediction}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            } else if (seriesName == 'Optimal Prediction') {
                              content.add(
                                Text(
                                  "${isGoldView ? 'Gold' : 'Silver'} Optimal: \$${(isGoldView ? dp.totalGoldOptimalPrediction : dp.totalSilverOptimalPrediction)}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                          });
                          final minValue = [
                            ...combinedData.map(
                              (d) => isTotalHoldingsView
                                  ? d.totalOunces
                                  : isGoldView
                                  ? d.totalGoldOunces
                                  : d.totalSilverOunces,
                            ),
                            ...predictionData.map(
                              (d) => isTotalHoldingsView
                                  ? d.totalOunces
                                  : isGoldView
                                  ? d.totalGoldWorstPrediction
                                  : d.totalSilverWorstPrediction,
                            ),
                          ].reduce((a, b) => a < b ? a : b);

                          // ✅ Only subtract 1 if result stays positive
                          final adjustedMin = (minValue - 1) < 0
                              ? minValue
                              : minValue - 1;

                          // Final tooltip container
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
                              children: content,
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
                        axisLabelFormatter: (AxisLabelRenderDetails details) {
                          return ChartAxisLabel(
                            '\$${formatValue(details.value)}',
                            const TextStyle(
                              color: Colors.black,
                            ), // customize style as needed
                          );
                        },
                        majorGridLines: const MajorGridLines(width: 0.5),
                        // Set the minimum value using the getMinY function
                        minimum: getMinY(combinedData, predictionData),
                        // Set the maximum value using the getMaxY function
                        maximum: getMaxY(actualData, predictionData),
                      ),
                      series: <CartesianSeries<MetalInOunces, DateTime>>[
                        // Actual Silver
                        AreaSeries<MetalInOunces, DateTime>(
                          key: ValueKey(selectedTab),
                          dataSource: actualData,
                          xValueMapper: (MetalInOunces data, _) =>
                              data.orderDate,
                          yValueMapper: (MetalInOunces data, _) =>
                              isTotalHoldingsView
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
                              (isTotalHoldingsView
                                      ? totalLineColor
                                      : actualLineColor)
                                  .withOpacity(0.7),
                              (isTotalHoldingsView
                                      ? totalLineColor
                                      : actualLineColor)
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
                            key: ValueKey('${selectedTab}_prediction'),
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
                            key: ValueKey('${selectedTab}_linepredictions'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => isTotalHoldingsView
                                ? d.totalOunces
                                : isGoldView
                                ? d.totalGoldOunces
                                : d.totalSilverOunces,
                            color: predictionLineColor,
                            width: 1.5,
                            name: 'Market Prediction',
                          ),
                        ],

                        if (shouldRenderWorstPrediction &&
                            isPredictionView &&
                            !isTotalHoldingsView) ...[
                          // Red Area Fill (Optimal to Market)
                          AreaSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_worstPrediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => isGoldView
                                ? d.totalGoldWorstPrediction
                                : d.totalSilverWorstPrediction,
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
                            key: ValueKey('${selectedTab}_lineworstPrediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => isGoldView
                                ? d.totalGoldWorstPrediction
                                : d.totalSilverWorstPrediction,
                            color: Colors.red,
                            width: 1.5,
                            name: 'Worst Prediction',
                          ),
                        ],
                        if (shouldRenderOptimalPrediction &&
                            isPredictionView &&
                            !isTotalHoldingsView) ...[
                          AreaSeries<MetalInOunces, DateTime>(
                            key: ValueKey('${selectedTab}_Optimalprediction'),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => isGoldView
                                ? d.totalGoldOptimalPrediction
                                : d.totalSilverOptimalPrediction,
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
                            key: ValueKey(
                              '${selectedTab}_LineOptimalprediction',
                            ),
                            dataSource: connectedPredictionData,
                            xValueMapper: (d, _) => d.orderDate,
                            yValueMapper: (d, _) => isGoldView
                                ? d.totalGoldOptimalPrediction
                                : d.totalSilverOptimalPrediction,
                            color: Colors.blue,
                            width: 1.5,
                            name: 'Optimal Prediction',
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
