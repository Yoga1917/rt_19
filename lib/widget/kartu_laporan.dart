import 'package:flutter/material.dart';

class KartuLaporan extends StatelessWidget {
  final String month;
  final String aksiBy;
  final String fotoAksiBy;
  final String income;
  final String expense;
  final String publish;
  final VoidCallback onDetail;
  final VoidCallback onPublish;

  KartuLaporan({
    required this.month,
    required this.aksiBy,
    required this.fotoAksiBy,
    required this.income,
    required this.expense,
    required this.publish,
    required this.onDetail,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
          publish == "1"
            ? Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                'https://pexadont.agsa.site/uploads/warga/$fotoAksiBy',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(
                          'https://pexadont.agsa.site/uploads/warga/$fotoAksiBy'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(aksiBy, style: TextStyle(color: Colors.black)),
                ],
              ),
            )
            : SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pemasukan:',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                '$income,-',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran:',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                '$expense,-',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
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
                      'Detail  ',
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
              if (publish == "0")
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
                ),
            ],
          ),
        ],
      ),
    );
  }
}
