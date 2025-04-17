import 'package:flutter/material.dart';
import 'package:m_manage/bills_page.dart';
import 'package:m_manage/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _filteredBills = [];
  bool _isLoading = true;

  // Filter criteria (add more as needed)
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final snapshot = await _firestore.collection('bills').get();
      _bills = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Assuming your date field is stored as a Timestamp
        if (data['timestamp'] is Timestamp) {
          data['date'] = (data['timestamp'] as Timestamp).toDate();
        } else {
          data['date'] = DateTime.now(); // Or handle the case where timestamp is missing/invalid
        }
        return data;
      }).toList();
      _filteredBills = List.from(_bills); // Initially, all bills are displayed
    } catch (e) {
      // Handle errors (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBills = _bills.where((bill) {
        final billDate = bill['date'] as DateTime;

        if (_startDate != null && billDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && billDate.isAfter(_endDate!)) {
          return false;
        }

        // Add more filter conditions here as needed (e.g., for amount range, "Issued By")

        return true;
      }).toList();
    });
  }


  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Documents Page'),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BillsPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'View Bills and Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
            ),
          ),
        ),
      ),
    );
  }
}