import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'bill_details_page.dart'; // Assuming you have this for details

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _filteredBills = [];
  bool _isLoading = true;

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
        data['id'] = doc.id; // Store the document ID
        if (data['timestamp'] is Timestamp) {
          data['date'] = (data['timestamp'] as Timestamp).toDate();
        } else {
          data['date'] = DateTime.now();
        }
        return data;
      }).toList();
      _filteredBills = List.from(_bills);
    } catch (e) {
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
      appBar: AppBar(
        title: const Text('Bills'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_startDate == null
                        ? 'Start Date'
                        : 'Start: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(_endDate == null
                        ? 'End Date'
                        : 'End: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredBills.isEmpty
                ? const Center(child: Text('No bills found.'))
                : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Adjust the number of columns as needed
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 2.0, // Adjust aspect ratio for content
              ),
              itemCount: _filteredBills.length,
              itemBuilder: (context, index) {
                final bill = _filteredBills[index];
                return _buildBillGridItem(bill);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillGridItem(Map<String, dynamic> bill) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView( // Allow scrolling within the item
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill ID: ${bill['id']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              // Use a ListView.builder for the key-value pairs
              SizedBox(
                height: 200, // Set a maximum height for the list (adjust as needed)
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling on the list itself
                  itemCount: bill.length - 1,  // Exclude ID
                  itemBuilder: (context, index) {
                    final keys = bill.keys.toList();
                    keys.remove("id");
                    final key = keys[index];
                    final value = bill[key];
                    String displayValue = value?.toString() ?? "";

                    //Format Values as Before
                    if (value is double) {
                      displayValue = value.toStringAsFixed(2);
                    } else if (value is DateTime) {
                      displayValue = DateFormat('yyyy-MM-dd').format(value);
                    } else if (value is Timestamp) {
                      displayValue = DateFormat('yyyy-MM-dd').format(value.toDate());
                    } else if (value is List) {
                      displayValue = "${value.length} items";
                    } else if (value is Map) {
                      displayValue = "[Map: ${value.length} entries]";
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '$key:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              displayValue,
                              // No maxLines or ellipsis to show full content (might overflow)
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}