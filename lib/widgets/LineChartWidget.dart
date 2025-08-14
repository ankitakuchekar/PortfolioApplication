import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // For DateFormat
import '../models/portfolio_model.dart'; // Adjust the path accordingly

class SilverHoldingsLineChart extends StatelessWidget {
  final List<MetalInOunces> metalInOuncesData;

  const SilverHoldingsLineChart({super.key, required this.metalInOuncesData});

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

    ChartAxisLabel formatValue(num value) {
      String formattedValue;

      if (value.abs() >= 1e9) {
        formattedValue = '\$${(value / 1e9).toStringAsFixed(1)}B';
      } else if (value.abs() >= 1e6) {
        formattedValue = '\$${(value / 1e6).toStringAsFixed(1)}M';
      } else if (value.abs() >= 1e3) {
        formattedValue = '\$${(value / 1e3).toStringAsFixed(1)}K';
      } else {
        formattedValue = '\$${value.toStringAsFixed(0)}';
      }

      // Return a ChartAxisLabel instead of just a String
      return ChartAxisLabel(formattedValue, null);
    }

    return Expanded(
      child: SfCartesianChart(
        backgroundColor: Colors.transparent,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.MMMd(), // Format the date
          intervalType: DateTimeIntervalType.days, // Set interval to days
          majorGridLines: MajorGridLines(width: 0), // Hide grid lines
          edgeLabelPlacement: EdgeLabelPlacement.shift, // Prevent overlap
          interval:
              5, // Adjust interval for tick marks (you can make this dynamic)
        ),

        primaryYAxis: NumericAxis(
          labelFormat: '{value} oz', // Default format for values
          majorGridLines: MajorGridLines(width: 0.5),
          minimum: minValue, // Set dynamic minimum Y-axis value
          maximum: maxValue, // Set dynamic maximum Y-axis value
          axisLabelFormatter: (AxisLabelRenderDetails args) {
            final num value = args.value;

            // Apply formatting logic
            return formatValue(value);
          },
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<MetalInOunces, DateTime>>[
          LineSeries<MetalInOunces, DateTime>(
            dataSource: chartData,
            xValueMapper: (MetalInOunces data, _) =>
                data.orderDate, // X-axis value
            yValueMapper: (MetalInOunces data, _) =>
                data.totalSilverOunces, // Y-axis value
            markerSettings: MarkerSettings(
              isVisible: true,
            ), // Enable markers for data points
            color: Colors.blue, // Set line color for visibility
            name: 'Silver Holdings',
          ),
        ],
      ),
    );
  }
}
