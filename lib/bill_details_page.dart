import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class BillDetailsPage extends StatefulWidget {
  final String billId;

  const BillDetailsPage({super.key, required this.billId});

  @override
  State<BillDetailsPage> createState() => _BillDetailsPageState();
}

class _BillDetailsPageState extends State<BillDetailsPage> {
  Map<String, dynamic>? _billDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  Future<void> _loadBillDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final doc = await FirebaseFirestore.instance.collection('bills').doc(widget.billId).get();
      if (doc.exists) {
        _billDetails = doc.data() as Map<String, dynamic>;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bill details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _billDetails == null
          ? const Center(child: Text('Failed to load bill details.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display bill details
            _buildBillHeader(),
            const SizedBox(height: 20),
            _buildItemsTable(),
            const SizedBox(height: 20),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillHeader() {
    final issuedTo = _billDetails!['issuedTo'] ?? 'Unknown';
    final issuedBy = _billDetails!['issuedBy'] ?? 'N/A';
    final date = (_billDetails!['date'] as Timestamp?)?.toDate(); // Assuming Timestamp in Firestore
    final formattedDate = date != null ? DateFormat('yyyy-MM-dd').format(date) : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bill for: $issuedTo', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Issued by: $issuedBy'),
        Text('Date: $formattedDate'),
      ],
    );
  }

  Widget _buildItemsTable() {
    final items = (_billDetails!['items'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

    if (items.isEmpty) {
      return const Text('No items in this bill.');
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Price'), numeric: true),
        DataColumn(label: Text('Quantity'), numeric: true),
        DataColumn(label: Text('Discount'), numeric: true),
        DataColumn(label: Text('Total'), numeric: true),
      ],
      rows: items.map((item) {
        final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final int quantity = (item['quantity'] as num?)?.toInt() ?? 1;
        final double discount = (item['discount'] as num?)?.toDouble() ?? 0.0;
        final double totalPrice = price * quantity * (1 - discount / 100);

        return DataRow(cells: [
          DataCell(Text(item['name'] ?? '')),
          DataCell(Text(price.toStringAsFixed(2))),
          DataCell(Text(quantity.toString())),
          DataCell(Text('${discount.toStringAsFixed(2)}%')),
          DataCell(Text(totalPrice.toStringAsFixed(2))),
        ]);
      }).toList(),
    );
  }

  Widget _buildSummary() {
    final total = (_billDetails!['total'] as num?)?.toDouble() ?? 0.0;
    final totalDiscount = (_billDetails!['totalDiscount'] as num?)?.toDouble() ?? 0.0;
    final gst = (_billDetails!['gst'] as num?)?.toDouble() ?? 0.0;
    final totalWithGST = (_billDetails!['totalWithGST'] as num?)?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildSummaryRow('Total', total),
        _buildSummaryRow('Discount', totalDiscount),
        _buildSummaryRow('GST', gst),
        _buildSummaryRow('Grand Total', totalWithGST, isBold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    final textStyle = isBold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: textStyle),
          Text('\$${value.toStringAsFixed(2)}', style: textStyle),
        ],
      ),
    );
  }
}