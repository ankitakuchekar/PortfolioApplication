import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/screens/HoldingScreen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:bold_portfolio/widgets/InvestmentFeature.dart';
import 'package:bold_portfolio/widgets/add_holding_form.dart';
import 'package:bold_portfolio/widgets/common_app_bar.dart';
import 'package:bold_portfolio/widgets/common_drawer.dart';
import 'package:bold_portfolio/widgets/portfolioValuation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BullionDashboard extends StatefulWidget {
  const BullionDashboard({super.key});
  @override
  State<BullionDashboard> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<BullionDashboard> {
  String? token;
  String? userId;
  bool showReturns = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(
        context,
        listen: false,
      ).loadPortfolioData();
    });
  }

  Future<void> _loadToken() async {
    final authService = AuthService();
    final fetchedToken = await authService.getToken();
    setState(() {
      token = fetchedToken;
    });
  }

  Future<void> _loadUserId() async {
    final authService = AuthService();
    final fetchedUser = await authService.getUser();
    setState(() {
      userId = fetchedUser?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Bullion Portfolio'),
      drawer: const CommonDrawer(),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          if (portfolioProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (portfolioProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    portfolioProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => portfolioProvider.loadPortfolioData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final portfolioData = portfolioProvider.portfolioData;
          final customerData = (portfolioData?.data.isNotEmpty ?? false)
              ? portfolioData!.data[0]
              : CustomerData.empty();

          if (customerData.productHoldings.isEmpty ||
              portfolioData == null ||
              portfolioData.data.isEmpty) {
            return _buildEmptyPortfolioView();
          }

          final holdingData = customerData.productHoldings;
          final silverHoldings = holdingData
              .where((h) => h.metal == "Silver")
              .toList();
          final goldHoldings = holdingData
              .where((h) => h.metal == "Gold")
              .toList();
          final investment = portfolioData.data[0].investment;

          final double totalCurrentValue =
              investment.totalGoldCurrent + investment.totalSilverCurrent;
          final double totalAcquisitionCost =
              investment.totalGoldInvested + investment.totalSilverInvested;

          final double difference = totalCurrentValue - totalAcquisitionCost;
          final double totalProfitDifference = (difference < 0)
              ? -difference
              : difference;
          final double percentDifference = totalAcquisitionCost > 0
              ? (totalProfitDifference / totalAcquisitionCost) * 100
              : 0;

          final double dayProfitLoss =
              investment.dayGold + investment.daySilver;
          final double percentDayProfitLossPage =
              investment.dayChangePercentage;
          final double percentDayProfitLoss =
              totalAcquisitionCost > 0 && !percentDayProfitLossPage.isNaN
              ? percentDayProfitLossPage.abs()
              : 0;

          final double daySilverPercent =
              investment.totalSilverInvested > 0 && !percentDayProfitLoss.isNaN
              ? percentDayProfitLoss.abs()
              : 0;

          final double dayGoldPercent =
              investment.totalGoldInvested > 0 && !percentDayProfitLoss.isNaN
              ? percentDayProfitLoss.abs()
              : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentValueCard(
                  totalCurrentValue,
                  difference,
                  percentDifference,
                  dayProfitLoss,
                  percentDayProfitLoss,
                  totalAcquisitionCost,
                ),

                // Toggle button (Returns / Current‑Invested)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showReturns = !showReturns;
                      });
                    },
                    child: Text(
                      showReturns ? "Current‑(Invested)" : "Returns (%)",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Silver Holding
                if (silverHoldings.isNotEmpty)
                  _buildHoldingRow(
                    metal: "Silver",
                    quantity:
                        "${investment.totalSilverOunces.toStringAsFixed(2)} ounces",
                    currentValue:
                        "\$${investment.totalSilverCurrent.toStringAsFixed(2) ?? 0}",
                    purchaseValue:
                        "\$${investment.totalSilverInvested.toStringAsFixed(2)}",
                    positive:
                        (investment.totalSilverCurrent -
                            investment.totalSilverInvested) >=
                        0,
                    showReturns: showReturns,
                    profit:
                        investment.totalSilverCurrent -
                        investment.totalSilverInvested,
                    profitPct: investment.totalSilverInvested > 0
                        ? ((investment.totalSilverCurrent -
                                      investment.totalSilverInvested) /
                                  investment.totalSilverInvested) *
                              100
                        : 0,
                    holdingData: silverHoldings,
                    isProfit:
                        (investment.totalSilverCurrent -
                            investment.totalSilverInvestment) >
                        0,
                    dayProfit: investment.daySilver,
                    dayPercentProfit: daySilverPercent,
                  ),
                const Divider(height: 24),

                // Gold Holding
                if (goldHoldings.isNotEmpty)
                  _buildHoldingRow(
                    metal: "Gold",
                    quantity:
                        "${investment.totalGoldOunces.toStringAsFixed(2)} ounces",
                    currentValue:
                        "\$${investment.totalGoldCurrent.toStringAsFixed(2)}",
                    purchaseValue:
                        "\$${investment.totalGoldInvested.toStringAsFixed(2)}",
                    positive:
                        (investment.totalGoldCurrent -
                            investment.totalGoldInvested) >=
                        0,
                    showReturns: showReturns,
                    profit:
                        investment.totalGoldCurrent -
                        investment.totalGoldInvested,
                    profitPct: investment.totalGoldInvested > 0
                        ? ((investment.totalGoldCurrent -
                                      investment.totalGoldInvested) /
                                  investment.totalGoldInvested) *
                              100
                        : 0,
                    holdingData: goldHoldings,
                    isProfit:
                        (investment.totalGoldCurrent -
                            investment.totalGoldInvested) >
                        0,
                    dayProfit: investment.dayGold,
                    dayPercentProfit: dayGoldPercent,
                  ),
                const Divider(height: 24),

                _buildComingSoonRow("Platinum"),
                const Divider(height: 24),
                _buildComingSoonRow("Palladium"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPortfolioView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://res.cloudinary.com/bold-pm/image/upload/Graphics/Bullion-invesment-Portfolio.webp',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Why is it Important to Build\nand Track Your Bullion Investment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          InvestmentFeature(
            icon: Icons.link,
            text: "Keeps all your gold and silver investments in one place.",
          ),
          InvestmentFeature(
            icon: Icons.show_chart,
            text:
                "Helps assess the current value of your holdings compared to purchase prices.",
          ),
          InvestmentFeature(
            icon: Icons.bar_chart,
            text:
                "Offers insights into the growth of your investments over time.",
          ),
          InvestmentFeature(
            icon: Icons.settings,
            text:
                "Centralizes all data, making it easily accessible anytime and anywhere.",
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.amber[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddHoldingForm(
                    onClose: () => Navigator.of(context).pop(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Add New Holdings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentValueCard(
    double totalCurrentValue,
    double difference,
    double percentDifference,
    double dayProfitLoss,
    double percentDayProfitLoss,
    double totalAcquisitionCost,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Current Value",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            AnimatedCounter(
              value: totalCurrentValue,
              prefix: '\$',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total P/L", style: TextStyle(fontSize: 16)),
                AnimatedCounter(
                  value: difference,
                  prefix: '+\$',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: difference > 0 ? Colors.green : Colors.red,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Day P/L", style: TextStyle(fontSize: 16)),
                AnimatedCounter(
                  value: dayProfitLoss,
                  prefix: dayProfitLoss >= 0 ? '+\$' : '-\$',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: dayProfitLoss >= 0 ? Colors.green : Colors.red,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Purchase Cost", style: TextStyle(fontSize: 16)),
                AnimatedCounter(
                  value: totalAcquisitionCost,
                  prefix: '\$',
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w200,
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingRow({
    required String metal,
    required String quantity,
    required String currentValue,
    required String purchaseValue,
    required bool positive,
    required bool showReturns,
    required double profit,
    required double profitPct,
    required List<ProductHolding> holdingData,
    required bool isProfit,
    required double dayProfit,
    required double dayPercentProfit,
  }) {
    double parseCurrency(String value) {
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    final double currentValueDouble = parseCurrency(currentValue);
    final double purchaseValueDouble = parseCurrency(purchaseValue);

    return InkWell(
      onTap: () {
        // Navigate to detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HoldingDetailScreen(
              metal: metal,
              currentValue: currentValueDouble,
              totalPL: profit,
              percentPL: profitPct,
              dayPL: dayProfit, // Replace with actual value if available
              percentDayPL:
                  dayPercentProfit, // Replace with actual value if available
              purchaseCost: purchaseValueDouble,
              holdings: holdingData
                  .map(
                    (holding) => PortfolioItem(
                      name: holding.name,
                      imageUrl: holding.productImage,
                      quantity: holding.totalQtyOrdered,
                      purchasePrice: holding.avgPrice,
                      currentPrice: holding.currentMetalValue,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Metal + Quantity
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantity,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),

            // Right side: Returns or Current + Purchase
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: showReturns
                  ? [
                      AnimatedCounter(
                        value: profit,
                        prefix: '\$',
                        style: TextStyle(
                          fontSize: 18,
                          color: positive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${profit >= 0 ? '+' : '-'}${profitPct.toStringAsFixed(2)}%",
                        style: TextStyle(
                          fontSize: 16,
                          color: positive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ]
                  : [
                      AnimatedCounter(
                        value: currentValueDouble,
                        prefix: '\$',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: isProfit
                              ? AppColors.profitGreen
                              : AppColors.lossRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedCounter(
                        value: purchaseValueDouble,
                        prefix: '\$',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonRow(String metal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metal,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Text(
            "Coming Soon",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(seconds: 2),
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      builder: (context, val, child) {
        final formatted = NumberFormat("#,##0.00").format(val);
        return Text(
          "$prefix$formatted$suffix",
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}
