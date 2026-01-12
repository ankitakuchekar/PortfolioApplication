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
  final bool showCombined;

  const MetalCandleChart({
    super.key,
    required this.candleChartData,
    required this.selectedMetal,
    this.showCombined = false,
  });

  @override
  _MetalCandleChartState createState() => _MetalCandleChartState();
}

class _MetalCandleChartState extends State<MetalCandleChart> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late CrosshairBehavior _crosshairBehavior;

  List<CandleData> _goldData = [];
  List<CandleData> _silverData = [];

  @override
  void initState() {
    super.initState();
    _goldData = _groupCandles(
      widget.candleChartData,
      5,
      true,
      widget.selectedMetal,
    );
    _silverData = _groupCandles(
      widget.candleChartData,
      5,
      false,
      widget.selectedMetal,
    );

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      shouldAlwaysShow: false,
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
            final formattedDate = DateFormat(
              'MMM dd, hh:mm a',
            ).format(candle.x);
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    'Open: ${formatPrice(candle.open)}',
                    style: const TextStyle(color: Color(0xFF00cc00)),
                  ),
                  Text(
                    'High: ${formatPrice(candle.high)}',
                    style: const TextStyle(color: Color(0xFF00cc00)),
                  ),
                  Text(
                    'Low: ${formatPrice(candle.low)}',
                    style: const TextStyle(color: Color(0xFFff3333)),
                  ),
                  Text(
                    'Close: ${formatPrice(candle.close)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );

    _crosshairBehavior = CrosshairBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Colors.white,
      lineDashArray: [4, 4],
      shouldAlwaysShow: false,
    );
  }

  @override
  void didUpdateWidget(covariant MetalCandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candleChartData != widget.candleChartData ||
        oldWidget.selectedMetal != widget.selectedMetal ||
        oldWidget.showCombined != widget.showCombined) {
      setState(() {
        _goldData = _groupCandles(
          widget.candleChartData,
          5,
          true,
          widget.selectedMetal,
        );
        _silverData = _groupCandles(
          widget.candleChartData,
          5,
          false,
          widget.selectedMetal,
        );
      });
    }
  }

  String formatPrice(num price) {
    final format = NumberFormat.simpleCurrency(locale: 'en_US');
    return format.format(price);
  }

  List<CandleData> _groupCandles(
    List<MetalCandleChartEntry> data,
    int groupSize,
    bool useGold,
    String selectedMetal,
  ) {
    final groupedData = <CandleData>[];
    for (int i = 0; i < data.length; i += groupSize) {
      final group = data.sublist(
        i,
        i + groupSize <= data.length ? i + groupSize : data.length,
      );
      if (group.isNotEmpty) {
        final open = selectedMetal == 'All'
            ? group[0].openMetal
            : useGold
            ? group[0].openGold
            : group[0].openSilver;
        final close = selectedMetal == 'All'
            ? (group.last.closeMetal != 0
                  ? group.last.closeMetal
                  : group.last.openMetal)
            : useGold
            ? (group.last.closeGold != 0
                  ? group.last.closeGold
                  : group.last.openGold)
            : (group.last.closeSilver != 0
                  ? group.last.closeSilver
                  : group.last.openSilver);

        final highValues = selectedMetal == 'All'
            ? group.map((d) => d.highMetal).where((v) => v > 0)
            : useGold
            ? group.map((d) => d.highGold).where((v) => v > 0)
            : group.map((d) => d.highSilver).where((v) => v > 0);
        final lowValues = selectedMetal == 'All'
            ? group.map((d) => d.lowMetal).where((v) => v > 0)
            : useGold
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

  Widget _buildChartButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2c2c2c),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 12),
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final dataSource = widget.selectedMetal == 'Gold' ? _goldData : _silverData;

    // Determine initial visible range (last 12 candles) with padding
    const int visibleCandlesCount = 12;
    DateTime initialMin;
    DateTime initialMax;

    if (dataSource.isNotEmpty) {
      final dataLength = dataSource.length;

      if (dataLength > visibleCandlesCount) {
        initialMin = dataSource[dataLength - visibleCandlesCount].x;
        initialMax = dataSource.last.x;

        // Add half candle padding to both ends to avoid cutting
        final candleInterval = dataSource[1].x.difference(dataSource[0].x);
        initialMin = initialMin.subtract(candleInterval * 1.5);
        initialMax = initialMax.add(candleInterval * 1.5);
      } else if (dataLength > 1) {
        initialMin = dataSource.first.x;
        initialMax = dataSource.last.x;

        final candleInterval = dataSource[1].x.difference(dataSource[0].x);
        initialMin = initialMin.subtract(candleInterval * 1.5);
        initialMax = initialMax.add(candleInterval * 1.5);
      } else {
        // Only one candle
        initialMin = dataSource.first.x.subtract(const Duration(minutes: 5));
        initialMax = dataSource.first.x.add(const Duration(minutes: 5));
      }
    } else {
      // No data, fallback to now
      initialMin = DateTime.now().subtract(const Duration(minutes: 5));
      initialMax = DateTime.now().add(const Duration(minutes: 5));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.showCombined
                    ? 'Live Both Holdings'
                    : widget.selectedMetal == 'Gold'
                    ? 'Live Gold Holdings'
                    : 'Live Silver Holdings',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildChartButton(
                    Icons.add,
                    'Zoom In',
                    () => _zoomPanBehavior.zoomIn(),
                  ),
                  _buildChartButton(
                    Icons.remove,
                    'Zoom Out',
                    () => _zoomPanBehavior.zoomOut(),
                  ),
                  _buildChartButton(
                    Icons.home,
                    'Reset Zoom',
                    () => _zoomPanBehavior.reset(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chart
        Expanded(
          child: SfCartesianChart(
            backgroundColor: const Color(0xFF1a1a1a),
            plotAreaBorderWidth: 0,
            tooltipBehavior: _tooltipBehavior,
            zoomPanBehavior: _zoomPanBehavior,
            crosshairBehavior: _crosshairBehavior,
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.minutes,
              dateFormat: DateFormat('hh:mm a'),
              initialVisibleMinimum: initialMin,
              initialVisibleMaximum: initialMax,
              majorGridLines: const MajorGridLines(
                color: Color(0xFF333333),
                dashArray: [4, 4],
              ),
            ),
            primaryYAxis: NumericAxis(
              decimalPlaces: 2,
              rangePadding: ChartRangePadding.additional,
              majorGridLines: const MajorGridLines(
                color: Color(0xFF333333),
                dashArray: [4, 4],
              ),
              majorTickLines: const MajorTickLines(color: Color(0xFF404040)),
              axisLine: const AxisLine(color: Color(0xFF404040)),
              labelStyle: TextStyle(
                color: const Color(0xFF8c8c8c),
                fontSize: MediaQuery.of(context).size.width < 768 ? 10 : 12,
              ),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                  '\$${details.value.toStringAsFixed(2)}',
                  const TextStyle(color: Color(0xFF8c8c8c)),
                );
              },
            ),
            series: <CartesianSeries>[
              CandleSeries<CandleData, DateTime>(
                dataSource: dataSource,
                xValueMapper: (CandleData data, _) => data.x,
                openValueMapper: (CandleData data, _) => data.open,
                highValueMapper: (CandleData data, _) => data.high,
                lowValueMapper: (CandleData data, _) => data.low,
                closeValueMapper: (CandleData data, _) => data.close,
                bullColor: const Color(0xFF00cc00),
                bearColor: const Color(0xFFff3333),
                enableSolidCandles: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
