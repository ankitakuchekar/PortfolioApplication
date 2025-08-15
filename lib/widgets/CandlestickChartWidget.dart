import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class CandleData {
  final DateTime x;
  final num open;
  final num high;
  final num low;
  final num close;

  CandleData(this.x, this.open, this.high, this.low, this.close);
}

class MetalCandleChart extends StatefulWidget {
  final List<MetalCandleChartEntry> candleChartData;
  final String selectedMetal;

  const MetalCandleChart({
    Key? key,
    required this.candleChartData,
    required this.selectedMetal,
  }) : super(key: key);

  @override
  _MetalCandleChartState createState() => _MetalCandleChartState();
}

class _MetalCandleChartState extends State<MetalCandleChart> {
  List<CandleData> _groupedData = [];
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _groupedData = _groupCandles(
      widget.candleChartData,
      5,
      widget.selectedMetal == 'Gold',
    );

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      tooltipPosition: TooltipPosition.pointer,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final CandleData candle = data as CandleData;
            final formattedDate =
                '${candle.x.month}/${candle.x.day} ${candle.x.hour}:${candle.x.minute.toString().padLeft(2, '0')}';
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Open: \$${candle.open.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF00cc00)),
                  ),
                  Text(
                    'High: \$${candle.high.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF00cc00)),
                  ),
                  Text(
                    'Low: \$${candle.low.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFFff3333)),
                  ),
                  Text(
                    'Close: \$${candle.close.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enablePanning: true,
      enableMouseWheelZooming: true,
      zoomMode: ZoomMode.x,
      // maximumZoomLevel: 0, // ❌ Removed to allow full zoom out
    );
  }

  @override
  void didUpdateWidget(covariant MetalCandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candleChartData != widget.candleChartData ||
        oldWidget.selectedMetal != widget.selectedMetal) {
      setState(() {
        _groupedData = _groupCandles(
          widget.candleChartData,
          5,
          widget.selectedMetal == 'Gold',
        );
      });
    }
  }

  List<CandleData> _groupCandles(
    List<MetalCandleChartEntry> data,
    int groupSize,
    bool useGold,
  ) {
    final groupedData = <CandleData>[];
    for (int i = 0; i < data.length; i += groupSize) {
      final group = data.sublist(
        i,
        i + groupSize <= data.length ? i + groupSize : data.length,
      );
      if (group.isNotEmpty) {
        final open = useGold ? group[0].openGold : group[0].openSilver;
        final close = useGold
            ? (group.last.closeGold != 0
                  ? group.last.closeGold
                  : group.last.openGold)
            : (group.last.closeSilver != 0
                  ? group.last.closeSilver
                  : group.last.openSilver);

        final highValues = useGold
            ? group.map((d) => d.highGold).where((v) => v > 0)
            : group.map((d) => d.highSilver).where((v) => v > 0);
        final lowValues = useGold
            ? group.map((d) => d.lowGold).where((v) => v > 0)
            : group.map((d) => d.lowSilver).where((v) => v > 0);

        final high = highValues.isNotEmpty
            ? highValues.reduce((a, b) => a > b ? a : b)
            : open;
        final low = lowValues.isNotEmpty
            ? lowValues.reduce((a, b) => a < b ? a : b)
            : open;

        if (open > 0 && high > 0 && low > 0 && close > 0) {
          groupedData.add(
            CandleData(
              group.first.intervalStart,
              double.parse(open.toStringAsFixed(2)),
              double.parse(high.toStringAsFixed(2)),
              double.parse(low.toStringAsFixed(2)),
              double.parse(close.toStringAsFixed(2)),
            ),
          );
        }
      }
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      backgroundColor: const Color(0xFF1a1a1a),
      title: ChartTitle(
        text: widget.selectedMetal == 'Gold'
            ? 'Live Gold Holdings'
            : 'Live Silver Holdings',
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      tooltipBehavior: _tooltipBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        lineColor: Colors.white, // ⚪ White crosshair lines
        lineWidth: 1,
        lineDashArray: [4, 4], // 🔲 Dotted lines
      ),
      primaryXAxis: DateTimeAxis(
        initialZoomFactor: 1.0, // ✅ Full zoom out on X-axis
        initialZoomPosition: 0.0,
        majorGridLines: const MajorGridLines(
          color: Color(0xFF333333),
          dashArray: [4, 4],
        ),
        axisLine: const AxisLine(color: Color(0xFF404040)),
        majorTickLines: const MajorTickLines(color: Color(0xFF404040)),
        labelStyle: const TextStyle(color: Color(0xFF8c8c8c), fontSize: 12),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat('R\$#,##0.00'),
        majorGridLines: const MajorGridLines(
          color: Color(0xFF333333),
          dashArray: [4, 4],
        ),
        axisLine: const AxisLine(color: Color(0xFF404040)),
        majorTickLines: const MajorTickLines(color: Color(0xFF404040)),
        labelStyle: const TextStyle(color: Color(0xFF8c8c8c), fontSize: 12),
      ),
      series: <CartesianSeries>[
        CandleSeries<CandleData, DateTime>(
          dataSource: _groupedData,
          xValueMapper: (CandleData data, _) => data.x,
          openValueMapper: (CandleData data, _) => data.open,
          highValueMapper: (CandleData data, _) => data.high,
          lowValueMapper: (CandleData data, _) => data.low,
          closeValueMapper: (CandleData data, _) => data.close,
          bearColor: const Color(0xFFff3333),
          bullColor: const Color(0xFF00cc00),
        ),
      ],
    );
  }
}
