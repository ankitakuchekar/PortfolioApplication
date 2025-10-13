import 'dart:convert';
import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/providers/portfolio_provider.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:bold_portfolio/widgets/LineChartWidget.dart';
import 'package:bold_portfolio/widgets/PLCLineWidget.dart';
import 'package:bold_portfolio/widgets/common_app_bar.dart';
import 'package:bold_portfolio/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProductLife {
  final List<MetalInOunces> metalInOunces;
  final List<dynamic> productsForPortfolio;
  final List<dynamic> investment;
  final List<dynamic> transactions;

  ProductLife({
    required this.metalInOunces,
    required this.productsForPortfolio,
    required this.investment,
    required this.transactions,
  });

  factory ProductLife.fromJson(Map<String, dynamic> json) {
    return ProductLife(
      metalInOunces:
          (json['metalInounces'] as List?)
              ?.map((e) => MetalInOunces.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      productsForPortfolio: json['productsForPortfolio'] != null
          ? List<dynamic>.from(json['productsForPortfolio'])
          : [],
      investment: json['investment'] != null
          ? List<dynamic>.from(json['investment'])
          : [],
      transactions: json['transactions'] != null
          ? List<dynamic>.from(json['transactions'])
          : [],
    );
  }
}

class ProductLifecycleScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final int productId;
  final String frequency;
  final String metal;

  const ProductLifecycleScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.productId,
    this.frequency = '1D',
    required this.metal,
  });

  @override
  State<ProductLifecycleScreen> createState() => _ProductLifecycleScreenState();
}

class _ProductLifecycleScreenState extends State<ProductLifecycleScreen> {
  ProductLife? _productLife;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      final data = await _fetchProductDetails('3M');
      setState(() {
        _productLife = data;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<ProductLife> _fetchProductDetails(frequency) async {
    final authService = AuthService();
    final fetchedUserId = await authService.getUser();
    final token = await authService.getToken();
    final String baseUrl = dotenv.env['API_URL'] ?? '';

    try {
      final url = Uri.parse(
        '$baseUrl/Portfolio/GetProductWiseCustomerTransactions',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customerId': int.parse(fetchedUserId?.id ?? '0'),
          'frequency': frequency,
          'productId': widget.productId,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic rawResponse = jsonDecode(response.body);
        if (rawResponse['success'] == true &&
            rawResponse['data'] != null &&
            rawResponse['data'] is Map<String, dynamic>) {
          final dataMap = rawResponse['data'] as Map<String, dynamic>;
          return ProductLife.fromJson(dataMap);
        } else {
          throw Exception('No data found in response');
        }
      } else {
        throw Exception(
          'Failed to load product data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  String _selectedRange = '3M';
  final List<String> _timerOptions = [
    '1D',
    '1W',
    '1M',
    '3M',
    '6M',
    '1Y',
    '2Y',
    '5Y',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Holdings'),
      drawer: const CommonDrawer(),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (_productLife == null) {
            return const Center(
              child: Text(
                'No holdings data available.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final metalInOuncesData = _productLife?.metalInOunces ?? [];
          final currentInvestment =
              (_productLife?.investment.isNotEmpty ?? false)
              ? _productLife!.investment[0] as Map<String, dynamic>
              : {};

          final double currentValue =
              (currentInvestment['totalSilverCurrent'] ?? 0).toDouble();
          final double totalInvested =
              (currentInvestment['totalSilverInvested'] ?? 0).toDouble();
          final double difference = currentValue - totalInvested;
          final bool isProfit = difference >= 0;

          final String profitLossPercentStr = totalInvested > 0
              ? '${((difference.abs() / totalInvested) * 100).toStringAsFixed(2)}%'
              : '0.00%';
          final Color profitColor = isProfit ? Colors.green : Colors.red;
          final selectedImage =
              "https://res.cloudinary.com/bold-pm/image/upload/q_auto:good/Graphics/no_img_preview_product.png";

          final transactionProducts =
              (_productLife?.transactions ?? []) as List<dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Product Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.imageUrl,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.network(
                                    selectedImage,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.subtitle,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),

                          _buildValueRow(
                            "Current Value",
                            "\$${currentValue.toStringAsFixed(2)}",
                          ),
                          _buildValueRow(
                            "Cost Basis",
                            "\$${totalInvested.toStringAsFixed(2)}",
                          ),
                          _buildValueRow(
                            "Profit/Loss",
                            "${isProfit ? '+' : '-'}\$${difference.abs().toStringAsFixed(2)} ($profitLossPercentStr)",
                            color: profitColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row with Selected Range Chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Silver Performance Chart",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B), // Dark text
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _selectedRange,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Time Filter Buttons (2-row layout)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: _timerOptions.map((option) {
                              final isSelected = _selectedRange == option;
                              return GestureDetector(
                                onTap: () async {
                                  if (_selectedRange == option) return;

                                  setState(() {
                                    _selectedRange = option;
                                    // _isLoading = true;
                                    _error = null;
                                  });

                                  try {
                                    final fetchedData =
                                        await _fetchProductDetails(option);
                                    setState(() {
                                      _productLife = fetchedData;
                                      _isLoading = false;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _error = e.toString();
                                      _isLoading = false;
                                    });
                                  }
                                },
                                child: Container(
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          100) /
                                      4, // 4 per row
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Chart
                          SizedBox(
                            height: 450,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              child: MetalHoldingsLineChartForPLC(
                                key: ValueKey(_selectedRange), // force rebuild
                                metalInOuncesData: metalInOuncesData,
                                isGoldView: widget.metal == 'Gold',
                                metal: widget.metal,
                                selectedRange: _selectedRange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Transaction History Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: Colors.white,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Transaction History",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Purchase and Sell/Exit history",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        transactionProducts.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "No transaction history available",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Table(
                                    defaultColumnWidth:
                                        const IntrinsicColumnWidth(),
                                    border: TableBorder.symmetric(
                                      inside: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    children: [
                                      const TableRow(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                        ),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              "Date",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "Transaction\nType",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "Transaction\nQty",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "Available\nQty",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "Unit\nPrice",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ...transactionProducts.map((tx) {
                                        final transactionType =
                                            tx['transactionType'] ?? '';
                                        final isPurchase =
                                            transactionType == 'PURCHASED';
                                        final color = isPurchase
                                            ? Colors.blue
                                            : Colors.green;
                                        final icon = isPurchase
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward;

                                        final rawDateStr =
                                            tx['transactionDate'] ?? '';
                                        DateTime? parsedDate;
                                        try {
                                          parsedDate = DateFormat(
                                            "MM/dd/yyyy HH:mm:ss",
                                          ).parse(rawDateStr);
                                        } catch (_) {}

                                        final formattedDate = parsedDate != null
                                            ? "${DateFormat("MMM d,").format(parsedDate)}\n${DateFormat("yyyy").format(parsedDate)}"
                                            : 'Invalid Date';

                                        return TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 4,
                                                  ),
                                              child: Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    icon,
                                                    size: 14,
                                                    color: color,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      isPurchase
                                                          ? "Purchased"
                                                          : "Exit",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: color,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                tx['transactionQuantity']
                                                        ?.toString() ??
                                                    "0",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                tx['afterQuantity']
                                                        ?.toString() ??
                                                    "0",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                "\$${(tx['transactionPrice'] ?? 0).toString()}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Helper for mobile row layout
  Widget _buildTwoColumnRow(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                leftValue,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (rightLabel.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  rightValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildValueRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color ?? Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, {bool selected = false}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      selectedColor: Colors.black,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
    );
  }
}
