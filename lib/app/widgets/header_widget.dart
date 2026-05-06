import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final bool showBorder;

  const HeaderWidget({
    super.key,
    this.title = "HappyTrip",
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: showBorder
            ? Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              )
            : null,
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/logo.png",
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}