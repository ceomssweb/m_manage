import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Welcome to the Product Page!'),
      ),
    );
  }
}