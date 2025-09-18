import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // A list to hold the prediction data for each quarter
  final List<Prediction> predictions = [Prediction(quarter: "Q3 2025")];

  // State for enabling/disabling the "Add Quarter" button
  bool _isAddQuarterButtonEnabled = true;

  // Colors derived from the UI screenshot for accuracy
  final Color _optimalColor = const Color(0xFF28A745);
  final Color _worstColor = const Color(0xFFDC3545);
  final Color _quarterTitleColor = const Color(0xFF4C51BF);
  final Color _primaryTextColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    // Add listeners to the initial quarter's text fields to handle validation
    if (predictions.isNotEmpty) {
      _addListenersToLastQuarter();
    }
  }

  // It's important to dispose of controllers to free up resources
  @override
  void dispose() {
    // Remove listeners before disposing controllers
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

  /// Validates that all text fields in the last quarter contain valid numbers.
  void _validateLastQuarter() {
    if (predictions.isEmpty) return;
    final lastPrediction = predictions.last;

    bool isValid(TextEditingController controller) {
      final text = controller.text.trim();
      final value = double.tryParse(text);
      return value != null && value >= 0;
    }

    final silverValid =
        isValid(lastPrediction.silverOptimalController) &&
        isValid(lastPrediction.silverWorstController);

    final goldValid =
        isValid(lastPrediction.goldOptimalController) &&
        isValid(lastPrediction.goldWorstController);

    final shouldEnable = silverValid || goldValid;

    if (_isAddQuarterButtonEnabled != shouldEnable) {
      setState(() {
        _isAddQuarterButtonEnabled = shouldEnable;
      });
    }
  }

  /// Adds validation listeners to the controllers of the last prediction in the list.
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

  /// Logic to add the next quarter dynamically
  void _addQuarter() {
    // Remove listeners from the current last quarter before adding a new one
    _removeListenersFromLastQuarter();

    setState(() {
      final lastQuarterStr = predictions.last.quarter;
      final year = int.parse(lastQuarterStr.substring(3));
      int quarterNum = int.parse(lastQuarterStr.substring(1, 2));

      if (quarterNum == 4) {
        predictions.add(Prediction(quarter: "Q1 ${year + 1}"));
      } else {
        predictions.add(Prediction(quarter: "Q${quarterNum + 1} $year"));
      }
    });

    // Add listeners to the new last quarter and validate its initial state
    _addListenersToLastQuarter();
    _validateLastQuarter();
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
            // 👈 Wrap everything in a SingleChildScrollView
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
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Add your save logic here
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Save Predictions"),
          ),
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
