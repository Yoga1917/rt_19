import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indonesia/indonesia.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:rt_19/pages/kas_RT/detail_kas.dart';
import 'package:rt_19/pages/kas_RT/input_kas.dart';
import 'package:rt_19/widget/kartu_laporan.dart';
import 'package:rt_19/widget/kartu_total_laporan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KasPage extends StatefulWidget {
  @override
  State<KasPage> createState() => _KasPageState();
}

class _KasPageState extends State<KasPage> {
  String? selectedYear;
  List<dynamic> kasData = [];
  List<dynamic> kasSaldo = [];
  bool isLoading = true;
  int saldoKas = 0;
  int sisaDana = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  String? id_pengurus;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toString();
    _loadIdPengurus();
    _fetchKas();
    _fetchAllKas();
  }

  Future<String?> getIdPengurus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_pengurus');
  }

  Future<void> _loadIdPengurus() async {
    id_pengurus = await getIdPengurus();
    setState(() {});
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

          perhitunganTotal();
          isLoading = false;
        });
      } else {
        showSnackbar('Gagal memuat data kas');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _fetchAllKas() async {
    try {
      String url = 'https://pexadont.agsa.site/api/kas';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          kasSaldo = responseData['data'];
          kasSaldo.sort((a, b) =>
              int.parse(b['id_kas']).compareTo(int.parse(a['id_kas'])));

          _saldoKas();
        });
      } else {
        showSnackbar('Gagal memuat data kas');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _saldoKas() {
    for (var kas in kasSaldo) {
      int pemasukan =
          kas['pemasukan'] != null ? int.parse(kas['pemasukan']) : 0;
      int pengeluaran =
          kas['pengeluaran'] != null ? int.parse(kas['pengeluaran']) : 0;

      saldoKas += (pemasukan - pengeluaran);
    }
  }

  void perhitunganTotal() {
    totalIncome = 0;
    totalExpense = 0;
    sisaDana = 0;

    // Menghitung total pemasukan dan pengeluaran serta sisa dana hanya untuk tahun yang dipilih
    for (var kas in kasData) {
      if (kas['tahun'] == selectedYear) {
        // Hanya untuk tahun yang dipilih
        int pemasukan =
            kas['pemasukan'] != null ? int.parse(kas['pemasukan']) : 0;
        int pengeluaran =
            kas['pengeluaran'] != null ? int.parse(kas['pengeluaran']) : 0;

        totalIncome += pemasukan;
        totalExpense += pengeluaran;
        sisaDana += (pemasukan - pengeluaran); // Hanya untuk tahun yang dipilih
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _publishKas(String id_kas) async {
    if (id_pengurus == null) {
      showSnackbar('ID Pengurus tidak ditemukan. Silakan login ulang.');
      return;
    }

    print('Mengirim request: id_kas=$id_kas, id_pengurus=$id_pengurus');

    try {
      final response = await http.post(
        Uri.parse('https://pexadont.agsa.site/api/kas/publish/simpan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_kas': id_kas,
          'id_pengurus': id_pengurus, 
        }),
      );

      if (response.statusCode == 200) {
        showSnackbar('Berhasil Publish KAS');
        Navigator.of(context).pop();
        _fetchKas();
      } else {
        print('Response body: ${response.body}');
        print(response.statusCode);
        showSnackbar('Gagal memuat data kas!');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
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
          : LayoutBuilder(builder: (context, constraints) {
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              value: selectedYear,
                              items: generateYearList()
                                  .map<DropdownMenuItem<String>>((String year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Text(
                                      year,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
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
                              itemHeight: null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saldo Kas : ',
                        ),
                        Text(
                          '${rupiah(saldoKas)},-',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: kasData.length > 0
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: kasData.length,
                                    itemBuilder: (context, index) {
                                      final kas =
                                          kasData.reversed.toList()[index];
                                      return KartuLaporan(
                                        month:
                                            kas['bulan'] + " " + kas['tahun'],
                                        fotoAksiBy: '${kas['fotoAksiBy']}',
                                        aksiBy: '${kas['aksiBy']}',
                                        income: rupiah(kas['pemasukan'] ?? 0),
                                        expense:
                                            rupiah(kas['pengeluaran'] ?? 0),
                                        publish: kas['publish'],
                                        onDetail: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailKASPage(
                                                        kas['id_kas'])),
                                          );
                                        },
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
                                                        color:
                                                            Color(0xff30C083),
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
                                                              Color(
                                                                  0xff30C083))),
                                                  child: const Text(
                                                    "Publish",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () => _publishKas(
                                                      kas['id_kas']),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  if (kasData.isNotEmpty)
                                    TotalCard(
                                      totalIncome:
                                          rupiah(totalIncome.toString()),
                                      totalExpense:
                                          rupiah(totalExpense.toString()),
                                      remainingFunds:
                                          rupiah(sisaDana.toString()),
                                    ),
                                  SizedBox(height: 30)
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                  "Tidak ada data KAS di tahun yang dipilih."),
                            ),
                    ),
                  ],
                );
              }
            }),
    );
  }

  List<String> generateYearList() {
    int currentYear = DateTime.now().year;
    List<String> years = [];

    for (int i = 2014; i <= currentYear; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
