import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MetalCandleChartEntry {
  final DateTime intervalStart;
  final double open;
  final double high;
  final double low;
  final double close;

  MetalCandleChartEntry({
    required this.intervalStart,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class ApexChartFlutter extends StatefulWidget {
  final List<MetalCandleChartEntry> chartData;
  final bool isGold; // true => Gold, false => Silver

  const ApexChartFlutter({
    super.key,
    required this.chartData,
    required this.isGold,
  });

  @override
  State<ApexChartFlutter> createState() => _ApexChartFlutterState();
}

class _ApexChartFlutterState extends State<ApexChartFlutter> {
  late ZoomPanBehavior _zoomPanBehavior;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      zoomMode: ZoomMode.x,
      enableMouseWheelZooming: true,
    );

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      format: 'point.x : point.y',
      tooltipPosition: TooltipPosition.pointer,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: Colors.white),
                  onPressed: () => _zoomPanBehavior.zoomIn(),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: Colors.white),
                  onPressed: () => _zoomPanBehavior.zoomOut(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _zoomPanBehavior.reset(),
                ),
              ],
            ),
          ),
        SfCartesianChart(
          backgroundColor: Colors.black,
          plotAreaBackgroundColor: Colors.black,
          title: ChartTitle(
            text: widget.isGold ? 'Live Gold Holdings' : 'Live Silver Holdings',
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
            alignment: ChartAlignment.near,
          ),
          primaryXAxis: DateTimeAxis(
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat.jm(), // 5:00 PM, 12:00 AM
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            majorGridLines: MajorGridLines(color: Colors.grey.shade800),
            axisLine: AxisLine(color: Colors.grey.shade700),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          primaryYAxis: NumericAxis(
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            majorGridLines: MajorGridLines(color: Colors.grey.shade800),
            axisLine: AxisLine(color: Colors.grey.shade700),
            numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
          ),
          tooltipBehavior: _tooltipBehavior,
          zoomPanBehavior: _zoomPanBehavior,
          series: <CandleSeries<MetalCandleChartEntry, DateTime>>[
            CandleSeries<MetalCandleChartEntry, DateTime>(
              dataSource: widget.chartData,
              xValueMapper: (entry, _) => entry.intervalStart,
              lowValueMapper: (entry, _) => entry.low,
              highValueMapper: (entry, _) => entry.high,
              openValueMapper: (entry, _) => entry.open,
              closeValueMapper: (entry, _) => entry.close,
              bearColor: Colors.red,
              bullColor: Colors.green,
              width: 0.8,
              enableTooltip: true,
            ),
          ],
        ),
      ],
    );
  }
}
