import 'dart:convert';

import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// Data class to hold controllers for each prediction quarter
class Prediction {
  final String quarter;
  final Map<String, String> optimal;
  final Map<String, String> worst;

  // Add these controller fields
  final TextEditingController silverOptimalController;
  final TextEditingController silverWorstController;
  final TextEditingController goldOptimalController;
  final TextEditingController goldWorstController;

  Prediction({
    required this.quarter,
    required this.optimal,
    required this.worst,
  }) : silverOptimalController = TextEditingController(text: optimal['silver']),
       silverWorstController = TextEditingController(text: worst['silver']),
       goldOptimalController = TextEditingController(text: optimal['gold']),
       goldWorstController = TextEditingController(text: worst['gold']);

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final optimal = Map<String, String>.from(json['optimal'] ?? {});
    final worst = Map<String, String>.from(json['worst'] ?? {});

    return Prediction(
      quarter: json['quarter'] ?? '',
      optimal: optimal,
      worst: worst,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quarter': quarter,
      'optimal': {
        'silver': silverOptimalController.text,
        'gold': goldOptimalController.text,
      },
      'worst': {
        'silver': silverWorstController.text,
        'gold': goldWorstController.text,
      },
    };
  }
}

class PredictionPopup extends StatefulWidget {
  const PredictionPopup({Key? key}) : super(key: key);

  @override
  _PredictionPopupState createState() => _PredictionPopupState();
}

class _PredictionPopupState extends State<PredictionPopup> {
  List<Prediction> predictionsData = [];
  bool _isAddQuarterButtonEnabled = false;
  bool _isSaving = false;
  bool _isLoading = true;

  // For showing market data (analyst averages) if needed
  List<Map<String, String>> marketData = [];

  // Colors etc.
  final Color _optimalColor = const Color(0xFF28A745);
  final Color _worstColor = const Color(0xFFDC3545);
  final Color _quarterTitleColor = const Color(0xFF4C51BF);
  final Color _primaryTextColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    // Initialize with a default (in case fetch fails or no data)
    predictionsData = [
      Prediction(quarter: _nextFourQuarters().first, optimal: {}, worst: {}),
    ];
    _addListenersToLastQuarter();
    _fetchInitialData();
  }

  @override
  void dispose() {
    if (predictionsData.isNotEmpty) {
      _removeListenersFromLastQuarter();
    }
    for (var p in predictionsData) {
      p.silverOptimalController.dispose();
      p.silverWorstController.dispose();
      p.goldOptimalController.dispose();
      p.goldWorstController.dispose();
    }
    super.dispose();
  }

  List<String> getNextFourQuarters() {
    final currentQuarter = getCurrentQuarter();
    List<String> quarters = [];
    String nextQuarter = currentQuarter;

    if (!isQuarterEnded(currentQuarter)) {
      quarters.add(currentQuarter);
    }

    while (quarters.length < 4) {
      nextQuarter = getNextQuarter(nextQuarter);
      if (!isQuarterEnded(nextQuarter)) {
        quarters.add(nextQuarter);
      }
    }

    // Safety net — optional if the first loop is enough
    while (quarters.length < 4) {
      nextQuarter = getNextQuarter(nextQuarter);
      quarters.add(nextQuarter);
    }

    return quarters;
  }

  String getCurrentQuarter() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if (month >= 1 && month <= 3) return 'Q1 $year';
    if (month >= 4 && month <= 6) return 'Q2 $year';
    if (month >= 7 && month <= 9) return 'Q3 $year';
    return 'Q4 $year';
  }

  String getNextQuarter(String currentQuarter) {
    final parts = currentQuarter.split(' ');
    final currentQ = parts[0]; // e.g., "Q4"
    final year = int.parse(parts[1]);

    final nextQMap = {'Q1': 'Q2', 'Q2': 'Q3', 'Q3': 'Q4', 'Q4': 'Q1'};

    final nextQ = nextQMap[currentQ]!;
    final nextYear = currentQ == 'Q4' ? year + 1 : year;

    return '$nextQ $nextYear';
  }

  bool isQuarterEnded(String quarter) {
    final today = DateTime.now();
    final parts = quarter.split(' ');
    final q = parts[0]; // e.g. "Q1"
    final year = int.parse(parts[1]);

    final endDates = {
      'Q1': DateTime(year, 4, 1), // April 1 (Q1 ends March 31)
      'Q2': DateTime(year, 7, 1), // July 1 (Q2 ends June 30)
      'Q3': DateTime(year, 10, 1), // October 1 (Q3 ends Sep 30)
      'Q4': DateTime(year + 1, 1, 1), // Jan 1 of next year (Q4 ends Dec 31)
    };

    return today.isAfter(endDates[q]!);
  }

  String dateToQuarter(String dateString) {
    final parts = dateString.split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format. Expected MM/DD/YYYY');
    }

    final month = int.parse(parts[0]);
    final year = int.parse(parts[2]);

    if (month >= 1 && month <= 3) return 'Q1 $year';
    if (month >= 4 && month <= 6) return 'Q2 $year';
    if (month >= 7 && month <= 9) return 'Q3 $year';
    return 'Q4 $year';
  }

  // === Fetch & process data ===
  Future<void> _fetchInitialData() async {
    try {
      final authService = AuthService();
      final fetchedUser = await authService.getUser();
      final userId = fetchedUser?.id;
      final token = fetchedUser?.token;
      if (userId == null || token == null) {
        throw Exception("User not logged in");
      }
      final String baseUrl = dotenv.env['API_URL']!;
      final url = Uri.parse(
        "$baseUrl/Portfolio/GetCustomerPredictions?customerId=$userId",
      );
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("API error: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      final marketAnalystPredictions =
          decoded['data']['marketAnalystPredictions'] as List<dynamic>? ?? [];
      // Get next four quarters
      final nextFourQuarters = getNextFourQuarters();

      // Transform analyst predictions
      final analystPredictions = marketAnalystPredictions
          .map((item) {
            final dateStr = item['dateNTime']?.split(' ')?.first;
            final quarter = dateToQuarter(dateStr);

            return {
              'quarter': quarter,
              'silver': item['silver'],
              'gold': item['gold'],
            };
          })
          .where((pred) => !isQuarterEnded(pred['quarter']))
          .toList();
      // ✅ Group by quarter
      final groupedByQuarter = <String, Map<String, List<dynamic>>>{};

      for (final prediction in analystPredictions) {
        final quarter = prediction['quarter'];
        final silver = prediction['silver'];
        final gold = prediction['gold'];

        if (!groupedByQuarter.containsKey(quarter)) {
          groupedByQuarter[quarter] = {'silver': [], 'gold': []};
        }

        groupedByQuarter[quarter]!['silver']!.add(silver);
        groupedByQuarter[quarter]!['gold']!.add(gold);
      }

      // Format and average market data
      final formattedMarketData = groupedByQuarter.entries
          .map((entry) {
            final quarter = entry.key;
            final values = entry.value;

            final silverAvg =
                (values['silver']!.reduce((a, b) => a + b)) /
                values['silver']!.length;
            final goldAvg =
                (values['gold']!.reduce((a, b) => a + b)) /
                values['gold']!.length;

            return {
              'quarter': quarter,
              'silver': silverAvg.toStringAsFixed(2),
              'gold': goldAvg.toStringAsFixed(2),
            };
          })
          .where((data) => nextFourQuarters.contains(data['quarter']))
          .toList();

      // Sort by year then by quarter
      formattedMarketData.sort((a, b) {
        final qa = a['quarter']!.split(' ');
        final qb = b['quarter']!.split(' ');

        final ya = int.parse(qa[1]);
        final yb = int.parse(qb[1]);

        if (ya == yb) {
          const order = ['Q1', 'Q2', 'Q3', 'Q4'];
          return order.indexOf(qa[0]) - order.indexOf(qb[0]);
        }
        return ya - yb;
      });

      marketData = formattedMarketData
          .map(
            (item) => item.map((key, value) => MapEntry(key, value.toString())),
          )
          .toList();
      // Limit to 4 items
      final slicedFormattedMarketData = formattedMarketData.take(4).toList();
      // Step 1: Extract available quarters from formattedMarketData
      final availableQuarters = formattedMarketData
          .map((data) => data['quarter'] as String)
          .toList();
      // Step 2: Get quarterlyPredictedSpotPrices from decoded response
      final rawUserPredictions =
          decoded['data']['quarterlyPredictedSpotPrices'] as List<dynamic>? ??
          [];

      // Step 3: Map and filter user predictions
      List<Map<String, dynamic>> fetchedPredictions;

      if (rawUserPredictions.isNotEmpty) {
        fetchedPredictions = rawUserPredictions
            .map<Map<String, dynamic>>((item) {
              final dateStr = (item['dateNTime'] as String?)?.split(' ').first;
              final quarter = dateStr != null
                  ? dateToQuarter(dateStr)
                  : (availableQuarters.isNotEmpty
                        ? availableQuarters[0]
                        : nextFourQuarters[0]);

              String formatValue(dynamic val) {
                if (val == 0) return '';
                if (val == null) return '';
                return val.toString();
              }

              return {
                'quarter': quarter,
                'optimal': {
                  'silver': formatValue(item['silverOptimalPrediction']),
                  'gold': formatValue(item['goldOptimalPrediction']),
                },
                'worst': {
                  'silver': formatValue(item['silverWorstPrediction']),
                  'gold': formatValue(item['goldWorstPrediction']),
                },
              };
            })
            .where((pred) => availableQuarters.contains(pred['quarter']))
            .toList();

        // Sort by quarter (Q1 before Q2, etc.)
        fetchedPredictions.sort((a, b) {
          final qa = (a['quarter'] as String).split(' ');
          final qb = (b['quarter'] as String).split(' ');

          final ya = int.parse(qa[1]);
          final yb = int.parse(qb[1]);

          if (ya == yb) {
            const order = ['Q1', 'Q2', 'Q3', 'Q4'];
            return order.indexOf(qa[0]) - order.indexOf(qb[0]);
          }

          return ya - yb;
        });
      } else if (availableQuarters.isNotEmpty) {
        fetchedPredictions = [
          {
            'quarter': availableQuarters[0],
            'optimal': {'silver': '', 'gold': ''},
            'worst': {'silver': '', 'gold': ''},
          },
        ];
      } else {
        fetchedPredictions = [];
      }

      setState(() {
        predictionsData = fetchedPredictions
            .map((item) => Prediction.fromJson(item))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching initial data: $e");
      Fluttertoast.showToast(msg: "Failed to load prediction data.");
      // Leave predictions as the default
    }
  }

  // === Validations, listeners, helpers, UI building etc. (all your previous code) ===

  void _validateLastQuarter() {
    if (predictionsData.isEmpty) return;
    final last = predictionsData.last;

    bool isValid(TextEditingController c) {
      final text = c.text.trim();
      if (text.isEmpty) return false;
      final value = double.tryParse(text);
      return value != null && value >= 0;
    }

    final silverValid =
        isValid(last.silverOptimalController) &&
        isValid(last.silverWorstController);
    final goldValid =
        isValid(last.goldOptimalController) &&
        isValid(last.goldWorstController);

    final shouldEnable = silverValid || goldValid;

    if (_isAddQuarterButtonEnabled != shouldEnable) {
      setState(() {
        _isAddQuarterButtonEnabled = shouldEnable;
      });
    }
  }

  void _addListenersToLastQuarter() {
    if (predictionsData.isEmpty) return;
    final last = predictionsData.last;
    last.silverOptimalController.addListener(_validateLastQuarter);
    last.silverWorstController.addListener(_validateLastQuarter);
    last.goldOptimalController.addListener(_validateLastQuarter);
    last.goldWorstController.addListener(_validateLastQuarter);
  }

  void _removeListenersFromLastQuarter() {
    if (predictionsData.isEmpty) return;
    final last = predictionsData.last;
    last.silverOptimalController.removeListener(_validateLastQuarter);
    last.silverWorstController.removeListener(_validateLastQuarter);
    last.goldOptimalController.removeListener(_validateLastQuarter);
    last.goldWorstController.removeListener(_validateLastQuarter);
  }

  void _addQuarter() {
    _removeListenersFromLastQuarter();
    setState(() {
      final lastQuarterStr = predictionsData.last.quarter;
      final parts = lastQuarterStr.split(' ');
      final q = parts[0];
      final year = int.parse(parts[1]);
      final qNum = int.parse(q.substring(1));
      if (qNum == 4) {
        predictionsData.add(
          Prediction(quarter: "Q1 ${year + 1}", optimal: {}, worst: {}),
        );
      } else {
        predictionsData.add(
          Prediction(quarter: "Q${qNum + 1} $year", optimal: {}, worst: {}),
        );
      }
    });
    _addListenersToLastQuarter();
    _validateLastQuarter();
  }

  bool _isPredictionEmpty(Prediction pred) {
    bool emptyOrZero(String? s) {
      if (s == null || s.trim().isEmpty) return true;
      final v = double.tryParse(s.trim());
      return v == null || v == 0.0;
    }

    return emptyOrZero(pred.silverOptimalController.text) &&
        emptyOrZero(pred.silverWorstController.text) &&
        emptyOrZero(pred.goldOptimalController.text) &&
        emptyOrZero(pred.goldWorstController.text);
  }

  bool _isSilverFilled(Prediction pred) {
    final opt = pred.silverOptimalController.text.trim();
    final worst = pred.silverWorstController.text.trim();
    final optVal = double.tryParse(opt) ?? 0.0;
    final worstVal = double.tryParse(worst) ?? 0.0;
    return opt.isNotEmpty && worst.isNotEmpty && optVal > 0 && worstVal > 0;
  }

  bool _isGoldFilled(Prediction pred) {
    final opt = pred.goldOptimalController.text.trim();
    final worst = pred.goldWorstController.text.trim();
    final optVal = double.tryParse(opt) ?? 0.0;
    final worstVal = double.tryParse(worst) ?? 0.0;
    return opt.isNotEmpty && worst.isNotEmpty && optVal > 0 && worstVal > 0;
  }

  bool _hasEmptyEarlierRows() {
    for (int i = 0; i < predictionsData.length; i++) {
      if (_isPredictionEmpty(predictionsData[i])) {
        for (int j = i + 1; j < predictionsData.length; j++) {
          if (!_isPredictionEmpty(predictionsData[j])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _areQuartersSequential() {
    // You can implement more checks if needed
    return true;
  }

  Future<void> handleSave() async {
    final allEmpty = predictionsData.every((pred) => _isPredictionEmpty(pred));
    if (allEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter at least one complete set of predictions.",
      );
      return;
    }

    final filtered = predictionsData
        .where((pred) => !_isPredictionEmpty(pred))
        .toList();
    if (filtered.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter at least one complete set of predictions.",
      );
      return;
    }
    if (_hasEmptyEarlierRows()) {
      Fluttertoast.showToast(
        msg: "Ensure all previous quarters are filled before proceeding.",
      );
      return;
    }

    for (var pred in filtered) {
      final optSilverStr = pred.silverOptimalController.text.trim();
      final worstSilverStr = pred.silverWorstController.text.trim();
      final optGoldStr = pred.goldOptimalController.text.trim();
      final worstGoldStr = pred.goldWorstController.text.trim();

      final optSilver = double.tryParse(optSilverStr) ?? 0.0;
      final worstSilver = double.tryParse(worstSilverStr) ?? 0.0;
      final optGold = double.tryParse(optGoldStr) ?? 0.0;
      final worstGold = double.tryParse(worstGoldStr) ?? 0.0;

      if ((optSilverStr.isNotEmpty && optSilver == 0.0) ||
          (worstSilverStr.isNotEmpty && worstSilver == 0.0) ||
          (optGoldStr.isNotEmpty && optGold == 0.0) ||
          (worstGoldStr.isNotEmpty && worstGold == 0.0)) {
        Fluttertoast.showToast(
          msg: "Predictions cannot be 0. Please enter a value greater than 0.",
        );
        return;
      }

      final silverPartiallyFilled =
          (optSilver > 0 && worstSilver == 0) ||
          (optSilver == 0 && worstSilver > 0);
      final goldPartiallyFilled =
          (optGold > 0 && worstGold == 0) || (optGold == 0 && worstGold > 0);

      final silverFilled = _isSilverFilled(pred);
      final goldFilled = _isGoldFilled(pred);

      if ((silverPartiallyFilled && !goldFilled) ||
          (goldPartiallyFilled && !silverFilled) ||
          (silverPartiallyFilled && goldPartiallyFilled) ||
          (silverFilled && goldPartiallyFilled) ||
          (goldFilled && silverPartiallyFilled)) {
        Fluttertoast.showToast(
          msg:
              "Please complete both optimal and worst predictions for either silver, gold, or both.",
        );
        return;
      }

      final currentIndex = filtered.indexOf(pred);
      final later = filtered.sublist(currentIndex + 1);

      if (!silverFilled &&
          later.any(
            (p) =>
                (double.tryParse(p.silverOptimalController.text.trim()) ??
                        0.0) >
                    0 ||
                (double.tryParse(p.silverWorstController.text.trim()) ?? 0.0) >
                    0,
          )) {
        Fluttertoast.showToast(
          msg:
              "Please complete silver predictions in earlier quarters before filling later quarters.",
        );
        return;
      }

      if (!goldFilled &&
          later.any(
            (p) =>
                (double.tryParse(p.goldOptimalController.text.trim()) ?? 0.0) >
                    0 ||
                (double.tryParse(p.goldWorstController.text.trim()) ?? 0.0) > 0,
          )) {
        Fluttertoast.showToast(
          msg:
              "Please complete gold predictions in earlier quarters before filling later quarters.",
        );
        return;
      }
    }

    if (!_areQuartersSequential()) {
      Fluttertoast.showToast(
        msg: "Quarters must be added sequentially without gaps.",
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = AuthService();
      final fetchedUser = await authService.getUser();
      final userId = fetchedUser?.id;
      final token = fetchedUser?.token;
      final String baseUrl = dotenv.env['API_URL']!;

      for (var pred in filtered) {
        final optSilverStr = pred.silverOptimalController.text.trim();
        final worstSilverStr = pred.silverWorstController.text.trim();
        final optGoldStr = pred.goldOptimalController.text.trim();
        final worstGoldStr = pred.goldWorstController.text.trim();

        double? optSilver = optSilverStr.isEmpty
            ? null
            : double.tryParse(optSilverStr);
        double? worstSilver = worstSilverStr.isEmpty
            ? null
            : double.tryParse(worstSilverStr);
        double? optGold = optGoldStr.isEmpty
            ? null
            : double.tryParse(optGoldStr);
        double? worstGold = worstGoldStr.isEmpty
            ? null
            : double.tryParse(worstGoldStr);

        final silverFilled = _isSilverFilled(pred);
        final goldFilled = _isGoldFilled(pred);

        final finalOptSilver = (!silverFilled && goldFilled) ? null : optSilver;
        final finalWorstSilver = (!silverFilled && goldFilled)
            ? null
            : worstSilver;
        final finalOptGold = (!goldFilled && silverFilled) ? null : optGold;
        final finalWorstGold = (!goldFilled && silverFilled) ? null : worstGold;

        final body = jsonEncode({
          "customerId": int.parse(userId!),
          "dateNTime": _getQuarterStartDate(pred.quarter),
          "goldOptimalPrediction": finalOptGold ?? 0,
          "silverOptimalPrediction": finalOptSilver ?? 0,
          "goldWorstPrediction": finalWorstGold ?? 0,
          "silverWorstPrediction": finalWorstSilver ?? 0,
        });

        final resp = await http.post(
          Uri.parse(
            "$baseUrl/Portfolio/AddOrUpdateQuarterlyPredictedSpotPrices",
          ),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: body,
        );

        if (resp.statusCode != 200) {
          throw Exception("API error on save: ${resp.statusCode}");
        }
      }

      Fluttertoast.showToast(msg: "Predictions saved successfully!");
      Navigator.of(context).pop();
    } catch (e) {
      print("Error saving predictions: $e");
      Fluttertoast.showToast(msg: "Failed to save predictions.");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Helper: Get the first day of the quarter
  String _getQuarterStartDate(String quarter) {
    final parts = quarter.split(' ');
    final q = parts[0];
    final year = int.parse(parts[1]);
    switch (q) {
      case "Q1":
        return "${year}-01-01";
      case "Q2":
        return "${year}-04-01";
      case "Q3":
        return "${year}-07-01";
      case "Q4":
        return "${year}-10-01";
      default:
        return "${year}-01-01";
    }
  }

  // Helpers for market-data and quarter utilities

  List<String> _nextFourQuarters() {
    final now = DateTime.now();
    final List<String> quarters = [];
    int currentQuarter = ((now.month - 1) ~/ 3) + 1;
    int year = now.year;

    for (int i = 0; i < 4; i++) {
      quarters.add("Q$currentQuarter $year");
      currentQuarter++;
      if (currentQuarter > 4) {
        currentQuarter = 1;
        year++;
      }
    }
    return quarters;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildDisclaimer(),
                const SizedBox(height: 10),

                if (_isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 20),
                ] else ...[
                  ...predictionsData
                      .map((p) => _predictionQuarterCard(prediction: p))
                      .toList(),
                  const SizedBox(height: 16),
                  _buildAddQuarterButton(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Add Your Predictions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _primaryTextColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimal Prices - ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
            fontSize: 16,
          ),
        ),
        Text(
          'The potential highest that the metal price can reach in the respective Quarter.\n',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        SizedBox(height: 8),
        Text(
          'Worst Prices - ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        Text(
          'The potential lowest that the metal price can drop to in the respective Quarter.\n',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        SizedBox(height: 8),
        Text(
          'Disclaimer - ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        Text(
          'Analyst estimates are based on available data and market trends. They are not guarantees of future performance, and we are not liable for any decisions made based on this information.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  bool canAddPrediction() {
    if (predictionsData.isEmpty) return true;
    if (predictionsData.length >= 4 ||
        predictionsData.length >= marketData.length)
      return false;

    final lastPrediction = predictionsData.last;
    final nextQuarter = getNextQuarter(lastPrediction.quarter);

    return (isSilverFilled(lastPrediction) ||
            isGoldFilled(lastPrediction) ||
            isFullyFilled(lastPrediction)) &&
        marketData.any((data) => data['quarter'] == nextQuarter);
  }

  bool isSilverFilled(Prediction pred) {
    final optimalSilver = double.tryParse(pred.optimal['silver'] ?? '') ?? 0;
    final worstSilver = double.tryParse(pred.worst['silver'] ?? '') ?? 0;

    return optimalSilver > 0 && worstSilver > 0;
  }

  bool isGoldFilled(Prediction pred) {
    final optimalGold = double.tryParse(pred.optimal['gold'] ?? '') ?? 0;
    final worstGold = double.tryParse(pred.worst['gold'] ?? '') ?? 0;

    return optimalGold > 0 && worstGold > 0;
  }

  bool isFullyFilled(Prediction pred) {
    final optimalSilver = double.tryParse(pred.optimal['silver'] ?? '') ?? 0;
    final worstSilver = double.tryParse(pred.worst['silver'] ?? '') ?? 0;
    final optimalGold = double.tryParse(pred.optimal['gold'] ?? '') ?? 0;
    final worstGold = double.tryParse(pred.worst['gold'] ?? '') ?? 0;

    return optimalSilver > 0 &&
        worstSilver > 0 &&
        optimalGold > 0 &&
        worstGold > 0;
  }

  Widget _buildAddQuarterButton() {
    return OutlinedButton.icon(
      onPressed: (canAddPrediction() || _isAddQuarterButtonEnabled)
          ? _addQuarter
          : null,
      icon: const Icon(Icons.add),
      label: const Text("Add Quarter"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[800],
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        disabledForegroundColor: Colors.grey[400],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Save Predictions"),
          ),
        ),
      ],
    );
  }

  Widget _predictionQuarterCard({required Prediction prediction}) {
    // Optionally, find matching market average to display
    String marketSilver = '';
    String marketGold = '';

    var md = marketData.firstWhere(
      (e) => e['quarter'] == prediction.quarter,
      orElse: () => {},
    );
    if (md.isNotEmpty) {
      marketSilver = md['silver'] ?? '';
      marketGold = md['gold'] ?? '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prediction.quarter,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _quarterTitleColor,
            ),
          ),
          const SizedBox(height: 12),
          // Silver section
          Text(
            "Market Analyst Prediction (Silver)",
            style: TextStyle(color: _primaryTextColor, fontSize: 14),
          ),
          if (marketSilver.isNotEmpty)
            Text(
              "\$$marketSilver",
              style: TextStyle(
                color: _primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _predictionTextField(
                  label: "Optimal Case",
                  icon: Icons.check_circle,
                  color: _optimalColor,
                  controller: prediction.silverOptimalController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _predictionTextField(
                  label: "Worst Case",
                  icon: Icons.warning,
                  color: _worstColor,
                  controller: prediction.silverWorstController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gold section
          Text(
            "Market Analyst Prediction (Gold)",
            style: TextStyle(color: _primaryTextColor, fontSize: 14),
          ),
          if (marketGold.isNotEmpty)
            Text(
              "\$$marketGold",
              style: TextStyle(
                color: _primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _predictionTextField(
                  label: "Optimal Case",
                  icon: Icons.check_circle,
                  color: _optimalColor,
                  controller: prediction.goldOptimalController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _predictionTextField(
                  label: "Worst Case",
                  icon: Icons.warning,
                  color: _worstColor,
                  controller: prediction.goldWorstController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _predictionTextField({
    required String label,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color, width: 2.0),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
