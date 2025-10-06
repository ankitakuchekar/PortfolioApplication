import 'dart:convert';
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
import 'package:printing/printing.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchTaxReport();
  }

  Future<void> _fetchTaxReport() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final data = await generateCustomerTaxReport(
      widget.token,
      int.parse(widget.customerId),
      '2025',
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

  Future<void> _printPdfReport() async {
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
            textAlign: pw.TextAlign.center,
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

              // Data Rows
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
            ],
          ),

          pw.SizedBox(height: 16),

          // Capital Gains/Losses
          pw.Text(
            'Capital Gains/Losses',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Table(
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

              // Data Rows
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
                      child: pw.Text('\$${_formatNumber(cost)}'),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                    pw.Padding(
                      child: pw.Text('\$${_formatNumber(proceeds)}'),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        '${gainLoss >= 0 ? '+' : '-'}\$${_formatNumber(gainLoss.abs())}',
                        style: pw.TextStyle(color: gainLossColor),
                      ),
                    ),
                    pw.Padding(
                      child: pw.Text(gain['type'] ?? '-'),
                      padding: const pw.EdgeInsets.all(4),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 16),

          // ✅ Transaction History
          pw.Text(
            'Transaction History',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Table.fromTextArray(
            headers: [
              'Date',
              'Transaction Type',
              'Product Name',
              'Qty',
              'Price per Unit',
            ],
            data: transactions.map((txn) {
              return [
                _formatDate(txn['transactionDate']),
                txn['transactionType'] ?? '-',
                txn['productName'] ?? '-',
                '${txn['transactionQuantity'] ?? '-'}',
                '\$${_formatNumber(txn['transactionPrice'] ?? 0.0)}',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Future<void> _downloadPdfReport() async {
  //   final pdf = pw.Document();

  //   // Build the same content as your _printPdfReport()
  //   pdf.addPage(
  //     pw.MultiPage(
  //       build: (pw.Context context) => [
  //         pw.Center(
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Text(
  //                 'BOLD Precious Metals Tax Report',
  //                 style: pw.TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: pw.FontWeight.bold,
  //                   font: pw.Font.times(),
  //                 ),
  //                 textAlign: pw.TextAlign.center,
  //               ),
  //               pw.SizedBox(height: 8),
  //               if (customerInfo?['startDate'] != null &&
  //                   customerInfo?['endDate'] != null)
  //                 pw.Text(
  //                   _formatDateRange(
  //                     customerInfo!['startDate'],
  //                     customerInfo!['endDate'],
  //                   ),
  //                   style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
  //                 ),
  //               pw.SizedBox(height: 4),
  //               pw.Text(
  //                 'This report includes all investment transactions and holdings for the specified period.',
  //                 style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
  //                 textAlign: pw.TextAlign.center,
  //               ),
  //               pw.SizedBox(height: 24),
  //             ],
  //           ),
  //         ),
  //         // Add your Investment Summary, Capital Gains, Transaction History here
  //       ],
  //     ),
  //   );

  //   try {
  //     // Request permissions if on Android
  //     if (Platform.isAndroid) {
  //       final status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         Fluttertoast.showToast(msg: "Storage permission denied.");
  //         return;
  //       }
  //     }

  //     final bytes = await pdf.save();

  //     final directory = await getExternalStorageDirectory();
  //     final path = directory?.path ?? '/storage/emulated/0/Download';
  //     final file = File(
  //       '$path/tax_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
  //     );

  //     await file.writeAsBytes(bytes);

  //     Fluttertoast.showToast(msg: "PDF downloaded to: ${file.path}");
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Download failed: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Tax Report'),
      drawer: const CommonDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (isLoading)
            const Scaffold(body: Center(child: CircularProgressIndicator()))
          else
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
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              child: const Text(
                'Customer Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
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
                        _formatDate(customerInfo!['reportGenerationDate']),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Investment Summary
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: const Text(
                    'Investment Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey.shade100,
                    ),
                    columns: const [
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Purchase Date')),
                      DataColumn(label: Text('Purchase Price')),
                      DataColumn(label: Text('Current Value')),
                      DataColumn(label: Text('Gain/Loss')),
                    ],
                    rows:
                        productsForPortfolio.isEmpty ||
                            productsForPortfolio.every(
                              (item) =>
                                  item['assetList'] == null &&
                                  item['totalQtyOrdered'] == null &&
                                  item['orderDate'] == null &&
                                  item['pastMetalValue'] == null &&
                                  item['currentMetalValue'] == null,
                            )
                        ? [
                            const DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    'No Investments to display.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                                DataCell.empty,
                              ],
                            ),
                          ]
                        : productsForPortfolio.map<DataRow>((item) {
                            final pastValue = item['pastMetalValue'] ?? 0.0;
                            final currentValue =
                                item['currentMetalValue'] ?? 0.0;
                            final gainLoss = currentValue - pastValue;
                            final gainLossColor = gainLoss >= 0
                                ? Colors.green
                                : Colors.red;

                            return DataRow(
                              cells: [
                                DataCell(Text(item['assetList'] ?? '-')),
                                DataCell(
                                  Text(
                                    '${item['totalQtyOrdered'] ?? '-'}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(Text(_formatDate(item['orderDate']))),
                                DataCell(
                                  Text(
                                    '\$${formatValue(pastValue)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '\$${formatValue(currentValue)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${gainLoss >= 0 ? '+' : '-'}\$${formatValue(gainLoss.abs())}',
                                    style: TextStyle(color: gainLossColor),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                  ),
                ),

                // Total Row
                if (productsForPortfolio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Total Portfolio Value:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '\$${formatValue(productsForPortfolio.fold(0.0, (sum, item) => sum + (item['pastMetalValue'] ?? 0.0)))}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '\$${formatValue(productsForPortfolio.fold(0.0, (sum, item) => sum + (item['currentMetalValue'] ?? 0.0)))}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final totalGainLoss = productsForPortfolio
                                .fold<double>(
                                  0.0,
                                  (sum, item) =>
                                      sum +
                                      ((item['currentMetalValue'] ?? 0.0) -
                                          (item['pastMetalValue'] ?? 0.0)),
                                );

                            final isPositive = totalGainLoss >= 0;
                            return Text(
                              '${isPositive ? '+' : '-'}\$${formatValue(totalGainLoss.abs())}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Summary Stats
          // Transaction History
          buildTransactionHistory(transactions),

          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: const Text(
                    'Capital Gains/Losses Calculation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey.shade50,
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
                        label: SizedBox(width: 120, child: Text('Date Sold')),
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
                          child: Text('Proceeds (sales price'),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(width: 120, child: Text('Gain/Loss')),
                      ),
                      DataColumn(
                        label: SizedBox(width: 100, child: Text('Category')),
                      ),
                    ],
                    rows: capitalGL.isEmpty
                        ? [
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
                          ]
                        : capitalGL.map<DataRow>((gain) {
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
                                    '\$${_formatNumber(cost)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '\$${_formatNumber(proceeds)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${isPositive ? '+' : '-'}\$${_formatNumber(gainLoss.abs())}',
                                    style: TextStyle(color: gainLossColor),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(Text(gain['type'] ?? '-')),
                              ],
                            );
                          }).toList(),
                  ),
                ),

                // Total Row
                if (capitalGL.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 5,
                          child: Text(
                            'Total Realized Gains/Losses',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Builder(
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
                                '${isPositive ? '+' : '-'}\$${_formatNumber(totalGainLoss.abs())}',
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _printPdfReport,
                icon: const Icon(Icons.print),
                label: const Text('Print Report'),
              ),
              const SizedBox(width: 12),
              // TextButton.icon(
              //   onPressed: _downloadPdfReport,
              //   icon: const Icon(Icons.download),
              //   label: const Text('Download PDF'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
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

String _formatNumber(num? number) {
  if (number == null) return '0.00';
  return number.toStringAsFixed(2);
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
  final absValue = value.abs();

  if (absValue >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(1)}B';
  } else if (absValue >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(1)}M';
  } else if (absValue >= 1e3) {
    return '${(value / 1e3).toStringAsFixed(1)}K';
  } else {
    return '${value.toStringAsFixed(0)}';
  }
}

Widget buildTransactionHistory(List<dynamic> transactions) {
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade100,
          child: const Text(
            'Transaction History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        // Data Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.grey.shade50,
            ),
            columns: const [
              DataColumn(
                label: SizedBox(
                  width: 150,
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 150,
                  child: Text(
                    'Transaction Type',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 250,
                  child: Text(
                    'Product Name',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100,
                  child: Text(
                    'Qty',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: SizedBox(
                  width: 150,
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
                    final transactionDate = _formatDate(txn['transactionDate']);
                    final transactionType = txn['transactionType'] ?? '-';
                    final productName = txn['productName'] ?? '-';
                    final quantity = txn['transactionQuantity'] ?? '-';
                    final price = txn['transactionPrice'] ?? 0.0;

                    return DataRow(
                      cells: [
                        DataCell(Text(transactionDate)),
                        DataCell(Text(transactionType)),
                        DataCell(Text(productName)),
                        DataCell(Text('$quantity', textAlign: TextAlign.right)),
                        DataCell(
                          Text(
                            '\$${_formatNumber(price)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
          ),
        ),
      ],
    ),
  );
}
