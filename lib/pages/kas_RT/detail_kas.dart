import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indonesia/indonesia.dart';
import 'package:intl/intl.dart';
import 'package:rt_19/pages/home/kas.dart';
import 'package:rt_19/widget/toggle_tabs.dart';

class DetailKASPage extends StatefulWidget {
  final String id_kas;
  const DetailKASPage(this.id_kas);

  @override
  State<DetailKASPage> createState() => _DetailKASPageState();
}

class _DetailKASPageState extends State<DetailKASPage> {
  bool isPemasukanSelected = true;
  List<dynamic> pemasukanData = [];
  List<dynamic> pengeluaranData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _getKasPemasukan();
    _getKasPengeluaran();
  }

  void _getKasPemasukan() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://pexadont.agsa.site/api/kas/pemasukan?id_kas=${widget.id_kas}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          pemasukanData = responseData['data'];
          isLoading = false;
        });
      } else {
        showSnackbar('Gagal memuat data pemasukan');
        isLoading = false;
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
      isLoading = false;
    }
  }

  void _getKasPengeluaran() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://pexadont.agsa.site/api/kas/pengeluaran?id_kas=${widget.id_kas}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          pengeluaranData = responseData['data'];
          isLoading = false;
        });
      } else {
        showSnackbar('Gagal memuat data pengeluaran');
        isLoading = false;
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
      isLoading = false;
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
          'Detail Kas RT',
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
              MaterialPageRoute(builder: (context) => KasPage()),
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
          : LayoutBuilder(
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
                      Text(
                        isPemasukanSelected
                            ? 'Detail Pemasukan'
                            : 'Detail Pengeluaran',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: isPemasukanSelected
                            ? pemasukanData.isEmpty
                                ? Center(
                                    child: Text("Tidak ada data pemasukan dibulan ini."))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: pemasukanData.length,
                                    itemBuilder: (context, index) {
                                      final pemasukan = pemasukanData[index];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 20,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          '${formatDate(pemasukan['tgl'])}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      rupiah(
                                                          pemasukan['jumlah']),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Didapatkan dari :',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                pemasukan['keterangan'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 15),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                            : pengeluaranData.isEmpty
                                ? Center(
                                    child: Text(
                                        "Tidak ada data pengeluaran di bulan ini."))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: pengeluaranData.length,
                                    itemBuilder: (context, index) {
                                      final pengeluaran =
                                          pengeluaranData[index];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 20,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          '${formatDate(pengeluaran['tgl'])}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      rupiah(pengeluaran[
                                                          'jumlah']),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Digunakan :',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              pengeluaran['foto'] != null
                                                  ? Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 10),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            child:
                                                                Image.network(
                                                              "https://pexadont.agsa.site/uploads/pengeluaran_kas/${pengeluaran['foto']}",
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(height: 5),
                                              Text(
                                                pengeluaran['keterangan'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }
}
