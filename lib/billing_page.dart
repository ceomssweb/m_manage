import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'custom_app_bar.dart'; // Import the custom app bar
import 'print_bill_page.dart'; // Import the PrintBillPage

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _issuedByController = TextEditingController();
  final TextEditingController _issuedToController = TextEditingController();
  final List<Map<String, dynamic>> _items = []; // Local list to store items temporarily
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  void _addItemLocally() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final int quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      final double discount = double.tryParse(_discountController.text.trim()) ?? 0.0;

      setState(() {
        _items.add({
          'name': name,
          'price': price,
          'quantity': quantity,
          'discount': discount,
        });
      });

      _resetForm();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _discountController.clear();
  }

  double _calculateTotal() {
    return _items.fold(0.0, (sum, item) {
      final double totalPrice = item['price'] * item['quantity'];
      final double discount = item['discount'];
      return sum + (totalPrice - (totalPrice * discount / 100));
    });
  }

  double _calculateTotalDiscount() {
    return _items.fold(0.0, (sum, item) {
      final double totalPrice = item['price'] * item['quantity'];
      final double discount = item['discount'];
      return sum + (totalPrice * discount / 100);
    });
  }

  double _calculateGST() {
    const double gstRate = 0.18; // 18% GST
    return _calculateTotal() * gstRate;
  }

  double _calculateTotalWithGST() {
    return _calculateTotal() + _calculateGST();
  }

  Future<void> _saveAndPrintBill() async {
    try {
      final double total = _calculateTotal();

      // Save the billing data to Firestore
      await FirebaseFirestore.instance.collection('bills').add({
        'issuedBy': _issuedByController.text.trim(),
        'issuedTo': _issuedToController.text.trim(),
        'items': _items,
        'total': total,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Trigger the print functionality
      _printBill();
    } catch (e) {
      print('Error saving bill: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save bill. Please try again.')),
      );
    }
  }

  void _printBill() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrintBillPage(
          items: _items,
          issuedBy: _issuedByController.text.trim(),
          issuedTo: _issuedToController.text.trim(),
          total: _calculateTotal(),
          totalDiscount: _calculateTotalDiscount(),
          gst: _calculateGST(),
          totalWithGST: _calculateTotalWithGST(),
          logoPath: 'assets/images/logo/mt-logo.png', // Ensure this path is correct
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Billing Page'), // Use CustomAppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _issuedByController,
                    decoration: const InputDecoration(labelText: 'Issued By'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter who issued the bill';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _issuedToController,
                    decoration: const InputDecoration(labelText: 'Issued To'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter who the bill is issued to';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an item name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(labelText: 'Discount (%)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a discount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addItemLocally,
                    child: const Text('Add Item'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Discount (%)')),
                        DataColumn(label: Text('Total')), // Add Total column
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _items.map((item) {
                        final double totalPrice = item['price'] * item['quantity'];
                        final double discountedPrice = totalPrice - (totalPrice * item['discount'] / 100);

                        return DataRow(cells: [
                          DataCell(Text(item['name'])),
                          DataCell(Text(item['price'].toString())),
                          DataCell(Text(item['quantity'].toString())),
                          DataCell(Text(item['discount'].toString())),
                          DataCell(Text(discountedPrice.toStringAsFixed(2))), // Display Total
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _items.remove(item);
                                });
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                    const Divider(), // Add a divider for separation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Discount: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_calculateTotalDiscount().toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Grand Total (Before GST): ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_calculateTotal().toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'GST (18%): ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_calculateGST().toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Grand Total (After GST): ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_calculateTotalWithGST().toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _items.isNotEmpty ? _saveAndPrintBill : null,
              child: const Text('Save and Print Bill'),
            ),
          ],
        ),
      ),
    );
  }
}