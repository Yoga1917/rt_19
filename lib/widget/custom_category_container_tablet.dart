import 'package:flutter/material.dart';

class CustomCategoryContainerTablet extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color iconColor;

  const CustomCategoryContainerTablet({
    Key? key,
    required this.icon,
    required this.text,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xff30C083),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            height: 100,
            width: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 80,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
