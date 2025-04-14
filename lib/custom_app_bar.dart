import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true, // Center the title (logo)
      title: Image.asset(
        'assets/images/logo/mt-logo.png', // Path to the logo
        fit: BoxFit.contain,
        height: 40, // Adjust the height of the logo
      ),
      backgroundColor: Colors.deepPurple,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Center(
            child: AnimatedDateTime(), // Use the animated date-time widget
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AnimatedDateTime extends StatefulWidget {
  const AnimatedDateTime({super.key});

  @override
  _AnimatedDateTimeState createState() => _AnimatedDateTimeState();
}

class _AnimatedDateTimeState extends State<AnimatedDateTime>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _ticker = Ticker((_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('hh:mm:ss a').format(_currentTime);
    final formattedDate = DateFormat('dd/MM/yyyy').format(_currentTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}