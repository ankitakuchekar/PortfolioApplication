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
  // List<CandleData> _groupedData = [];
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
      width: 28, // Adjust width/height for smaller/larger button
      height: 28,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2c2c2c),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 12), // Smaller icon size
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(), // Remove min constraints
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? rightMost;

    if (widget.showCombined) {
      if (_goldData.isNotEmpty && _silverData.isNotEmpty) {
        rightMost = _goldData.last.x.isAfter(_silverData.last.x)
            ? _goldData.last.x
            : _silverData.last.x;
      } else if (_goldData.isNotEmpty) {
        rightMost = _goldData.last.x;
      } else if (_silverData.isNotEmpty) {
        rightMost = _silverData.last.x;
      }
    } else {
      final data = widget.selectedMetal == 'Gold' ? _goldData : _silverData;
      if (data.isNotEmpty) rightMost = data.last.x;
    }

    // ✅ fallback to "now" if still null
    rightMost ??= DateTime.now();

    // add custom padding
    final DateTime xAxisMaxDate = rightMost.add(const Duration(hours: 3));

    debugPrint('rightMost: $rightMost  xAxisMaxDate: $xAxisMaxDate');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Bar: Metal Selector + Title + Zoom Buttons
        Container(
          color: Colors.black, // Background for entire top section
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Chart Title
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

              // Right side: Zoom buttons
              Row(
                children: [
                  _buildChartButton(Icons.add, 'Zoom In', () {
                    _zoomPanBehavior.zoomIn();
                  }),
                  const SizedBox(width: 10),
                  _buildChartButton(Icons.remove, 'Zoom Out', () {
                    _zoomPanBehavior.zoomOut();
                  }),
                  const SizedBox(width: 10),
                  _buildChartButton(Icons.home, 'Reset Zoom', () {
                    _zoomPanBehavior.reset();
                  }),
                ],
              ),
            ],
          ),
        ),

        // Chart
        Expanded(
          child: SfCartesianChart(
            backgroundColor: const Color(0xFF1a1a1a),
            tooltipBehavior: _tooltipBehavior,
            zoomPanBehavior: _zoomPanBehavior,
            crosshairBehavior: _crosshairBehavior,
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.minutes,
              interval: 35,
              dateFormat: MediaQuery.of(context).size.width < 768
                  ? DateFormat('hh:mm a')
                  : DateFormat('MMM dd hh:mm a'),
              majorGridLines: const MajorGridLines(
                color: Color(0xFF333333),
                dashArray: [4, 4],
              ),
              axisLine: const AxisLine(color: Color(0xFF404040)),
              majorTickLines: const MajorTickLines(color: Color(0xFF404040)),
              labelStyle: TextStyle(
                color: const Color(0xFF8c8c8c),
                fontSize: MediaQuery.of(context).size.width < 768 ? 10 : 12,
              ),
              rangePadding: ChartRangePadding.none,
              maximum: xAxisMaxDate, // manual padding
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.currency(
                symbol: '\$',
                decimalDigits: 2,
              ),
              majorGridLines: const MajorGridLines(
                color: Color(0xFF333333),
                dashArray: [4, 4],
              ),
              axisLine: const AxisLine(color: Color(0xFF404040)),
              majorTickLines: const MajorTickLines(color: Color(0xFF404040)),
              labelStyle: TextStyle(
                color: const Color(0xFF8c8c8c),
                fontSize: MediaQuery.of(context).size.width < 768 ? 10 : 12,
              ),
            ),
            series: <CartesianSeries>[
              if (widget.showCombined) ...[
                CandleSeries<CandleData, DateTime>(
                  name: 'Gold',
                  dataSource: _goldData,
                  xValueMapper: (CandleData data, _) => data.x,
                  openValueMapper: (CandleData data, _) => data.open,
                  highValueMapper: (CandleData data, _) => data.high,
                  lowValueMapper: (CandleData data, _) => data.low,
                  closeValueMapper: (CandleData data, _) => data.close,
                  bearColor: const Color(0xFFff3333),
                  bullColor: const Color(0xFF00cc00),
                  enableSolidCandles: true,
                ),
                CandleSeries<CandleData, DateTime>(
                  name: 'Silver',
                  dataSource: _silverData,
                  xValueMapper: (CandleData data, _) => data.x,
                  openValueMapper: (CandleData data, _) => data.open,
                  highValueMapper: (CandleData data, _) => data.high,
                  lowValueMapper: (CandleData data, _) => data.low,
                  closeValueMapper: (CandleData data, _) => data.close,
                  bearColor: const Color(0xFFff3333),
                  bullColor: const Color(0xFF00cc00),
                  enableSolidCandles: true,
                ),
              ] else ...[
                CandleSeries<CandleData, DateTime>(
                  dataSource: widget.selectedMetal == 'Gold'
                      ? _goldData
                      : _silverData,
                  xValueMapper: (CandleData data, _) => data.x,
                  openValueMapper: (CandleData data, _) => data.open,
                  highValueMapper: (CandleData data, _) => data.high,
                  lowValueMapper: (CandleData data, _) => data.low,
                  closeValueMapper: (CandleData data, _) => data.close,
                  // bearColor: widget.selectedMetal == 'Gold'
                  //     ? const Color(0xFFff3333)
                  //     : Colors.blueGrey.shade300,
                  bearColor: const Color(0xFFff3333),
                  bullColor: const Color(0xFF00cc00),
                  enableSolidCandles: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
