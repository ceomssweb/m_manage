import 'package:flutter/material.dart';
import 'package:m_manage/slide_view_page.dart';

class FileManagerPage extends StatelessWidget {
  const FileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // Slide View Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SlideViewPage(),
                  ),
                );
              },
              icon: const Icon(Icons.slideshow),
              label: const Text('Slide View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            // Add more buttons here if needed
          ],
        ),
      ),
    );
  }
}