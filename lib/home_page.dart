import 'package:flutter/material.dart';
import 'package:m_manage/billing_page.dart';
import 'package:m_manage/documents_page.dart';
import 'package:m_manage/product_page.dart';
import 'package:m_manage/staff_management_page.dart';
import 'custom_app_bar.dart'; // Import the custom app bar

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home Page'), // Use CustomAppBar
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Billing'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillingPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Documents'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DocumentsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Product'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Staff Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StaffManagementPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: const ForumComponent(),
    );
  }
}

class ForumComponent extends StatelessWidget {
  const ForumComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.forum,
            size: 100,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 20),
          Text(
            'Welcome to the Forum!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}