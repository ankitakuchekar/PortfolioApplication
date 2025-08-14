import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AssetAllocationPieChart extends StatelessWidget {
  final double goldPercentage;
  final double silverPercentage;

  const AssetAllocationPieChart({
    super.key,
    required this.goldPercentage,
    required this.silverPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final List<_PieData> data = [
      _PieData('Gold', goldPercentage, const Color(0xFFFFD700)),
      _PieData('Silver', silverPercentage, const Color(0xFFC0C0C0)),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SfCircularChart(
        backgroundColor: Colors.transparent,
        tooltipBehavior: TooltipBehavior(enable: true),
        // Reduce the chart's margin to give more space for the labels
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        title: ChartTitle(
          text: 'Asset Allocation',
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
          alignment: ChartAlignment.near,
        ),
        series: <CircularSeries>[
          PieSeries<_PieData, String>(
            dataSource: data,
            xValueMapper: (_PieData data, _) => data.name,
            yValueMapper: (_PieData data, _) => data.value,
            pointColorMapper: (_PieData data, _) => data.color,
            // Reduce the radius to create more space for the labels
            radius: '70%',
            dataLabelMapper: (_PieData data, _) =>
                '${data.name} ${data.value.toStringAsFixed(0)}%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              // Use a smart overflow mode to prevent cropping
              overflowMode: OverflowMode.shift,
              connectorLineSettings: ConnectorLineSettings(
                type: ConnectorType.line,
                width: 1.5,
                length: '10%',
              ),
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieData {
  final String name;
  final double value;
  final Color color;

  _PieData(this.name, this.value, this.color);
}
