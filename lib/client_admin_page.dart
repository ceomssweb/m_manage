import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientAdminPage extends StatefulWidget {
  const ClientAdminPage({super.key});

  @override
  _ClientAdminPageState createState() => _ClientAdminPageState();
}

class _ClientAdminPageState extends State<ClientAdminPage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gstController = TextEditingController(); // GST Controller
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  Uint8List? _logoBytes;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
  }

  Future<void> _loadCompanyDetails() async {
    final snapshot = await FirebaseFirestore.instance.collection('company_detail').get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      _documentId = snapshot.docs.first.id;
      setState(() {
        _companyNameController.text = data['name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _gstController.text = data['gst'] ?? '18'; // Default GST to 18% if not set
        _phoneController.text = data['phone'] ?? '';
        _faxController.text = data['fax'] ?? '';
      });
    }
  }

  Future<void> _saveDetails() async {
    final companyDetails = {
      'name': _companyNameController.text,
      'address': _addressController.text,
      'gst': _gstController.text, // Save GST to the database
      'phone': _phoneController.text,
      'fax': _faxController.text,
    };

    if (_documentId == null) {
      // Add new company details
      await FirebaseFirestore.instance.collection('company_detail').add(companyDetails);
    } else {
      // Update existing company details
      await FirebaseFirestore.instance
          .collection('company_detail')
          .doc(_documentId)
          .update(companyDetails);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company details saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Company Address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _gstController,
                decoration: const InputDecoration(labelText: 'GST (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _faxController,
                decoration: const InputDecoration(labelText: 'Fax Number'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveDetails,
                child: const Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}