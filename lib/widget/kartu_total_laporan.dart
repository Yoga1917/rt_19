import 'package:flutter/material.dart';

class TotalCard extends StatelessWidget {
  final String totalIncome;
  final String totalExpense;
  final String remainingFunds;

  TotalCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingFunds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekapitulasi Dana',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pemasukan:',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                '$totalIncome,-',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran:',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                '$totalExpense,-',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa Dana:',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                '$remainingFunds,-',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
