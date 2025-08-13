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
    return SfCircularChart(
      backgroundColor: Colors.transparent,
      title: ChartTitle(
        text: 'Asset Allocation',
        textStyle: const TextStyle(color: Colors.white, fontSize: 18),
        alignment: ChartAlignment.near,
      ),
      series: <CircularSeries>[
        PieSeries<_PieData, String>(
          dataSource: [
            _PieData('Gold', goldPercentage, const Color(0xFFFFD700)),
            _PieData('Silver', silverPercentage, const Color(0xFFC0C0C0)),
          ],
          xValueMapper: (_PieData data, _) => data.name,
          yValueMapper: (_PieData data, _) => data.value,
          pointColorMapper: (_PieData data, _) => data.color,
          dataLabelMapper: (_PieData data, _) =>
              '${data.name} ${data.value.toStringAsFixed(0)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _PieData {
  final String name;
  final double value;
  final Color color;

  _PieData(this.name, this.value, this.color);
}
