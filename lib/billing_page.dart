import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart'; // Import the custom app bar
import 'print_bill_page.dart'; // Import the PrintBillPage

class BillingPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  const BillingPage({super.key, required this.products});

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _issuedByController = TextEditingController();
  final TextEditingController _issuedToController = TextEditingController();
  final List<Map<String, dynamic>> _items = []; // Local list to store items temporarily
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  Map<String, dynamic>? _selectedProduct;
  double _gstRate = 0.18; // Default GST rate (18%)

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
  }

  Future<void> _loadCompanyDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('company_detail').get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _issuedByController.text = data['name'] ?? 'Unknown Company';
          _gstRate = double.tryParse(data['gst'] ?? '18')! / 100; // Convert GST to decimal
        });
      }
    } catch (e) {
      print('Error fetching company details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load company details.')),
      );
    }
  }

  void _onProductSelected(Map<String, dynamic>? product) {
    setState(() {
      _selectedProduct = product;
      _priceController.text = product != null ? product['price'].toString() : '';
      _discountController.text = product != null ? product['discount'].toString() : '';
    });
  }

  void _addItemLocally() {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      final String name = _selectedProduct!['name'];
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
    _selectedProduct = null;
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
    return _calculateTotal() * _gstRate;
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
        'gstRate': _gstRate * 100, // Save GST as a percentage
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
                    readOnly: true,
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
                  // Product Dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final products = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          'id': doc.id,
                          'name': data['name'],
                          'price': data['price'],
                          'discount': data['discount'],
                        };
                      }).toList();

                      return DropdownButtonFormField<String>(
                        value: _selectedProduct?['id'], // Use the product ID as the value
                        items: products.map((product) {
                          return DropdownMenuItem<String>(
                            value: product['id'], // Use the product ID as the unique value
                            child: Text('${product['name']} (₹${product['price']})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          final selectedProduct = products.firstWhere((product) => product['id'] == value);
                          setState(() {
                            _selectedProduct = selectedProduct;
                            _priceController.text = selectedProduct['price'].toString();
                            _discountController.text = selectedProduct['discount']?.toString() ?? '0';
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Select Product'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
            // Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addItemLocally,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white, // Contrast font color
                  ),
                  child: const Text('Add Item'),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white, // Contrast font color
                      ),
                      child: const Text('Reset Form'),
                    ),
                    const SizedBox(width: 8), // Add spacing between buttons
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _items.clear(); // Clear all items
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white, // Contrast font color
                      ),
                      child: const Text('Cancel All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table Section
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Discount (%)')),
                    DataColumn(label: Text('Total')),
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
                      DataCell(Text(discountedPrice.toStringAsFixed(2))),
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
              ),
            ),
            const SizedBox(height: 16),
            // Totals Section
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
                Text(
                  'GST (${(_gstRate * 100).toStringAsFixed(2)}%): ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            const SizedBox(height: 16),
            // Save and Print Button at the Bottom
            ElevatedButton(
              onPressed: _items.isNotEmpty ? _saveAndPrintBill : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, // Contrast font color
                minimumSize: const Size(double.infinity, 50), // Full-width button
              ),
              child: const Text('Save and Print Bill'),
            ),
          ],
        ),
      ),
    );
  }
}