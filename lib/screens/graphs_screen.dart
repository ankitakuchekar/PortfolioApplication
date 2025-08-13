// Add this import
import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';

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
  final bool isGold;

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

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  String selectedTimeRange = '1M';
  String selectedMetalType = 'All';

  final List<String> timeRanges = ['1W', '1M', '3M', '1Y', 'All'];
  final List<String> metalTypes = ['All', 'Gold', 'Silver'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portfolio Charts'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final portfolioData = portfolioProvider.portfolioData;
          if (portfolioData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final metalCandleCharts = portfolioData.customerData.metalCandleChart;

          List<MetalCandleChartEntry> filteredMetalData = [];

          if (selectedMetalType == 'Gold') {
            filteredMetalData = metalCandleCharts
                .where(
                  (entry) =>
                      entry.openGold != null &&
                      entry.highGold != null &&
                      entry.lowGold != null &&
                      entry.closeGold != null,
                )
                .map(
                  (entry) => MetalCandleChartEntry(
                    intervalStart: entry.intervalStart,
                    open: entry.openGold,
                    close: entry.closeGold,
                    high: entry.highGold,
                    low: entry.lowGold,
                  ),
                )
                .toList();
          } else if (selectedMetalType == 'Silver') {
            filteredMetalData = metalCandleCharts
                .where(
                  (entry) =>
                      entry.openSilver != null &&
                      entry.highSilver != null &&
                      entry.lowSilver != null &&
                      entry.closeSilver != null,
                )
                .map(
                  (entry) => MetalCandleChartEntry(
                    intervalStart: entry.intervalStart,
                    open: entry.openSilver,
                    close: entry.closeSilver,
                    high: entry.highSilver,
                    low: entry.lowSilver,
                  ),
                )
                .toList();

            // 🔁 Fallback to Gold if Silver data is not available
            if (filteredMetalData.isEmpty) {
              filteredMetalData = metalCandleCharts
                  .where(
                    (entry) =>
                        entry.openGold != null &&
                        entry.highGold != null &&
                        entry.lowGold != null &&
                        entry.closeGold != null,
                  )
                  .map(
                    (entry) => MetalCandleChartEntry(
                      intervalStart: entry.intervalStart,
                      open: entry.openGold,
                      close: entry.closeGold,
                      high: entry.highGold,
                      low: entry.lowGold,
                    ),
                  )
                  .toList();
              selectedMetalType = 'Gold';
            }
          } else {
            filteredMetalData = metalCandleCharts
                .map(
                  (entry) => MetalCandleChartEntry(
                    intervalStart: entry.intervalStart,
                    open: entry.openGold,
                    close: entry.closeGold,
                    high: entry.highGold,
                    low: entry.lowGold,
                  ),
                )
                .toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  color: AppColors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metal Price Candlestick Chart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: ApexChartFlutter(
                            chartData: filteredMetalData,
                            isGold: selectedMetalType != 'Silver',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Metal Type Selector
                Card(
                  color: AppColors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: metalTypes.map((type) {
                        final isSelected = selectedMetalType == type;
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedMetalType = type;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
