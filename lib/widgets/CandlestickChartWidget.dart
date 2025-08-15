import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/portfolio_model.dart'; // Make sure this path is correct

class CandlestickChartWidget extends StatelessWidget {
  final List<CandleData> seriesData;

  const CandlestickChartWidget({Key? key, required this.seriesData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black, // ✅ Card background
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Candlestick Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // ✅ Text color for dark background
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                backgroundColor: Colors.black, // ✅ Chart background
                plotAreaBackgroundColor: Colors.black,
                primaryXAxis: DateTimeAxis(
                  axisLine: const AxisLine(color: Colors.white),
                  majorGridLines: const MajorGridLines(color: Colors.grey),
                  majorTickLines: const MajorTickLines(color: Colors.white),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(color: Colors.white),
                  majorGridLines: const MajorGridLines(color: Colors.grey),
                  majorTickLines: const MajorTickLines(color: Colors.white),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                series: <CandleSeries<CandleData, DateTime>>[
                  CandleSeries<CandleData, DateTime>(
                    dataSource: seriesData,
                    xValueMapper: (CandleData data, _) => data.time,
                    lowValueMapper: (CandleData data, _) => data.low,
                    highValueMapper: (CandleData data, _) => data.high,
                    openValueMapper: (CandleData data, _) => data.open,
                    closeValueMapper: (CandleData data, _) => data.close,
                    bullColor: Colors.green,
                    bearColor: Colors.red,
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
