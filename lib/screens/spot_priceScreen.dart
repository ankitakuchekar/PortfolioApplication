import 'dart:convert';
import 'package:bold_portfolio/models/spot_price_model.dart';
import 'package:bold_portfolio/widgets/chartData.dart';
import 'package:bold_portfolio/widgets/spotPriceCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const snapYellow = Color.fromARGB(255, 220, 166, 2);

class SpotPriceScreen extends StatefulWidget {
  final ValueChanged<SpotData> onLatestSpotPriceChanged;
  const SpotPriceScreen({super.key, required this.onLatestSpotPriceChanged});

  @override
  State<SpotPriceScreen> createState() => _SpotPriceScreenState();
}

class _SpotPriceScreenState extends State<SpotPriceScreen> {
  int selectedTab = 0;
  String selectedMetal = "Gold";
  bool errorOccurred = false;

  // ----------- Filter mapping: UI text → API value -----------
  final Map<String, String> filterMap = {
    "24H": "1D",
    "1W": "1W",
    "1M": "1M",
    "6M": "6M",
    "YTD": "YTD",
    "1Y": "1Y",
    "5Y": "5Y",
    "All": "ALL",
  };

  String _selectedFilterUI = "24H"; // for ChoiceChip UI
  String _selectedRangeAPI = "1D"; // for API
  SpotData? latestSpotPrice;
  List<ChartData> metalInOuncesData = [];
  bool isLoading = false;
  final String spotBaseUrl = dotenv.env['SPOT_API_URL']!;

  @override
  void initState() {
    super.initState();
    _fetchMetalData(_selectedRangeAPI); // initial API call
  }

  // -------------------- API Fetch --------------------
  Future<void> _fetchMetalData(String range) async {
    setState(() => isLoading = true);

    final int metalId = selectedMetal == "Gold" ? 1 : 2;
    final String url =
        "$spotBaseUrl/SpotPrices/GetHistoricalSpotPriceChart?MetalId=$metalId&Type=$range";

    try {
      final response = await http.get(Uri.parse(url));
      print("API URL: $url");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final chartData = jsonData['data']['chartdata'];
          print("ChartData Length: ${chartData.length}");
          errorOccurred = false; // Reset error state

          setState(() {
            metalInOuncesData = (chartData as List)
                .map((item) => ChartData.fromJson(item))
                .toList();
          });
        } else {
          debugPrint("API Error: Success flag is false");
        }
      } else {
        debugPrint("API Error: ${response.statusCode}");
        errorOccurred = true; // Set error state when fetching fails
      }
    } catch (e) {
      debugPrint("API Exception: $e");
      errorOccurred = true; // Set error state when fetching fails
    } finally {
      setState(() => isLoading = false);
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _metalTabs(),
          const SizedBox(height: 16),
          SpotPriceCard(
            metal: selectedMetal,
            onSpotPriceUpdated: (spotData) {
              print("Received spot price: $spotData");
              // Example: store it in parent state
              setState(() {
                latestSpotPrice = spotData;
              });
              widget.onLatestSpotPriceChanged(spotData);
            },
          ),
          const SizedBox(height: 16),
          _timeFilters(),
          const SizedBox(height: 16),
          _chartPlaceholder(),
        ],
      ),
    );
  }

  // -------------------- Metal Tabs --------------------
  Widget _metalTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 235, 209),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [_tabButton("Gold", 0), _tabButton("Silver", 1)]),
    );
  }

  Widget _tabButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
            selectedMetal = text;
          });
          _fetchMetalData(_selectedRangeAPI); // fetch with current API range
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedTab == index ? snapYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // -------------------- Time Filters --------------------
  Widget _timeFilters() {
    final filters = ["24H", "1W", "1M", "6M", "YTD", "1Y", "5Y", "All"];

    return Wrap(
      spacing: 8,
      children: filters.map((e) {
        return ChoiceChip(
          label: Text(e, style: const TextStyle(color: Colors.black)),
          selected: _selectedFilterUI == e,
          selectedColor: selectedMetal == 'Silver'
              ? Colors.grey.shade400
              : snapYellow,

          onSelected: (_) {
            setState(() {
              _selectedFilterUI = e; // update UI
              _selectedRangeAPI = filterMap[e] ?? "1D"; // map to API
            });
            _fetchMetalData(_selectedRangeAPI); // fetch API
          },
        );
      }).toList(),
    );
  }

  // -------------------- Chart --------------------
  Widget _chartPlaceholder() {
    return Container(
      height: 450,
      decoration: _cardDecoration(),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ChartPage(
              data: metalInOuncesData,
              metal: selectedMetal,
              selectedFilter: _selectedFilterUI,
              errorOccurred: errorOccurred,
              pressedRetry: () {
                _fetchMetalData(_selectedRangeAPI);
              },
            ),
    );
  }

  // -------------------- Card Decoration --------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
