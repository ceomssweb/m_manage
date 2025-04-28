import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ClientAdminPage extends StatefulWidget {
  const ClientAdminPage({super.key});

  @override
  _ClientAdminPageState createState() => _ClientAdminPageState();
}

class _ClientAdminPageState extends State<ClientAdminPage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  File? _logo;
  List<File> _shopImages = [];
  List<File> _certificates = [];

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickShopImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _shopImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _pickCertificates() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _certificates = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _saveDetails() {
    // Save company details logic here
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
                decoration: const InputDecoration(labelText: 'GST Number'),
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
                onPressed: _pickLogo,
                child: const Text('Upload Company Logo'),
              ),
              if (_logo != null)
                const Text('Logo Selected', style: TextStyle(color: Colors.green)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickShopImages,
                child: const Text('Upload Shop Images'),
              ),
              if (_shopImages.isNotEmpty)
                Text('${_shopImages.length} Shop Images Selected',
                    style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickCertificates,
                child: const Text('Upload Certificates'),
              ),
              if (_certificates.isNotEmpty)
                Text('${_certificates.length} Certificates Selected',
                    style: const TextStyle(color: Colors.green)),
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