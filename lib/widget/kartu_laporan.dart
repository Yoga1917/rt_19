import 'package:flutter/material.dart';

class KartuLaporan extends StatelessWidget {
  final String month;
  final String aksiBy;
  final String income;
  final String expense;
  final String publish;
  final VoidCallback onDetail;
  final VoidCallback onPublish;

  KartuLaporan({
    required this.month,
    required this.aksiBy,
    required this.income,
    required this.expense,
    required this.publish,
    required this.onDetail,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            month,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.person_2_outlined, size: 16),
              ),
              Text(aksiBy),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pemasukan:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text(
                income,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text(
                expense,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: onDetail,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color(0xff30C083),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Detail',
                      style: TextStyle(
                        color: Color(0xff30C083),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              publish == "0" ?
              GestureDetector(
                onTap: onPublish,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff30C083),
                    border: Border.all(
                      color: Color(0xff30C083),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Publish',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ) : const Text(""),
            ],
          ),
        ],
      ),
    );
  }
}
