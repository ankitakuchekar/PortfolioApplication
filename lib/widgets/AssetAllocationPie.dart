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

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Asset Allocation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          height: 240, // More height to separate labels from pie
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pie chart
              SizedBox(
                height: 200,
                width: 200,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <CircularSeries>[
                    PieSeries<_PieData, String>(
                      dataSource: data,
                      xValueMapper: (_PieData data, _) => data.name,
                      yValueMapper: (_PieData data, _) => data.value,
                      pointColorMapper: (_PieData data, _) => data.color,
                      radius: '100%',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: false, // Disable default labels
                      ),
                    ),
                  ],
                ),
              ),
              // Gold label above the pie
              Positioned(
                bottom: 0,
                child: Text(
                  'Gold ${goldPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
              // Silver label below the pie
              Positioned(
                top: 0,
                child: Text(
                  'Silver ${silverPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC0C0C0),
                  ),
                ),
              ),
            ],
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
