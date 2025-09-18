import 'dart:convert';

import 'package:bold_portfolio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// Data class to hold controllers for each prediction quarter
class Prediction {
  String quarter;
  final TextEditingController silverOptimalController = TextEditingController();
  final TextEditingController silverWorstController = TextEditingController();
  final TextEditingController goldOptimalController = TextEditingController();
  final TextEditingController goldWorstController = TextEditingController();

  Prediction({required this.quarter});
}

class PredictionPopup extends StatefulWidget {
  const PredictionPopup({super.key});

  @override
  _PredictionPopupState createState() => _PredictionPopupState();
}

class _PredictionPopupState extends State<PredictionPopup> {
  final List<Prediction> predictions = [Prediction(quarter: "Q3 2025")];
  bool _isAddQuarterButtonEnabled = true;

  // New loading state
  bool _isSaving = false;

  // Colors etc.
  final Color _optimalColor = const Color(0xFF28A745);
  final Color _worstColor = const Color(0xFFDC3545);
  final Color _quarterTitleColor = const Color(0xFF4C51BF);
  final Color _primaryTextColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    if (predictions.isNotEmpty) {
      _addListenersToLastQuarter();
    }
  }

  @override
  void dispose() {
    if (predictions.isNotEmpty) {
      _removeListenersFromLastQuarter();
    }
    for (var p in predictions) {
      p.silverOptimalController.dispose();
      p.silverWorstController.dispose();
      p.goldOptimalController.dispose();
      p.goldWorstController.dispose();
    }
    super.dispose();
  }

  void _validateLastQuarter() {
    if (predictions.isEmpty) return;
    final last = predictions.last;

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
    final last = predictions.last;
    last.silverOptimalController.addListener(_validateLastQuarter);
    last.silverWorstController.addListener(_validateLastQuarter);
    last.goldOptimalController.addListener(_validateLastQuarter);
    last.goldWorstController.addListener(_validateLastQuarter);
  }

  void _removeListenersFromLastQuarter() {
    final last = predictions.last;
    last.silverOptimalController.removeListener(_validateLastQuarter);
    last.silverWorstController.removeListener(_validateLastQuarter);
    last.goldOptimalController.removeListener(_validateLastQuarter);
    last.goldWorstController.removeListener(_validateLastQuarter);
  }

  void _addQuarter() {
    _removeListenersFromLastQuarter();
    setState(() {
      final lastQuarterStr = predictions.last.quarter; // e.g. "Q3 2025"
      final parts = lastQuarterStr.split(' ');
      final q = parts[0]; // e.g "Q3"
      final year = int.parse(parts[1]);
      final qNum = int.parse(q.substring(1));
      if (qNum == 4) {
        predictions.add(Prediction(quarter: "Q1 ${year + 1}"));
      } else {
        predictions.add(Prediction(quarter: "Q${qNum + 1} $year"));
      }
    });
    _addListenersToLastQuarter();
    _validateLastQuarter();
  }

  // Utility methods similar to your JS code

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

  bool _isFullyFilled(Prediction pred) {
    return _isSilverFilled(pred) && _isGoldFilled(pred);
  }

  bool _hasEmptyEarlierRows() {
    // If any earlier prediction is empty while a later one is filled
    for (int i = 0; i < predictions.length; i++) {
      final p = predictions[i];
      if (_isPredictionEmpty(p)) {
        // see if any later predictions are non-empty
        for (int j = i + 1; j < predictions.length; j++) {
          if (!_isPredictionEmpty(predictions[j])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _areQuartersSequential() {
    // Assuming you want no gaps, i.e. Q1 2025 then Q2 2025, etc.
    // Here we check based on the list you built; if you only add sequentially it's OK.
    // Could add more checks if quarters might be missing.
    // For simplicity assume it's sequential since you control AddQuarter.
    return true;
  }

  // The save logic

  Future<void> handleSave() async {
    // First validation: all empty
    final allEmpty = predictions.every((pred) => _isPredictionEmpty(pred));
    if (allEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter at least one complete set of predictions.",
      );
      return;
    }

    final filtered = predictions
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

    // Loop through filtered for detailed validations
    for (var pred in filtered) {
      final optSilverStr = pred.silverOptimalController.text.trim();
      final worstSilverStr = pred.silverWorstController.text.trim();
      final optGoldStr = pred.goldOptimalController.text.trim();
      final worstGoldStr = pred.goldWorstController.text.trim();

      final optSilver = double.tryParse(optSilverStr) ?? 0.0;
      final worstSilver = double.tryParse(worstSilverStr) ?? 0.0;
      final optGold = double.tryParse(optGoldStr) ?? 0.0;
      final worstGold = double.tryParse(worstGoldStr) ?? 0.0;

      // Check for non-zero when something is entered
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

      // Ensure earlier quarters have silver/gold before later ones
      final currentIndex = filtered.indexOf(pred);
      final later = filtered.sublist(currentIndex + 1);

      if (!silverFilled &&
          later.any(
            (p) =>
                double.tryParse(p.silverOptimalController.text.trim()) !=
                        null &&
                    (double.tryParse(p.silverOptimalController.text.trim())! >
                        0) ||
                double.tryParse(p.silverWorstController.text.trim()) != null &&
                    (double.tryParse(p.silverWorstController.text.trim())! > 0),
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
                double.tryParse(p.goldOptimalController.text.trim()) != null &&
                    (double.tryParse(p.goldOptimalController.text.trim())! >
                        0) ||
                double.tryParse(p.goldWorstController.text.trim()) != null &&
                    (double.tryParse(p.goldWorstController.text.trim())! > 0),
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

    // All validations passed — proceed to save
    setState(() {
      _isSaving = true;
    });

    try {
      final authService = AuthService();
      final fetchedUser = await authService.getUser();
      // Replace these with your actual values
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

        // Following logic: if gold is filled but silver not, set silver optimal and worst to null etc.
        final finalOptSilver = (!silverFilled && goldFilled) ? null : optSilver;
        final finalWorstSilver = (!silverFilled && goldFilled)
            ? null
            : worstSilver;
        final finalOptGold = (!goldFilled && silverFilled) ? null : optGold;
        final finalWorstGold = (!goldFilled && silverFilled) ? null : worstGold;

        // Construct request payload
        final body = jsonEncode({
          "customerId": int.parse(userId ?? '0'),
          "dateNTime": _getQuarterStartDate(
            pred.quarter,
          ), // implement this helper
          "goldOptimalPrediction": finalOptGold ?? 0,
          "silverOptimalPrediction": finalOptSilver ?? 0,
          "goldWorstPrediction": finalWorstGold ?? 0,
          "silverWorstPrediction": finalWorstSilver ?? 0,
        });

        final response = await http.post(
          Uri.parse(
            "$baseUrl/Portfolio/AddOrUpdateQuarterlyPredictedSpotPrices",
          ),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: body,
        );

        if (response.statusCode != 200) {
          // optionally log or inspect response.body
          throw Exception("API error: ${response.statusCode}");
        }
      }

      Fluttertoast.showToast(msg: "Predictions saved successfully!");
      // optionally refresh data, close popup etc.
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to save predictions.");
      print("Error saving predictions: $e");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _getQuarterStartDate(String quarter) {
    // Based on your JS helper getQuarterStartDate
    // Implement mapping: e.g. "Q1 2025" -> "2025-01-01", etc.
    final parts = quarter.split(' ');
    final q = parts[0]; // Q1, Q2...
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
                ...predictions
                    .map((p) => _PredictionQuarterCard(prediction: p))
                    .toList(),
                const SizedBox(height: 16),
                _buildAddQuarterButton(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header with a title and a close button
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

  /// 3) BUILDS THE DISCLAIMER SECTION WITH UPDATED STYLING
  Widget _buildDisclaimer() {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Optimal Prices - ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green,
              fontSize: 16,
            ),
          ),
          const TextSpan(
            text:
                'The potential highest that the metal price can reach in the respective Quarter.\n\n',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          TextSpan(
            text: 'Worst Prices - ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const TextSpan(
            text:
                'The potential lowest that the metal price can drop to in the respective Quarter.\n\n',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          TextSpan(
            text: 'Disclaimer - ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const TextSpan(
            text:
                'Analyst estimates are based on available data and market trends. They are not guarantees of future performance, and we are not liable for any decisions made based on this information.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// 2) BUILDS THE "ADD QUARTER" BUTTON WITH ENABLE/DISABLE LOGIC
  Widget _buildAddQuarterButton() {
    return OutlinedButton.icon(
      // Disable the button by setting onPressed to null if state is false
      onPressed: _isAddQuarterButtonEnabled ? _addQuarter : null,
      icon: const Icon(Icons.add),
      label: const Text("Add Quarter"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[800],
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // Change color when disabled to provide visual feedback
        disabledForegroundColor: Colors.grey[400],
      ),
    );
  }

  /// Builds the bottom action buttons ("Cancel" and "Save Predictions")
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
        ElevatedButton(
          onPressed: _isSaving
              ? null // Disable the button while saving
              : handleSave,
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
      ],
    );
  }

  /// A reusable widget for displaying the prediction card for a single quarter
  Widget _PredictionQuarterCard({required Prediction prediction}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Light background for the card
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
          // Silver Predictions
          Text(
            "Market Analyst Prediction (Silver)",
            style: TextStyle(color: _primaryTextColor, fontSize: 14),
          ),
          Text(
            "\$35.82",
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
                child: _PredictionTextField(
                  label: "Optimal Case",
                  icon: Icons.check_circle,
                  color: _optimalColor,
                  controller: prediction.silverOptimalController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PredictionTextField(
                  label: "Worst Case",
                  icon: Icons.warning,
                  color: _worstColor,
                  controller: prediction.silverWorstController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gold Predictions
          Text(
            "Market Analyst Prediction (Gold)",
            style: TextStyle(color: _primaryTextColor, fontSize: 14),
          ),
          Text(
            "\$3163.93",
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
                child: _PredictionTextField(
                  label: "Optimal Case",
                  icon: Icons.check_circle,
                  color: _optimalColor,
                  controller: prediction.goldOptimalController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PredictionTextField(
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

  /// A reusable widget for the custom-styled text fields
  Widget _PredictionTextField({
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
              hintText: '0.00', // 👈 This is the placeholder
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
