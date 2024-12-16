import 'package:flutter/material.dart';
import 'package:rt_19/widget/toggle_tabs.dart';

class DetailKASPage extends StatefulWidget {
  @override
  State<DetailKASPage> createState() => _DetailKASPageState();
}

class _DetailKASPageState extends State<DetailKASPage> {
  bool isPemasukanSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Detail Kas RT',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Column();
            } else {
              return Column(
                children: [
                  SizedBox(height: 30),
                  ToggleTabs(
                    isSelectedLeft: isPemasukanSelected,
                    leftLabel: 'Pemasukan',
                    rightLabel: 'Pengeluaran',
                    onToggle: (value) {
                      setState(() {
                        isPemasukanSelected = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: isPemasukanSelected
                        ? Column(
                            children: [
                              Text(
                                'Detail Pemasukan',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month,
                                                    color: Colors.black),
                                                SizedBox(width: 10),
                                                Text(
                                                  '14 Januari 2024',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              'Rp. 50.000.000,-',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Sumber :',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Iuran Warga',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                'Detail Pengeluaran',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month,
                                                    color: Colors.black),
                                                SizedBox(width: 10),
                                                Text(
                                                  '28 Januari 2024',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              'Rp. 10.000.000,-',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Digunakan :',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            'https://placehold.co/300x300.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Iuran Warga',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
