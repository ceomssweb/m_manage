import 'package:flutter/material.dart';
import 'custom_app_bar.dart'; // Import the custom app bar

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Billing Page'), // Use CustomAppBar
      body: const Center(
        child: Text('Welcome to the Billing Page!'),
      ),
    );
  }
}