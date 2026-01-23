import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  final List<ChartData> data;
  final String metal;
  final String selectedFilter;

  const ChartPage({
    super.key,
    required this.data,
    required this.metal,
    required this.selectedFilter,
  });

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  bool isLoading = false;
  List<ChartData> chartData = [];
  late String metalTitle;
  late String metalColor;
  late String metalUrl;
  late Map<String, dynamic> gradientFill;
  late double metalId;

  @override
  void initState() {
    super.initState();
    chartData = widget.data;
    metalTitle =
        "${widget.metal[0].toUpperCase()}${widget.metal.substring(1)} Spot Chart";
  }
  // -------------------- Helpers --------------------

  bool get _isShortRange =>
      widget.selectedFilter == "24H" || widget.selectedFilter == "1W";

  bool get _isSilver => widget.metal == "Silver";

  DateTime get _minX => widget.data.first.timestamp;
  DateTime get _maxX => widget.data.last.timestamp;

  Color get _borderColor =>
      _isSilver ? const Color(0xFF9E9E9E) : const Color(0xFFFFC107);

  LinearGradient get _areaGradient => LinearGradient(
    colors: _isSilver
        ? [
            const Color(0xFFBDBDBD).withOpacity(0.6),
            const Color(0xFFE0E0E0).withOpacity(0.15),
          ]
        : [
            const Color(0xFFFFC107).withOpacity(0.6),
            const Color(0xFFFFF3CD).withOpacity(0.15),
          ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // -------------------- X AXIS --------------------

  DateTimeAxis _buildXAxis() {
    switch (widget.selectedFilter) {
      case "24H":
        return DateTimeAxis(
          minimum: _minX,
          maximum: _maxX,
          intervalType: DateTimeIntervalType.hours,
          interval: 1,
          dateFormat: DateFormat('hh:mm a'),
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: const TextStyle(fontSize: 12),
        );

      case "1W":
        return DateTimeAxis(
          intervalType: DateTimeIntervalType.days,
          interval: 1,
          dateFormat: DateFormat('dd MMM'),
        );

      case "1M":
      case "6M":
      case "1Y":
      case "YTD":
        return DateTimeAxis(
          intervalType: DateTimeIntervalType.months,
          interval: 1,
          dateFormat: DateFormat('MMM yyyy'),
        );

      case "5Y":
      case "All":
        return DateTimeAxis(
          intervalType: DateTimeIntervalType.years,
          interval: 1,
          dateFormat: DateFormat('yyyy'),
        );

      default:
        return DateTimeAxis();
    }
  }

  // -------------------- Y AXIS --------------------

  NumericAxis _buildTightYAxis() {
    final min = widget.data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final max = widget.data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final padding = (max - min) * 0.15;

    return NumericAxis(
      minimum: min - padding,
      maximum: max + padding,
      interval: (max - min) / 4,
      numberFormat: NumberFormat.currency(symbol: '\$'),
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  NumericAxis _buildWideYAxis() {
    final min = widget.data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final max = widget.data.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    final roundedMin = (min / 500).floor() * 500;
    final roundedMax = (max / 500).ceil() * 500;

    return NumericAxis(
      minimum: roundedMin.toDouble(),
      maximum: roundedMax.toDouble(),
      interval: 500,
      numberFormat: NumberFormat.currency(symbol: '\$'),
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('EEEE, dd MMM • hh:mm a').format(date);
  }

  // -------------------- TRACKBALL --------------------
  TrackballBehavior get _trackballBehavior => TrackballBehavior(
    enable: true,

    // 🔥 IMPORTANT: use singleTap
    activationMode: ActivationMode.singleTap,

    lineType: TrackballLineType.vertical,
    lineWidth: 1,
    lineColor: Colors.grey,

    tooltipSettings: const InteractiveTooltip(
      enable: true,
      color: Colors.transparent, // builder will handle UI
    ),

    markerSettings: const TrackballMarkerSettings(
      markerVisibility: TrackballVisibilityMode.visible,
      height: 8,
      width: 8,
    ),
    builder: (BuildContext context, TrackballDetails details) {
      if (details.pointIndex == null) {
        return const SizedBox.shrink();
      }

      final data = widget.data[details.pointIndex!];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 PRICE LABEL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: Text(
              '${widget.metal.toUpperCase()}  ₹${data.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 2),

          // 🔹 X-AXIS LABEL (DAY + DATE + TIME)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDateTime(data.timestamp),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(metalTitle)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : chartData.isEmpty
          ? Center(child: Text('No data available'))
          : SfCartesianChart(
              trackballBehavior: _trackballBehavior,

              plotAreaBorderWidth: 0,

              primaryXAxis: _buildXAxis(),
              primaryYAxis: _isShortRange
                  ? _buildTightYAxis()
                  : _buildWideYAxis(),

              series: <CartesianSeries>[
                AreaSeries<ChartData, DateTime>(
                  dataSource: widget.data,
                  xValueMapper: (d, _) => d.timestamp,
                  yValueMapper: (d, _) => d.price,
                  borderWidth: 2,
                  borderColor: _borderColor,
                  gradient: _areaGradient,
                ),
              ],
            ),
    );
  }
}

// -------------------- MODEL --------------------

class ChartData {
  final DateTime timestamp;
  final double price;

  ChartData({required this.timestamp, required this.price});

  factory ChartData.fromJson(List<dynamic> item) {
    return ChartData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(item[0]),
      price: (item[1] as num).toDouble(),
    );
  }
}
