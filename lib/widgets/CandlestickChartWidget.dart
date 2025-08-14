import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/portfolio_model.dart'; // Ensure this path is correct

class CandlestickChartWidget extends StatelessWidget {
  final List<CandleData> seriesData;

  const CandlestickChartWidget({Key? key, required this.seriesData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Candlestick Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                primaryYAxis: NumericAxis(),
                series: <CandleSeries<CandleData, DateTime>>[
                  CandleSeries<CandleData, DateTime>(
                    dataSource: seriesData,
                    xValueMapper: (CandleData data, _) => data.time,
                    lowValueMapper: (CandleData data, _) => data.low,
                    highValueMapper: (CandleData data, _) => data.high,
                    openValueMapper: (CandleData data, _) => data.open,
                    closeValueMapper: (CandleData data, _) => data.close,
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
