import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:rt_19/pages/pengurus/input_pengurus.dart';

class PengurusPage extends StatefulWidget {
  @override
  _PengurusPageState createState() => _PengurusPageState();
}

class _PengurusPageState extends State<PengurusPage> {
  String? selectedPeriode;
  List<dynamic> pengurusData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengurusData();
  }

  Future<void> fetchPengurusData() async {
    String url = selectedPeriode == null
        ? 'https://pexadont.agsa.site/api/pengurus'
        : 'https://pexadont.agsa.site/api/pengurus?periode=${selectedPeriode}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (!responseData['error']) {
          setState(() {
            pengurusData = responseData['data'];
            isLoading = false;
          });
        } else {
          showSnackbar(responseData['message']);
        }
      } else {
        showSnackbar('Gagal memuat data pengurus');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatDate(String date) {
    if (date.isEmpty) return 'Unknown Date';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pengurus RT',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xff30C083),
              ),
            )
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Column();
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InputPengurusPage()),
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
                                      'Pengurus',
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
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xff30C083),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Color(0xff30C083),
                              iconEnabledColor: Colors.white,
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: Text(
                                  'Periode',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              value: selectedPeriode,
                              items: [
                                '2019-2024',
                                '2024-2029',
                                '2029-2034',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPeriode = newValue;
                                });
                                fetchPengurusData();
                              },
                              itemHeight: null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: pengurusData.isNotEmpty
                            ? SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pengurusData.length,
                                  itemBuilder: (context, index) {
                                    final pengurus = pengurusData[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(height: 20),
                                          Text(
                                            pengurus['jabatan'],
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                'https://pexadont.agsa.site/uploads/warga/${pengurus['foto']}',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 10),
                                                Text(
                                                  pengurus['nama'],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'NIK : ${pengurus['nik']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Tanggal Lahir : ${formatDate(pengurus['tgl_lahir'])}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Jenis Kelamin : ${pengurus['jenis_kelamin']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'No. Rumah : ${pengurus['no_rumah']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                SizedBox(height: 20),
                                                InkWell(
                                                  onTap: () {},
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: const Color(
                                                            0xff30C083)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10,
                                                        horizontal: 15),
                                                    child: const Text(
                                                      "Aktif",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                    "Tidak ada data pengurus di periode ini."),
                              ),
                      ),
                    ],
                  ),
                );
              }
            }),
    );
  }
}
