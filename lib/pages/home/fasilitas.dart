import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rt_19/pages/fasilitas/edit_fasilitas.dart';
import 'package:rt_19/pages/fasilitas/input_fasilitas.dart';
import 'package:http/http.dart' as http;

class FasilitasPage extends StatefulWidget {
  @override
  State<FasilitasPage> createState() => _FasilitasPageState();
}

class _FasilitasPageState extends State<FasilitasPage> {
  List<dynamic> fasilitasList = [];
  int totalFasilitas = 0;

  @override
  void initState() {
    super.initState();
    fetchFasilitasData();
  }

  Future<void> fetchFasilitasData() async {
    final response =
        await http.get(Uri.parse('https://pexadont.agsa.site/api/fasilitas'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fasilitasList = (data['data'] as List)
            .map((item) => {
                  'nama': item['nama'],
                  'jml': item['jml'],
                  'status': item['status'],
                  'foto': item['foto']
                })
            .toList();
        totalFasilitas = fasilitasList.length;
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Fasilitas',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Column();
          } else {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InputFasilitasPage()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff30C083),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Fasilitas',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: TextField(
                          cursorColor: Color(0xff30C083),
                          decoration: InputDecoration(
                            hintText: 'Cari Fasilitas...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xff30C083)),
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text('Total Fasilitas : $totalFasilitas Fasilitas'),
                SizedBox(
                  height: 30,
                ),
                if (fasilitasList.isNotEmpty) ...[
                  for (var fasilitas in fasilitasList)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  (fasilitas['foto'] != null)
                                      ? 'https://pexadont.agsa.site/uploads/fasilitas/${fasilitas['foto']}'
                                      : 'https://placehold.co/300x300.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  Text(
                                    fasilitas['nama'] ?? 'Unknown Name',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Jumlah : ${fasilitas['jml']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Kondisi : ${fasilitas['status']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditFasilitasPage()),
                                    );
                                    },
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
                                          'Edit',
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
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ] else ...[
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 200, horizontal: 20),
                    child: Center(
                      child: Text(
                        'Data fasilitas kosong.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
        }),
      ),
    );
  }
}
