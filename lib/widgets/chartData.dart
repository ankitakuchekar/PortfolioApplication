import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  final List<ChartData> data;
  final String metal;
  final String selectedFilter;

  const ChartPage({
    Key? key,
    required this.data,
    required this.metal,
    required this.selectedFilter,
  }) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
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

  bool get _isShortRange {
    return widget.selectedFilter == "24H" || widget.selectedFilter == "1W";
  }

  String spotBaseUrl = dotenv.env['SPOT_API_URL']!;

  double get minY =>
      chartData.map((e) => e.price).reduce((a, b) => a < b ? a : b) - 1;

  double get maxY =>
      chartData.map((e) => e.price).reduce((a, b) => a > b ? a : b) + 1;

  DateTime get _minX => widget.data.first.timestamp;

  DateTime get _maxX => widget.data.last.timestamp;

  DateTimeAxis _build24HXAxis() {
    return DateTimeAxis(
      minimum: _minX,
      maximum: _maxX,

      intervalType: DateTimeIntervalType.hours,
      interval: 1, // ✅ Gives 4–6 labels

      dateFormat: DateFormat('hh:mm a'),
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
      labelStyle: const TextStyle(fontSize: 12),

      // 🔥 VERY IMPORTANT
      autoScrollingMode: AutoScrollingMode.end,
    );
  }

  DateTimeAxis _buildXAxis() {
    switch (widget.selectedFilter) {
      case "24H":
        return _build24HXAxis();

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

  NumericAxis _buildTightYAxis() {
    final min = widget.data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final max = widget.data.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    final padding = (max - min) * 0.15; // 15% padding

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

  Color get _borderColor => widget.metal == "Silver"
      ? const Color(0xFF9E9E9E)
      : const Color(0xFFFFC107);

  LinearGradient get _areaGradient => LinearGradient(
    colors: widget.metal == "Silver"
        ? [
            const Color(0xFFBDBDBD).withOpacity(0.6), // silver
            const Color.fromARGB(255, 187, 183, 183).withOpacity(0.15),
          ]
        : [
            const Color(0xFFFFC107).withOpacity(0.6), // gold
            const Color.fromARGB(255, 245, 210, 96).withOpacity(0.15),
          ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(metalTitle)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : chartData.isEmpty
          ? Center(child: Text('No data available'))
          : SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: _buildXAxis(),
              primaryYAxis: _isShortRange
                  ? _buildTightYAxis()
                  : _buildWideYAxis(),
              tooltipBehavior: TooltipBehavior(enable: true),

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

class ChartData {
  final DateTime timestamp;
  final double price;

  ChartData({required this.timestamp, required this.price});

  // Add this factory method to parse List<dynamic> from API
  factory ChartData.fromJson(List<dynamic> item) {
    return ChartData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(item[0]),
      price: (item[1] as num).toDouble(),
    );
  }
}
