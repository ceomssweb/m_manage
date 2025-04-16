import 'package:flutter/material.dart';
import 'custom_app_bar.dart'; // Import the custom app bar
import 'print_bill_page.dart'; // Import the PrintBillPage

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'Product A', 'price': 100.0, 'quantity': 2, 'discount': 10.0},
    {'id': 2, 'name': 'Product B', 'price': 200.0, 'quantity': 1, 'discount': 0.0},
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _issuedByController = TextEditingController();
  final TextEditingController _issuedToController = TextEditingController();

  int? _editingIndex;

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _discountController.clear();
    _editingIndex = null;
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int quantity = int.tryParse(_quantityController.text) ?? 1;
      final double discount = double.tryParse(_discountController.text) ?? 0.0;

      setState(() {
        if (_editingIndex == null) {
          // Add new product
          _products.add({
            'id': _products.length + 1,
            'name': name,
            'price': price,
            'quantity': quantity,
            'discount': discount,
          });
        } else {
          // Update existing product
          _products[_editingIndex!] = {
            'id': _products[_editingIndex!]['id'],
            'name': name,
            'price': price,
            'quantity': quantity,
            'discount': discount,
          };
        }
      });

      _resetForm();
    }
  }

  void _editProduct(int index) {
    setState(() {
      _editingIndex = index;
      _nameController.text = _products[index]['name'];
      _priceController.text = _products[index]['price'].toString();
      _quantityController.text = _products[index]['quantity'].toString();
      _discountController.text = _products[index]['discount'].toString();
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  double _calculateTotal() {
    return _products.fold(0.0, (sum, product) {
      final double totalPrice = product['price'] * product['quantity'];
      final double discount = product['discount'];
      return sum + (totalPrice - (totalPrice * discount / 100));
    });
  }

  void _printBill() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrintBillPage(
          products: _products,
          issuedBy: _issuedByController.text,
          issuedTo: _issuedToController.text,
          total: _calculateTotal(),
          logoPath: 'assets/images/logo/mt-logo.png', // Replace with your logo path
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
                    decoration: const InputDecoration(labelText: 'Bill Issued By'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter who issued the bill';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _issuedToController,
                    decoration: const InputDecoration(labelText: 'Bill Issued To'),
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
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _saveProduct,
                        child: Text(_editingIndex == null ? 'Add Product' : 'Update Product'),
                      ),
                      if (_editingIndex != null)
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Cancel'),
                        ),
                    ],
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
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Discount (%)')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _products.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> product = entry.value;
                        return DataRow(cells: [
                          DataCell(Text(product['id'].toString())),
                          DataCell(Text(product['name'])),
                          DataCell(Text(product['price'].toString())),
                          DataCell(Text(product['quantity'].toString())),
                          DataCell(Text(product['discount'].toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editProduct(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(index),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_calculateTotal().toStringAsFixed(2)}',
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
              onPressed: _printBill,
              child: const Text('Print Bill'),
            ),
          ],
        ),
      ),
    );
  }
}