import 'package:flutter/material.dart';

class CustomCategoryContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const CustomCategoryContainer({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xff30C083),
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            height: 80,
            width: 80,
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
              size: 60,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
