import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActualPriceBanner extends StatefulWidget {
  final int customerId;
  final PortfolioSettings settings;
  final String token;
  final Future<void> Function() fetchChartData;

  const ActualPriceBanner({
    super.key,
    required this.customerId,
    required this.settings,
    required this.token,
    required this.fetchChartData,
  });

  @override
  State<ActualPriceBanner> createState() => _ActualPriceBannerState();
}

class _ActualPriceBannerState extends State<ActualPriceBanner> {
  late bool isActualPrice;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isActualPrice = widget.settings.showActualPrice;
  }

  Future<void> handleToggle(bool value) async {
    setState(() => isLoading = true);

    bool result = await updatePortfolioSettings(
      customerId: widget.customerId,
      settings: widget.settings,
      showActualPrice: value,
      token: widget.token,
    );

    if (result) {
      setState(() => isActualPrice = value);
      await widget.fetchChartData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update settings')),
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildTooltipSection(String label, String message, bool active) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(8),
      textStyle: const TextStyle(color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.teal : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.info_outline,
            size: 14,
            color: active ? Colors.teal : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE5534D), Color(0xFF2CC399)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Do you want to ${isActualPrice ? "Exclude" : "Include"} Premium Price?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildTooltipSection(
                            "Exclude Premium",
                            "Only metal price is considered.\nExample: \$30 × 1 × 1 = \$30",
                            !isActualPrice,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Switch(
                          value: isActualPrice,
                          onChanged: handleToggle,
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.grey,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: buildTooltipSection(
                            "Include Premium",
                            "Metal + premium considered.\nExample: (\$32 + \$5) × 1 × 1 = \$37",
                            isActualPrice,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
