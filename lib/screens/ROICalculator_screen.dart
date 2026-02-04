import 'package:bold_portfolio/models/spot_price_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ROICalculator extends StatefulWidget {
  final SpotData spotPrice;

  const ROICalculator({super.key, required this.spotPrice});

  @override
  State<ROICalculator> createState() => _ROICalculatorState();
}

class _ROICalculatorState extends State<ROICalculator> {
  // State variables
  String? selectedMetal;
  final TextEditingController _ounceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  double currentSelectedSpot = 0.0; // Dynamic spot price based on selection

  String resultText = "";
  String profitPercentage = "";
  bool resultVisible = false;
  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    // Listeners to handle button disabled state
    _ounceController.addListener(_validateInputs);
    _priceController.addListener(_validateInputs);
  }

  void _updateSpotPrice(String? metal) {
    setState(() {
      selectedMetal = metal;
      if (metal == "Gold") {
        currentSelectedSpot = widget.spotPrice.goldAsk;
      } else if (metal == "Silver") {
        currentSelectedSpot = widget.spotPrice.silverAsk;
      } else if (metal == "Platinum") {
        currentSelectedSpot = widget.spotPrice.platinumAsk;
      } else if (metal == "Palladium") {
        currentSelectedSpot = widget.spotPrice.palladiumAsk;
      } else {
        currentSelectedSpot = 0.0;
      }
      _bullionSpotController.text = currentSelectedSpot.toStringAsFixed(2);
      _validateInputs();
    });
  }

  void _validateInputs() {
    setState(() {
      isButtonDisabled =
          _ounceController.text.isEmpty ||
          (double.tryParse(_priceController.text) ?? 0) <= 0 ||
          selectedMetal == null;
    });
  }

  void _calculateROI() {
    double ounces = double.tryParse(_ounceController.text) ?? 0;
    double buyPrice = double.tryParse(_priceController.text) ?? 0;

    if (ounces > 0 && buyPrice > 0) {
      double totalReturn = ounces * (currentSelectedSpot - buyPrice);
      double percent = (100 * (currentSelectedSpot - buyPrice)) / buyPrice;

      setState(() {
        resultVisible = true;
        resultText = NumberFormat.currency(symbol: "\$").format(totalReturn);
        String type = totalReturn >= 0 ? "Profit" : "Loss";
        profitPercentage = ", $type: ${percent.toStringAsFixed(2)}%";
      });
    }
  }

  String toCurrency(double value) =>
      NumberFormat.currency(symbol: "\$").format(value);

  // final TextEditingController _ounceController = TextEditingController();
  // final TextEditingController _roiPriceController = TextEditingController();
  String roiResult = "";
  bool roiVisible = false;

  // --- Bullion Value Calculator State (Your New Code) ---
  final TextEditingController _bullionWeightController =
      TextEditingController();
  final TextEditingController _bullionSpotController = TextEditingController();
  double weightUnit = 1.0; // Default: Troy Ounces
  double selPurity = 0.0;
  String totalBullionPrice = "";

  // Example Purity Data
  final List<Map<String, dynamic>> purities = [
    {"name": "Select Purity", "value": 0.0},
    {"name": ".9999", "value": 0.9999},
    {"name": ".999", "value": 0.999},
    {"name": ".9584 (Britannia)", "value": 0.9584},
    {"name": ".925 (Sterling)", "value": 0.925},
    {"name": ".900", "value": 0.9},
    {"name": ".400", "value": 0.4},
  ];

  void _calculateBullionWorth() {
    double weight = double.tryParse(_bullionWeightController.text) ?? 0.0;
    double spotAsk = double.tryParse(_bullionSpotController.text) ?? 0.0;

    // worth = weight * spotPrice * unitFactor * purity
    double worth = weight * spotAsk * weightUnit * selPurity;

    setState(() {
      totalBullionPrice = toCurrency(worth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Calculator"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // Ensure back arrow is visible
      ),
      body: SafeArea(
        // 2. Use SingleChildScrollView so the user can scroll through both calculators
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ROI Calculator",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 2) Spot Price display that updates based on selection
              Row(
                children: [
                  const Text(
                    "Current spot price/oz: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: "\$",
                    ).format(currentSelectedSpot),
                    style: TextStyle(
                      color: currentSelectedSpot >= 0
                          ? const Color(0xFF179900)
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabel("Metal"),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("--Select--"),
                value: selectedMetal,
                items: ["Silver", "Gold", "Platinum", "Palladium"]
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: _updateSpotPrice,
              ),

              const SizedBox(height: 16),
              _buildLabel("Ounce Purchased"),
              TextField(
                controller: _ounceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter Ounce"),
              ),

              const SizedBox(height: 16),
              _buildLabel("Spot Buy Price/oz"),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("\$0.00"),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isButtonDisabled ? null : _calculateROI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonDisabled
                        ? const Color(0xFF676F77)
                        : Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Calculate"),
                ),
              ),

              if (resultVisible) ...[
                const SizedBox(height: 20),
                _buildResultDisplay(),
              ],
              const SizedBox(height: 10),

              const Row(
                children: [
                  Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 10),

              // --- SECTION 2: BULLION VALUE (Know Your Metals Value) ---
              const Text(
                "Know Your Metals Value",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Weight & Unit Row
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      "Weight",
                      _bullionWeightController,
                      "Enter Weight",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      "Unit",
                      ["Troy Ounces", "Grams", "KiloGrams"],
                      (val) {
                        setState(() {
                          if (val == "Troy Ounces")
                            weightUnit = 1.0;
                          else if (val == "Grams")
                            weightUnit = 0.0311035;
                          else if (val == "KiloGrams")
                            weightUnit = 31.1035;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              _buildLabel("Purity"),

              DropdownButtonFormField<double?>(
                value: selPurity,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: purities.map((p) {
                  return DropdownMenuItem<double?>(
                    value: p['value'],
                    child: Text(p['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selPurity = val!);
                },
              ),

              const SizedBox(height: 20),
              const Text(
                "I would like to know how much my bullion is worth with a spot price of:",
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _bullionSpotController,
                      decoration: const InputDecoration(
                        hintText: "Spot Price",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "USD",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _calculateBullionWorth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    "Calculate Value",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- THE ADDED RESULT PART ---
              if (totalBullionPrice.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF064E3B), width: 10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF179900),
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "Your 99.99% ${selectedMetal ?? 'Metal'} bullion worth    ",
                        ),
                        TextSpan(
                          text: "$totalBullionPrice USD",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              if (totalBullionPrice.isNotEmpty) const SizedBox(height: 20),

              // --- THE DISCLAIMER PART ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 20,
                ),
                color: const Color(0xFFF3F3F3), // bg-[#f3f3f3]
                child: const Text(
                  "Disclaimer: Foreign exchange rates and spot prices are delayed. "
                  "The results are for indicative purposes only which may not match our offered pricing",
                  style: TextStyle(
                    color: Color(0xFF404040),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Builders ---
  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DropdownButtonFormField<String>(
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          left: BorderSide(color: Color(0xFF064E3B), width: 8),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Text(
        "Result: $resultText$profitPercentage",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: !resultText.contains('-')
              ? const Color(0xFF179900)
              : Colors.red,
        ),
      ),
    );
  }

  // Helper to create the red asterisk labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  // Common Input Styling
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}
