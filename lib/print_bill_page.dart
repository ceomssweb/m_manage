
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart'; // Import the printing package
import 'package:pdf/widgets.dart' as pw;

class PrintBillPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final String issuedBy;
  final String issuedTo;
  final double total;
  final String logoPath; // Path to the product logo

  const PrintBillPage({
    super.key,
    required this.products,
    required this.issuedBy,
    required this.issuedTo,
    required this.total,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Bill'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printBill(),
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
                // Header with Logo and Company Details
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
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final double totalPrice = product['price'] * product['quantity'];
                      final double discountedPrice =
                          totalPrice - (totalPrice * product['discount'] / 100);
                      return Row(
                        children: [
                          Expanded(child: Text(product['name'])),
                          Expanded(child: Text('\$${product['price'].toStringAsFixed(2)}')),
                          Expanded(child: Text('${product['quantity']}')),
                          Expanded(child: Text('${product['discount']}%')),
                          Expanded(child: Text('\$${discountedPrice.toStringAsFixed(2)}')),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(),
                // Total
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Grand Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _printBill() async {
    final pdf = pw.Document();

    // Load the logo asynchronously before adding the page
    final Uint8List logoBytes = await _loadLogo();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with Logo and Company Details
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(
                  pw.MemoryImage(logoBytes), // Use the loaded logo bytes
                  width: 80,
                  height: 80,
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Company Name', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Address Line 1', style: pw.TextStyle(fontSize: 16)),
                    pw.Text('Address Line 2', style: pw.TextStyle(fontSize: 16)),
                    pw.Text('Phone: +1 234 567 890', style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            // Issued By and Issued To
            pw.Text('Bill Issued By: $issuedBy', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Bill Issued To: $issuedTo', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            // Table Header
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Discount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            pw.Divider(),
            // Table Rows
            ...products.map((product) {
              final double totalPrice = product['price'] * product['quantity'];
              final double discountedPrice = totalPrice - (totalPrice * product['discount'] / 100);
              return pw.Row(
                children: [
                  pw.Expanded(child: pw.Text(product['name'])),
                  pw.Expanded(child: pw.Text('\$${product['price'].toStringAsFixed(2)}')),
                  pw.Expanded(child: pw.Text('${product['quantity']}')),
                  pw.Expanded(child: pw.Text('${product['discount']}%')),
                  pw.Expanded(child: pw.Text('\$${discountedPrice.toStringAsFixed(2)}')),
                ],
              );
            }),
            pw.Divider(),
            // Total
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: \$${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    // Send the PDF to the printer
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<Uint8List> _loadLogo() async {
    final ByteData data = await rootBundle.load(logoPath);
    return data.buffer.asUint8List();
  }
}