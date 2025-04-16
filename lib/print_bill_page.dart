import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for rootBundle
import 'package:printing/printing.dart'; // Import the printing package
import 'package:pdf/widgets.dart' as pw;

class PrintBillPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String issuedBy;
  final String issuedTo;
  final double total;
  final double totalDiscount;
  final double gst;
  final double totalWithGST;
  final String logoPath; // Path to the product logo

  const PrintBillPage({
    super.key,
    required this.items,
    required this.issuedBy,
    required this.issuedTo,
    required this.total,
    required this.totalDiscount,
    required this.gst,
    required this.totalWithGST,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final String currentDateTime = _getCurrentDateTime(); // Get current date and time

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Bill'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printBill(context), // Call the print function
          ),
        ],
      ),
      body: Stack(
        children: [
          // Watermarked background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Adjust opacity for watermark effect
              child: Image.asset(
                logoPath, // Path to the product logo
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Bill content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Logo, Company Details, and Date/Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Image.asset(
                      logoPath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    // Company Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Company Name',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Address Line 1',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Address Line 2',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Phone: +1 234 567 890',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Date and Time
                    Text(
                      currentDateTime,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Issued By and Issued To
                Text(
                  'Bill Issued By: $issuedBy',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bill Issued To: $issuedTo',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Table Header
                Row(
                  children: const [
                    Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Discount', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const Divider(),
                // Table Rows
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final double totalPrice = item['price'] * item['quantity'];
                      final double discountedPrice =
                          totalPrice - (totalPrice * item['discount'] / 100);
                      return Row(
                        children: [
                          Expanded(child: Text(item['name'])),
                          Expanded(child: Text('\$${item['price'].toStringAsFixed(2)}')),
                          Expanded(child: Text('${item['quantity']}')),
                          Expanded(child: Text('${item['discount']}%')),
                          Expanded(child: Text('\$${discountedPrice.toStringAsFixed(2)}')),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(),
                // Total Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Discount:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '\$${totalDiscount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Grand Total (Before GST)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total (Before GST):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // GST
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GST (18%):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '\$${gst.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Grand Total (After GST)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total (After GST):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '\$${totalWithGST.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}';
  }

  Future<void> _printBill(BuildContext context) async {
    final pdf = pw.Document();

    try {
      // Load the logo image
      final logoBytes = await rootBundle.load(logoPath);

      // Get the current date and time
      final now = DateTime.now();
      final String formattedDate = '${now.day}/${now.month}/${now.year}';
      final String formattedTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      // Add content to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Section with Logo and Company Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    pw.Image(
                      pw.MemoryImage(logoBytes.buffer.asUint8List()),
                      width: 80,
                      height: 80,
                    ),
                    // Company Details
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Company Name',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Address Line 1', style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Address Line 2', style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Phone: +1 234 567 890', style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Email: info@company.com', style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    // Date and Time
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Date: $formattedDate',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Time: $formattedTime',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                // Issued By and Issued To
                pw.Text(
                  'Bill Issued By: $issuedBy',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Bill Issued To: $issuedTo',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                // Items Table
                pw.Text(
                  'Items:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Name', 'Price', 'Quantity', 'Discount', 'Total'],
                  data: items.map((item) {
                    final double totalPrice = item['price'] * item['quantity'];
                    final double discountedPrice =
                        totalPrice - (totalPrice * item['discount'] / 100);
                    return [
                      item['name'],
                      '\$${item['price'].toStringAsFixed(2)}',
                      '${item['quantity']}',
                      '${item['discount']}%',
                      '\$${discountedPrice.toStringAsFixed(2)}',
                    ];
                  }).toList(),
                ),
                pw.Divider(),
                // Totals Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Discount:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    pw.Text(
                      '\$${totalDiscount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Grand Total (Before GST):',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    pw.Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'GST (18%):',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    pw.Text(
                      '\$${gst.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Grand Total (After GST):',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    pw.Text(
                      '\$${totalWithGST.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Print the PDF
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF. Please try again.')),
      );
    }
  }
}