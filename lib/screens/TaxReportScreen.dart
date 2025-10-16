import 'dart:convert';
import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:bold_portfolio/widgets/common_app_bar.dart';
import 'package:bold_portfolio/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// import 'dart:io'; // For Platform, File
// import 'package:path_provider/path_provider.dart'; // For getExternalStorageDirectory
// import 'package:permission_handler/permission_handler.dart'; // For Permission

class TaxReportScreen extends StatefulWidget {
  final String token;
  final String customerId;
  final String selectedYear;

  const TaxReportScreen({
    super.key,
    required this.token,
    required this.customerId,
    required this.selectedYear,
  });

  @override
  _TaxReportPageState createState() => _TaxReportPageState();
}

class _TaxReportPageState extends State<TaxReportScreen> {
  bool isLoading = true;
  String? error;

  Map<String, dynamic>? customerInfo;
  List<dynamic> productsForPortfolio = [];
  List<dynamic> transactions = [];
  List<dynamic> capitalGL = [];

  late String selectedYear;
  late List<String> yearOptions;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    selectedYear = currentYear.toString();
    yearOptions = [currentYear.toString(), (currentYear - 1).toString()];
    _fetchTaxReport(selectedYear);
  }

  Future<void> _fetchTaxReport(selectedYear) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final data = await generateCustomerTaxReport(
      widget.token,
      int.parse(widget.customerId),
      selectedYear,
    );

    if (data != null && data['error'] == null) {
      setState(() {
        customerInfo = (data['customerinfo'] as List?)?.first;
        productsForPortfolio = data['productsForPortfolio'] ?? [];
        transactions = data['transactions'] ?? [];
        capitalGL = data['capitalGL'] ?? [];
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        isLoading = false;
        error = data?['error'] ?? "Failed to fetch tax report data.";
      });
    }
  }

  pw.Widget buildPdfNumbered(int number, String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "$number. ",
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }

  pw.Widget buildPdfBullet(int numbers, String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("$numbers. ", style: pw.TextStyle(fontSize: 12)),
        pw.Expanded(
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadPdfReport() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text(
            'BOLD Precious Metals Tax Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              font: pw.Font.times(), // serif-style font
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          // Date Range
          if (customerInfo?['startDate'] != null &&
              customerInfo?['endDate'] != null)
            pw.Text(
              _formatDateRange(
                customerInfo!['startDate'],
                customerInfo!['endDate'],
              ),
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            'This report includes all investment transactions and holdings for the specified period.',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
            textAlign: pw.TextAlign.left,
          ),
          // Customer Info
          if (customerInfo != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Customer: ${customerInfo!['firstName']} ${customerInfo!['lastName']}',
                ),
                pw.Text(
                  'Address: ${customerInfo!['streetAddress1']}, ${customerInfo!['city']} ${customerInfo!['zip']}',
                ),
                pw.Text(
                  'Report Date: ${_formatDate(customerInfo!['reportGenerationDate'])}',
                ),
              ],
            ),

          pw.SizedBox(height: 16),

          // Investment Summary
          pw.Text(
            'Investment Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(4), // Product Name
              1: const pw.FlexColumnWidth(2), // Qty
              2: const pw.FlexColumnWidth(3), // Purchase Date
              3: const pw.FlexColumnWidth(3), // Purchase Price
              4: const pw.FlexColumnWidth(3), // Current Value
              5: const pw.FlexColumnWidth(3), // Gain/Loss
            },
            border: pw.TableBorder.all(width: 0.5),
            children: [
              // Header Row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    child: pw.Text('Product Name'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Qty'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Purchase Date'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Purchase Price'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Current Value'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Gain/Loss'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                ],
              ),

              // No data message
              if (productsForPortfolio.isEmpty)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'No investment data available.',
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    for (int i = 0; i < 5; i++) pw.SizedBox(),
                  ],
                )
              else ...[
                // Data rows
                ...productsForPortfolio.map((item) {
                  final past = item['pastMetalValue'] ?? 0.0;
                  final current = item['currentMetalValue'] ?? 0.0;
                  final gainLoss = current - past;
                  final gainLossColor = gainLoss >= 0
                      ? PdfColors.green
                      : PdfColors.red;

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        child: pw.Text(item['assetList'] ?? '-'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('${item['totalQtyOrdered'] ?? '-'}'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(_formatDate(item['orderDate'])),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('\$${formatValue(past)}'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('\$${formatValue(current)}'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${gainLoss >= 0 ? '+' : '-'}\$${formatValue(gainLoss.abs())}',
                          style: pw.TextStyle(color: gainLossColor),
                        ),
                      ),
                    ],
                  );
                }),

                // Total Row
                () {
                  final totalPast = productsForPortfolio.fold<double>(
                    0.0,
                    (sum, item) => sum + (item['pastMetalValue'] ?? 0.0),
                  );
                  final totalCurrent = productsForPortfolio.fold<double>(
                    0.0,
                    (sum, item) => sum + (item['currentMetalValue'] ?? 0.0),
                  );
                  final totalGainLoss = totalCurrent - totalPast;
                  final gainLossColor = totalGainLoss >= 0
                      ? PdfColors.green
                      : PdfColors.red;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Total Portfolio Value',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(),
                      pw.SizedBox(),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '\$${formatValue(totalPast)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '\$${formatValue(totalCurrent)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${totalGainLoss >= 0 ? '+' : '-'}\$${formatValue(totalGainLoss.abs())}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: gainLossColor,
                          ),
                        ),
                      ),
                    ],
                  );
                }(),
              ],
            ],
          ),

          pw.SizedBox(height: 16),

          // ✅ Transaction History
          pw.Text(
            'Transaction History',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3), // Date
              1: const pw.FlexColumnWidth(3), // Transaction Type
              2: const pw.FlexColumnWidth(4), // Product Name
              3: const pw.FlexColumnWidth(2), // Qty
              4: const pw.FlexColumnWidth(3), // Price per Unit
            },
            border: pw.TableBorder.all(width: 0.5),
            children: [
              // Header Row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    child: pw.Text('Date'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Transaction Type'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Product Name'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Qty'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Price per Unit'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                ],
              ),

              // Check if transactions list is empty
              if (transactions.isEmpty)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      child: pw.Text(
                        'No transactions available.',
                        textAlign: pw.TextAlign.center,
                      ),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                    pw.Padding(
                      child: pw.Text(''),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                    pw.Padding(
                      child: pw.Text(''),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                    pw.Padding(
                      child: pw.Text(''),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                    pw.Padding(
                      child: pw.Text(''),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                  ],
                ),

              // Data Rows (only if transactions are available)
              if (transactions.isNotEmpty)
                ...transactions.map((txn) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        child: pw.Text(_formatDate(txn['transactionDate'])),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(txn['transactionType'] ?? '-'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(txn['productName'] ?? '-'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('${txn['transactionQuantity'] ?? '-'}'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(
                          '\$${formatValue(txn['transactionPrice'] ?? 0.0)}',
                        ),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                    ],
                  );
                }).toList(),
            ],
          ),

          pw.SizedBox(height: 16),

          // Capital Gains/Losses
          pw.Text(
            'Capital Gains/Losses',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(3),
              4: const pw.FlexColumnWidth(3),
              5: const pw.FlexColumnWidth(3),
              6: const pw.FlexColumnWidth(3),
            },
            border: pw.TableBorder.all(width: 0.5),
            children: [
              // Header Row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    child: pw.Text('Description'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Date Acquired'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Date Sold'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Cost Basis'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Proceeds'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Gain/Loss'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                  pw.Padding(
                    child: pw.Text('Category'),
                    padding: const pw.EdgeInsets.all(4),
                  ),
                ],
              ),

              if (capitalGL.isEmpty)
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          border: pw.Border.all(width: 0.5),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'No Capital Gains/Losses to display.',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                // Map Data Rows
                ...capitalGL.map((gain) {
                  final cost = gain['costBasis'] ?? 0.0;
                  final proceeds = gain['proceeds'] ?? 0.0;
                  final gainLoss = proceeds - cost;
                  final gainLossColor = gainLoss >= 0
                      ? PdfColors.green
                      : PdfColors.red;

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        child: pw.Text(gain['productName'] ?? '-'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(_formatDate(gain['dateAcquired'])),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(_formatDate(gain['dateSold'])),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('\$${formatValue(cost)}'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('\$${formatValue(proceeds)}'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${gainLoss >= 0 ? '+' : '-'}\$${formatValue(gainLoss.abs())}',
                          style: pw.TextStyle(color: gainLossColor),
                        ),
                      ),
                      pw.Padding(
                        child: pw.Text(gain['type'] ?? '-'),
                        padding: const pw.EdgeInsets.all(4),
                      ),
                    ],
                  );
                }).toList(),

                // Total Row
                () {
                  final totalGainLoss = capitalGL.fold<num>(
                    0,
                    (sum, gain) =>
                        sum +
                        ((gain['proceeds'] ?? 0.0) -
                            (gain['costBasis'] ?? 0.0)),
                  );
                  final isPositive = totalGainLoss >= 0;
                  final color = isPositive ? PdfColors.green : PdfColors.red;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Total Realized Gains/Losses',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      for (int i = 0; i < 4; i++) pw.SizedBox(),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${isPositive ? '+' : '-'}\$${formatValue(totalGainLoss.abs())}',
                          style: pw.TextStyle(
                            color: color,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(),
                    ],
                  );
                }(),
              ],
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Calculation Notes:",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              buildPdfBullet(
                1,
                "Cost basis includes original purchase price plus applicable fees",
              ),
              buildPdfBullet(
                2,
                "Short-term gains apply to assets held for one year or less",
              ),
              buildPdfBullet(
                3,
                "Long-term gains apply to assets held for more than one year",
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 20),

              pw.Text(
                "Disclaimers",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              buildPdfNumbered(
                1,
                "This report is provided for informational purposes only. BOLD Precious Metals does not provide tax advice. Consult with a qualified tax professional for personalized advice regarding your specific tax situation and bullion investments.",
              ),
              buildPdfNumbered(
                2,
                "All calculations in this report are based on transaction data from BOLD Precious Metals and any information manually entered by the client. BOLD is not responsible for client-entered data accuracy.",
              ),
              buildPdfNumbered(
                3,
                "Precious metals are classified as 'collectibles' by the IRS, which may result in different tax rates. Consult a tax professional.",
              ),
              buildPdfNumbered(
                4,
                "BOLD is not responsible for any errors or omissions in this report.",
              ),
              buildPdfNumbered(
                5,
                "Retain this report and supporting documents for your tax records.",
              ),
              buildPdfNumbered(
                6,
                "Tax laws are subject to change. It is your responsibility to stay updated.",
              ),
            ],
          ),
        ],
      ),
    );

    try {
      if (Platform.isAndroid) {
        // Android-specific file saving logic
        await Permission.storage.request();
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath =
            '${directory.path}/BOLD_Tax_Reports_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ PDF saved to Downloads folder ${directory.path}/BOLD_Tax_Reports_${DateTime.now().millisecondsSinceEpoch}.pdf',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        debugPrint('✅ PDF saved at: $filePath');
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/BOLD_Tax_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        // Share the PDF using iOS share sheet
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Here is your tax report PDF');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ PDF saved to app documents: $filePath'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        debugPrint('✅ PDF saved at: $filePath');
      }
    } catch (e) {
      debugPrint('❌ Error saving PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Tax Report'),
      drawer: const CommonDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (productsForPortfolio.isEmpty) ...[
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ] else ...[
            // Move Download PDF and Year Dropdown to the top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                TextButton.icon(
                  onPressed: () {
                    final mainState = context
                        .findAncestorStateOfType<MainScreenState>();
                    mainState?.onNavigationTap(0);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    'Back',
                    style: TextStyle(
                      color: const Color.fromRGBO(0, 0, 0, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 12, // space between download and dropdown
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Download PDF Button
                    ElevatedButton.icon(
                      onPressed: _downloadPdfReport,
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Year Dropdown
                DropdownButton<String>(
                  value: selectedYear,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedYear = newValue;
                        _fetchTaxReport(selectedYear);
                      });
                    }
                  },
                  items: yearOptions.map<DropdownMenuItem<String>>((
                    String year,
                  ) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  hint: const Text("Select year"),
                  underline: Container(height: 1, color: Colors.grey),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ), // spacing before the rest of the content
            // Report Header
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              padding: const EdgeInsets.only(bottom: 24),
              margin: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'BOLD Precious Metals Tax Report',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (customerInfo?['startDate'] != null &&
                        customerInfo?['endDate'] != null)
                      Text(
                        _formatDateRange(
                          customerInfo!['startDate'],
                          customerInfo!['endDate'],
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Text(
                      'This report includes all investment transactions and holdings for the specified period.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Customer Information
            if (customerInfo != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with gray background and bottom border
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Customer Info Content
                  Container(
                    decoration: BoxDecoration(
                      border: const Border(
                        left: BorderSide(color: Colors.grey, width: 1),
                        right: BorderSide(color: Colors.grey, width: 1),
                        bottom: BorderSide(color: Colors.grey, width: 1),
                        // no top border
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),

                    padding: const EdgeInsets.all(
                      12,
                    ), // Space inside the border
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${customerInfo!['firstName'] ?? ''} ${customerInfo!['lastName'] ?? ''}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                customerInfo!['streetAddress1'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _formatCityZip(
                                  customerInfo!['city'],
                                  customerInfo!['zip'],
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Report Generated Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatDate(
                                  customerInfo!['reportGenerationDate'],
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ],

            // Investment Summary
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                        // no top border
                      ),
                    ),
                    child: const Text(
                      'Investment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Scrollable Table with Borders
                  Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true, // Always show the scrollbar thumb
                    thickness: 8, // Thickness of the scrollbar
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        decoration: BoxDecoration(
                          // Outer border
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey.shade100,
                          ),
                          dataRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.white,
                          ),
                          dividerThickness: 1,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          columnSpacing: 0,

                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            verticalInside: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),

                          columns: const [
                            DataColumn(
                              label: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Product Name'),
                              ),
                            ),
                            DataColumn(
                              label: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Qty'),
                              ),
                            ),
                            DataColumn(
                              label: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Purchase Date'),
                              ),
                            ),
                            DataColumn(
                              label: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Purchase Price'),
                              ),
                            ),
                            DataColumn(
                              label: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Current Value'),
                              ),
                            ),
                            DataColumn(
                              label: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Gain/Loss'),
                              ),
                            ),
                          ],
                          rows: [
                            if (productsForPortfolio.isNotEmpty)
                              ...productsForPortfolio.map<DataRow>((item) {
                                final pastValue = item['pastMetalValue'] ?? 0.0;
                                final currentValue =
                                    item['currentMetalValue'] ?? 0.0;
                                final gainLoss = currentValue - pastValue;
                                final gainLossColor = gainLoss >= 0
                                    ? Colors.green
                                    : Colors.red;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(item['assetList'] ?? '-'),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          '${item['totalQtyOrdered'] ?? '-'}',
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          _formatDate(item['orderDate']),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          '\$${formatValue(pastValue)}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          '\$${formatValue(currentValue)}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          '${gainLoss >= 0 ? '+' : '-'}\$${formatValue(gainLoss.abs())}',
                                          style: TextStyle(
                                            color: gainLossColor,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),

                            if (productsForPortfolio.isNotEmpty)
                              DataRow(
                                cells: [
                                  const DataCell(
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Total Portfolio Value',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const DataCell(Text('')), // Qty
                                  const DataCell(Text('')), // Purchase Date
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '\$${formatValue(productsForPortfolio.fold(0.0, (sum, item) => sum + (item['pastMetalValue'] ?? 0.0)))}',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '\$${formatValue(productsForPortfolio.fold(0.0, (sum, item) => sum + (item['currentMetalValue'] ?? 0.0)))}',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Builder(
                                        builder: (context) {
                                          final totalGainLoss =
                                              productsForPortfolio.fold<double>(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    ((item['currentMetalValue'] ??
                                                            0.0) -
                                                        (item['pastMetalValue'] ??
                                                            0.0)),
                                              );
                                          final isPositive = totalGainLoss >= 0;
                                          return Text(
                                            '${isPositive ? '+' : '-'}\$${formatValue(totalGainLoss.abs())}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: isPositive
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (productsForPortfolio.isEmpty)
                              const DataRow(
                                cells: [
                                  DataCell(Text('No Investments to display.')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Summary Stats
            // Transaction History
            buildTransactionHistory(transactions),

            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: const Text(
                      'Capital Gains/Losses Calculation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Table
                  Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true, // Always show the scrollbar thumb
                    thickness: 8, // Thickness of the scrollbar
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.grey.shade100,
                        ),
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          verticalInside: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 200,
                              child: Text('Description of property'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text('Date Acquired'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text('Date Sold'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 150,
                              child: Text('Cost or other basis'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 150,
                              child: Text('Proceeds (sales price)'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text('Gain/Loss'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text('Category'),
                            ),
                          ),
                        ],
                        rows: [
                          if (capitalGL.isNotEmpty)
                            ...capitalGL.map<DataRow>((gain) {
                              final cost = gain['costBasis'] ?? 0.0;
                              final proceeds = gain['proceeds'] ?? 0.0;
                              final gainLoss = proceeds - cost;
                              final isPositive = gainLoss >= 0;
                              final gainLossColor = isPositive
                                  ? Colors.green
                                  : Colors.red;

                              return DataRow(
                                cells: [
                                  DataCell(Text(gain['productName'] ?? '-')),
                                  DataCell(
                                    Text(_formatDate(gain['dateAcquired'])),
                                  ),
                                  DataCell(Text(_formatDate(gain['dateSold']))),
                                  DataCell(
                                    Text(
                                      '\$${formatValue(cost)}',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '\$${formatValue(proceeds)}',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${isPositive ? '+' : '-'}\$${formatValue(gainLoss.abs())}',
                                      style: TextStyle(color: gainLossColor),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  DataCell(Text(gain['type'] ?? '-')),
                                ],
                              );
                            }),

                          if (capitalGL.isNotEmpty)
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text(
                                    'Total Realized Gains/Losses',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                DataCell(
                                  Builder(
                                    builder: (context) {
                                      final totalGainLoss = capitalGL.fold<num>(
                                        0,
                                        (sum, gain) =>
                                            sum +
                                            ((gain['proceeds'] ?? 0) -
                                                (gain['costBasis'] ?? 0)),
                                      );
                                      final isPositive = totalGainLoss >= 0;
                                      return Text(
                                        '${isPositive ? '+' : '-'}\$${formatValue(totalGainLoss.abs())}',
                                        style: TextStyle(
                                          color: isPositive
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      );
                                    },
                                  ),
                                ),
                                const DataCell(Text('')),
                              ],
                            ),

                          if (capitalGL.isEmpty)
                            const DataRow(
                              cells: [
                                DataCell(
                                  Text('No Capital Gains/Losses to display.'),
                                ),
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(bottom: 24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Calculation Notes ----
                  Text(
                    "Calculation Notes:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildBulletText(
                    "Cost basis includes original purchase price plus applicable fees",
                  ),
                  _buildBulletText(
                    "Short-term gains apply to assets held for one year or less",
                  ),
                  _buildBulletText(
                    "Long-term gains apply to assets held for more than one year",
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1),
                  const SizedBox(height: 20),

                  // ---- Disclaimers ----
                  Text(
                    "Disclaimers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _buildNumberedText(
                    1,
                    "This report is provided for informational purposes only. "
                    "BOLD Precious Metals does not provide tax advice. Consult with "
                    "a qualified tax professional for personalized advice regarding "
                    "your specific tax situation and bullion investments.",
                  ),

                  const SizedBox(height: 10),

                  _buildNumberedText(
                    2,
                    "All calculations in this report are based on transaction data from "
                    "BOLD Precious Metals and any information manually entered by the "
                    "client. BOLD Precious Metals is not responsible for the accuracy or completeness of client-entered data. It is the client's responsibility to verify the accuracy of all manually entered information.",
                  ),
                  const SizedBox(height: 10),

                  _buildNumberedText(
                    3,
                    "Precious metals, including gold, silver, platinum, and palladium, are classified as 'collectibles' by the IRS. This classification may result in different capital gains tax rates than those applied to other capital assets. Tax laws regarding collectibles can be complex, and it is crucial to consult with a tax professional for accurate reporting.",
                  ),
                  const SizedBox(height: 10),

                  _buildNumberedText(
                    4,
                    "BOLD Precious Metals is not responsible for any errors or omissions in this report or any actions taken in reliance on this information.",
                  ),
                  const SizedBox(height: 10),

                  _buildNumberedText(
                    5,
                    "It is essential to retain this report, along with all original purchase receipts, sale confirmations, and any other relevant documentation, for your tax records. These records may be required by the IRS or state tax authorities.",
                  ),
                  const SizedBox(height: 10),

                  _buildNumberedText(
                    6,
                    "Tax laws and regulations are subject to change. The information in this report is based on current laws as of the report's generation date. It is the client's responsibility to stay informed about any changes that may affect their tax obligations.",
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _buildBulletText(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 16, height: 1.4)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNumberedText(int number, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$number. ",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    ],
  );
}

String _formatDate(dynamic dateInput) {
  if (dateInput == null) return '-';

  try {
    DateTime date;

    if (dateInput is int) {
      // Unix timestamp
      date = DateTime.fromMillisecondsSinceEpoch(dateInput);
    } else if (dateInput is String) {
      // Handles input like: "09/30/2025 00:00:00"
      final inputFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
      date = inputFormat.parse(dateInput);
    } else {
      return '-';
    }

    // Desired format: "9/30/2025" (no leading zero in month/day)
    return '${date.month}/${date.day}/${date.year}';
  } catch (e) {
    return '-';
  }
}

Future<Map<String, dynamic>?> generateCustomerTaxReport(
  String token,
  int customerId,
  String year,
) async {
  final String baseUrl = dotenv.env['API_URL']!;

  final uri = Uri.parse(
    '$baseUrl/Portfolio/GenerateCustomerTaxReport'
    '?token=$token&customerId=$customerId&year=$year',
  );

  try {
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data']; // your JS returns res.data.data
    } else {
      return {'error': 'Server returned ${response.statusCode}'};
    }
  } catch (e) {
    return {'error': e.toString()};
  }
}

String _formatDateRange(String start, String end) {
  return '${_formatDates(start)} - ${_formatDates(end)}';
}

String _formatDates(String? dateStr) {
  if (dateStr == null) return '-';

  try {
    final inputFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
    final date = inputFormat.parse(dateStr);
    final outputFormat = DateFormat('MMMM d, y'); // e.g. October 6, 2025
    return outputFormat.format(date);
  } catch (e) {
    return '-';
  }
}

String _formatCityZip(String? city, String? zip) {
  if (city != null && zip != null) {
    return '$city, $zip';
  } else if (city != null) {
    return city;
  } else if (zip != null) {
    return zip;
  } else {
    return '';
  }
}

String formatValue(num value) {
  final formatter = NumberFormat('#,##0.00');
  return formatter.format(value);
}

Widget buildTransactionHistory(List<dynamic> transactions) {
  final ScrollController _scrollController = ScrollController();

  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: const Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          child: const Text(
            'Transaction History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Scrollbar with horizontal scrolling
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true, // Always show the scrollbar thumb
          thickness: 8, // Thickness of the scrollbar
          radius: const Radius.circular(4),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade100,
              ),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                verticalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              columns: const [
                DataColumn(
                  label: SizedBox(
                    width: 90,
                    child: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      'Transaction Type',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 230,
                    child: Text(
                      'Product Name',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 50,
                    child: Text(
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Text(
                      'Price per Unit',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  numeric: true,
                ),
              ],
              rows: transactions.isEmpty
                  ? [
                      const DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'No transactions available.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell.empty,
                          DataCell.empty,
                          DataCell.empty,
                          DataCell.empty,
                        ],
                      ),
                    ]
                  : transactions.map<DataRow>((txn) {
                      final transactionDate = _formatDate(
                        txn['transactionDate'],
                      );
                      final transactionType = txn['transactionType'] ?? '-';
                      final productName = txn['productName'] ?? '-';
                      final quantity = txn['transactionQuantity'] ?? '-';
                      final price = txn['transactionPrice'] ?? 0.0;

                      return DataRow(
                        cells: [
                          DataCell(Text(transactionDate)),
                          DataCell(Text(transactionType)),
                          DataCell(Text(productName)),
                          DataCell(
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text('$quantity'),
                            ),
                          ),
                          DataCell(
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text('\$${formatValue(price)}'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}
