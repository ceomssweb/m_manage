import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SlideshowPage extends StatefulWidget {
  final List<XFile> images;

  const SlideshowPage({super.key, required this.images});

  @override
  _SlideshowPageState createState() => _SlideshowPageState();
}

class _SlideshowPageState extends State<SlideshowPage> {
  int _currentIndex = 0;
  List<Uint8List> _imageBytes = [];

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  Future<void> _loadImageBytes() async {
    for (var image in widget.images) {
      final bytes = await image.readAsBytes();
      _imageBytes.add(bytes);
    }
    setState(() {});
  }

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _imageBytes.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _imageBytes.length) % _imageBytes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slideshow'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageBytes.isNotEmpty
                ? Image.memory(
                    _imageBytes[_currentIndex],
                    fit: BoxFit.contain,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousImage,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextImage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}