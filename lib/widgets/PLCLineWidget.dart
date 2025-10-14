import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:bold_portfolio/widgets/PredictionPopup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // For DateFormat
import '../models/portfolio_model.dart'; // Adjust the path accordingly

class MetalHoldingsLineChartForPLC extends StatelessWidget {
  final List<MetalInOunces> metalInOuncesData;
  final bool isGoldView; // Flag to distinguish between gold and silver
  final String metal;
  final String selectedRange;

  const MetalHoldingsLineChartForPLC({
    super.key,
    required this.metalInOuncesData,
    required this.isGoldView, // Flag to determine if it's gold or silver
    required this.metal, // Selected tab for dynamic label
    required this.selectedRange,
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
    final List<MetalInOunces> actualData = metalInOuncesData;
    Color actualLineColor = isGoldView
        ? Colors.orangeAccent
        : const Color(0xFF808080); // Gray for actual data

    String labelText = '';
    Color labelColor = Colors.white;

    switch (metal) {
      case 'Gold':
        labelText = 'Gold';
        labelColor = Colors.orangeAccent;
        break;
      case 'Silver':
        labelText = 'Silver';
        labelColor = const Color(0xFF808080);
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

    return Card(
      elevation: 4,
      // margin: const EdgeInsets.all(4.0),
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       isGoldView ? 'Gold Holdings' : 'Silver Holdings',
            //       style: const TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),

            // Comprehensive legend for prediction view
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLegendDot(color: labelColor),
                const SizedBox(width: 8),
                Text(labelText, style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child: actualData.isEmpty
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

                          // Loop through all series and display values properly
                          seriesToData.forEach((seriesName, dp) {
                            if (seriesName == 'Silver') {
                              content.add(
                                Text(
                                  "Silver: ${formatPrice(dp.totalSilverOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            } else if (seriesName == 'Gold') {
                              content.add(
                                Text(
                                  "Gold: ${formatPrice(dp.totalGoldOunces)}",
                                  style: baseStyle,
                                ),
                              );
                            }
                          });
                          final minValue = [
                            ...metalInOuncesData.map(
                              (d) => isGoldView
                                  ? d.totalGoldOunces
                                  : d.totalSilverOunces,
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
                        minimum:
                            [
                                  ...metalInOuncesData.map(
                                    (d) => isGoldView
                                        ? d.totalGoldOunces
                                        : d.totalSilverOunces,
                                  ),
                                ].reduce((a, b) => a < b ? a : b) <
                                1
                            ? [
                                ...metalInOuncesData.map(
                                  (d) => isGoldView
                                      ? d.totalGoldOunces
                                      : d.totalSilverOunces,
                                ),
                              ].reduce((a, b) => a < b ? a : b)
                            : [
                                    ...metalInOuncesData.map(
                                      (d) => isGoldView
                                          ? d.totalGoldOunces
                                          : d.totalSilverOunces,
                                    ),
                                  ].reduce((a, b) => a < b ? a : b) -
                                  1,

                        maximum:
                            [
                              ...metalInOuncesData.map(
                                (d) => isGoldView
                                    ? d.totalGoldOunces
                                    : d.totalSilverOunces,
                              ),
                            ].reduce((a, b) => a > b ? a : b) +
                            1,
                      ),

                      series: <CartesianSeries<MetalInOunces, DateTime>>[
                        // Actual Silver
                        AreaSeries<MetalInOunces, DateTime>(
                          key: ValueKey('$metal $selectedRange'),
                          dataSource: actualData,
                          xValueMapper: (MetalInOunces data, _) =>
                              data.orderDate,
                          yValueMapper: (MetalInOunces data, _) => isGoldView
                              ? data.totalGoldOunces
                              : data.totalSilverOunces,
                          color: (actualLineColor),
                          borderWidth: 2,
                          gradient: LinearGradient(
                            colors: [
                              (actualLineColor).withOpacity(0.7),
                              (actualLineColor).withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.clamp,
                          ),
                          name: isGoldView ? 'Gold' : 'Silver',
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
