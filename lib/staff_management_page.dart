import 'package:flutter/material.dart';
import 'package:m_manage/custom_app_bar.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Staff Management'),
      body: const Center(
        child: Text('Welcome to the Staff Management Page!'),
      ),
    );
  }
}