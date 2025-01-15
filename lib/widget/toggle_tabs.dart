import 'package:flutter/material.dart';

class ToggleTabs extends StatelessWidget {
  final bool isSelectedLeft; 
  final String leftLabel; 
  final String rightLabel; 
  final Function(bool) onToggle; 

  const ToggleTabs({
    Key? key,
    required this.isSelectedLeft,
    required this.leftLabel,
    required this.rightLabel,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => onToggle(true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelectedLeft
                  ? Color(0xff30C083)
                  : Colors.white, // Warna latar belakang
              border: Border.all(
                width: 2,
                  color: isSelectedLeft
                      ? Color(0xff30C083)
                      : Color(0xff30C083) // Border hijau
                  ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              leftLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelectedLeft ? Colors.white : Color(0xff30C083),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onToggle(false), 
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelectedLeft
                  ? Colors.white
                  : Color(0xff30C083), 
              border: Border.all(
                width: 2,
                color: isSelectedLeft
                    ? Color(0xff30C083)
                    : Color(0xff30C083), 
              ),
              borderRadius: BorderRadius.circular(10), 
            ),
            child: Text(
              rightLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelectedLeft ? Color(0xff30C083) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
