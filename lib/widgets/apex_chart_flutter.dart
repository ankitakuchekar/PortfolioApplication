import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

    // This tooltip behavior is more aligned with your Next.js chart
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      tooltipPosition: TooltipPosition.auto,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final entry = data as MetalCandleChartEntry;
        final double open, high, low, close;

        // Use the correct data based on the selected metal
        if (widget.isGold) {
          open = entry.openGold;
          high = entry.highGold;
          low = entry.lowGold;
          close = entry.closeGold;
        } else {
          open = entry.openSilver;
          high = entry.highSilver;
          low = entry.lowSilver;
          close = entry.closeSilver;
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM d, hh:mm a').format(entry.intervalStart),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Open: \$${open.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'High: \$${high.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Low: \$${low.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Close: \$${close.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
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
        Expanded(
          child: SfCartesianChart(
            backgroundColor: Colors.black,
            plotAreaBackgroundColor: Colors.black,
            title: ChartTitle(
              text: widget.isGold
                  ? 'Live Gold Holdings'
                  : 'Live Silver Holdings',
              textStyle: const TextStyle(color: Colors.white, fontSize: 18),
              alignment: ChartAlignment.near,
            ),
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.hours,
              dateFormat: DateFormat.jm(),
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
                lowValueMapper: (entry, _) =>
                    widget.isGold ? entry.lowGold : entry.lowSilver,
                highValueMapper: (entry, _) =>
                    widget.isGold ? entry.highGold : entry.highSilver,
                openValueMapper: (entry, _) =>
                    widget.isGold ? entry.openGold : entry.openSilver,
                closeValueMapper: (entry, _) =>
                    widget.isGold ? entry.closeGold : entry.closeSilver,
                bearColor: Colors.red,
                bullColor: Colors.green,
                width: 0.8,
                enableTooltip: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
