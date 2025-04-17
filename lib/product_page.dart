import 'package:flutter/material.dart';
import 'package:m_manage/custom_app_bar.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Page',
      ),
      body: const Center(
        child: Text('Welcome to the Product Page!'),
      ),
    );
  }
}