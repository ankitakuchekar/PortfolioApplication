import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/widgets/add_holding_form.dart';
import 'package:bold_portfolio/widgets/holding_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';

class HoldingsScreen extends StatefulWidget {
  final PortfolioData? portfolioData;

  const HoldingsScreen({super.key, this.portfolioData});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Holdings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final holdingData =
              portfolioProvider.portfolioData?.data[0].productHoldings;
          final filteredHoldings = holdingData?.where((holding) {
            final query = _searchController.text.toLowerCase();
            final matchesSearch = holding.assetList.toLowerCase().contains(
              query,
            );
            final matchesFilter =
                selectedFilter == 'All' ||
                holding.metal.toLowerCase() == selectedFilter.toLowerCase();
            return matchesSearch && matchesFilter;
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddHoldingForm(
                              onClose: () => Navigator.of(context).pop(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Holdings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search product by name',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            underline: const SizedBox(),
                            items: ['All', 'Gold', 'Silver'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFilter = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredHoldings?.isEmpty ?? true
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No holdings found',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredHoldings?.length ?? 0,
                        itemBuilder: (context, index) {
                          final holding = filteredHoldings![index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HoldingCard(holding: holding),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
