import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indonesia/indonesia.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:rt_19/pages/kas_RT/detail_kas.dart';
import 'package:rt_19/pages/kas_RT/input_kas.dart';
import 'package:rt_19/widget/kartu_laporan.dart';
import 'package:rt_19/widget/kartu_total_laporan.dart';

class KasPage extends StatefulWidget {
  @override
  State<KasPage> createState() => _KasPageState();
}

class _KasPageState extends State<KasPage> {
  String? selectedYear;
  List<dynamic> kasData = [];
  bool isLoading = true;
  String? aksiBy;
  int saldo_kas = 0;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toString();
    _fetchKas();
  }

  void _fetchKas() async {
    try {
      String url = selectedYear == null
          ? 'https://pexadont.agsa.site/api/kas'
          : 'https://pexadont.agsa.site/api/kas?tahun=${selectedYear}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          kasData = responseData['data'];
          kasData.sort((a, b) =>
              int.parse(b['id_kas']).compareTo(int.parse(a['id_kas'])));

          int totalSisaKas = 0;
          for (var kas in kasData) {
            int pemasukan =
                kas['pemasukan'] != null ? int.parse(kas['pemasukan']) : 0;
            int pengeluaran =
                kas['pengeluaran'] != null ? int.parse(kas['pengeluaran']) : 0;
            totalSisaKas += (pemasukan - pengeluaran);
          }
          saldo_kas = totalSisaKas;

          isLoading = false;
          aksiBy = responseData['aksiBy'];
        });
      } else {
        showSnackbar('Gagal memuat data kas');
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

  void _publishKas(id_kas) async {
    final response = await http.post(
        Uri.parse('https://pexadont.agsa.site/api/kas/publish/simpan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_kas': id_kas,
        }));

    if (response.statusCode == 200) {
      showSnackbar('Berhasil Publish KAS');

      Navigator.of(context).pop();
      _fetchKas();
    } else {
      showSnackbar('Gagal memuat data kas');
      print(jsonDecode(response.body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Uang KAS RT',
          style: TextStyle(
            color: Colors.white,
          ),
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
          : SingleChildScrollView(
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Column();
                } else {
                  return Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InputKASPage()),
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
                                        'Kas RT',
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
                                      horizontal: 10),
                                  child: Text(
                                    'Pilih Tahun',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                value: selectedYear,
                                items: generateYearList()
                                    .map<DropdownMenuItem<String>>(
                                        (String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        year,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedYear = newValue;
                                  });
                                  _fetchKas();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      if (kasData.length > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Saldo Kas : ',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              '${rupiah(saldo_kas)},-',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      SizedBox(height: 10),
                      kasData.length > 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: kasData.length,
                              itemBuilder: (context, index) {
                                final kas = kasData[index];
                                return Column(
                                  children: [
                                    KartuLaporan(
                                      month: kas['bulan'] + " " + kas['tahun'],
                                      aksiBy: aksiBy!,
                                      income: rupiah(kas['pemasukan'] ?? 0),
                                      expense: rupiah(kas['pengeluaran'] ?? 0),
                                      publish: kas['publish'],
                                      onDetail: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailKASPage(kas['id_kas'])),
                                        );
                                      },
                                      // onPublish: () => _publishKas(kas['id_kas']),
                                      onPublish: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Konfirmasi"),
                                            content: Text(
                                                "Publish KAS bulan ${kas['bulan'] + " " + kas['tahun']}?"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text(
                                                  "Batal",
                                                  style: TextStyle(
                                                      color: Color(0xff30C083),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                style: const ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll(
                                                            Color(0xff30C083))),
                                                child: const Text(
                                                  "Publish",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () =>
                                                    _publishKas(kas['id_kas']),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    TotalCard(
                                        totalIncome:
                                            rupiah(kas['pemasukan'] ?? 0),
                                        totalExpense:
                                            rupiah(kas['pengeluaran'] ?? 0),
                                        remainingFunds: rupiah((int.parse(
                                                    kas['pemasukan'] ?? '0') -
                                                int.parse(
                                                    kas['pengeluaran'] ?? '0'))
                                            .toString())),
                                  ],
                                );
                              },
                            )
                          : Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: const Text(
                                  "Belum ada data KAS di tahun yang dipilih."),
                            ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  );
                }
              }),
            ),
    );
  }

  List<String> generateYearList() {
    int currentYear = DateTime.now().year;
    List<String> years = [];

    for (int i = currentYear - 10; i <= currentYear; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
