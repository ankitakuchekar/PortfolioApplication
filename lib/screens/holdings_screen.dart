import 'package:bold_portfolio/models/portfolio_model.dart';
import 'package:bold_portfolio/widgets/add_holding_form.dart';
import 'package:bold_portfolio/widgets/holding_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Holdings'),
      drawer: const CommonDrawer(),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final holdingData =
              portfolioProvider.portfolioData?.data[0].productHoldings;
          final showActualPrice =
              portfolioProvider
                  .portfolioData
                  ?.data[0]
                  .portfolioSettings
                  .showActualPrice ??
              false;
          final showMetalPrice =
              portfolioProvider
                  .portfolioData
                  ?.data[0]
                  .portfolioSettings
                  .showMetalPrice ??
              false;

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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Asset Holdings By Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ordered products are automatically added to holdings once shipped.',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5, // Adjust line height here
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Note: ', // "Note:" in bold
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    'Your Bullion Portfolio currently displays only products purchased from Bold Precious Metals on or after ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  height:
                                      1.5, // Line height for the first row of text
                                ),
                              ),
                              TextSpan(
                                text: 'January 1, 2023.',
                                style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold, // "January 1, 2023." in bold
                                ),
                              ),
                              TextSpan(
                                text: '  ', // Add space between two words
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                            label: const Text(
                              'Add New Holdings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                  const SizedBox(height: 16),
                  if (filteredHoldings?.isEmpty ?? true)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Column(
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
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredHoldings?.length ?? 0,
                      itemBuilder: (context, index) {
                        final holding = filteredHoldings![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HoldingCard(
                            holding: holding,
                            showActualPrice: showActualPrice,
                            showMetalPrice: showMetalPrice,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
