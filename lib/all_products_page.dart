import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key, required this.products});
  final List<Map<String, dynamic>> products;
  @override
  _AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  Uint8List? _selectedImageBytes;

  Future<void> _addOrUpdateProduct({String? productId}) async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _discountController.text.isNotEmpty) {
      final product = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'discount': double.parse(_discountController.text),
        'dateAdded': DateTime.now(),
      };

      if (productId == null) {
        // Add new product
        await FirebaseFirestore.instance.collection('products').add(product);
      } else {
        // Update existing product
        await FirebaseFirestore.instance.collection('products').doc(productId).update(product);
      }

      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _discountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  }

  Future<void> _printProducts() async {
    final pdf = pw.Document();

    final productsSnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Product List', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Name', 'Price', 'Quantity', 'Discount', 'Date Added'],
                data: productsSnapshot.docs.map((doc) {
                  final data = doc.data();
                  return [
                    data['name'],
                    '\$${data['price']}',
                    data['quantity'].toString(),
                    '${data['discount']}%',
                    (data['dateAdded'] as Timestamp).toDate().toString(),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printProducts,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to Add/Update Product
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(labelText: 'Discount (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _addOrUpdateProduct(),
              child: const Text('Save Product'),
            ),
            const SizedBox(height: 16),
            // Table of Products
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('dateAdded', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final data = product.data() as Map<String, dynamic>;
                      final dateAdded =
                          (data['dateAdded'] as Timestamp).toDate();

                      return Card(
                        child: ListTile(
                          title: Text(data['name']),
                          subtitle: Text(
                              'Price: ₹${data['price']} | Quantity: ${data['quantity']} | Discount: ${data['discount']}% | Date: ${dateAdded.toLocal()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _nameController.text = data['name'];
                                  _priceController.text = data['price'].toString();
                                  _quantityController.text = data['quantity'].toString();
                                  _discountController.text = data['discount'].toString();
                                  _addOrUpdateProduct(productId: product.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}