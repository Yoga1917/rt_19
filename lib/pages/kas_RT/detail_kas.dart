import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indonesia/indonesia.dart';
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
          : SingleChildScrollView(
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 30),
                                    pemasukanData.isEmpty
                                        ? const Text("Belum ada data pemasukan")
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: pemasukanData.length,
                                            itemBuilder: (context, index) {
                                              final pemasukan =
                                                  pemasukanData[index];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 20),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                height: 20),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .calendar_month,
                                                                    color: Colors
                                                                        .black),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                  pemasukan[
                                                                          'tgl'] ??
                                                                      "28 Desember 2024",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Text(
                                                              rupiah(pemasukan[
                                                                  'jumlah']),
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        pemasukan['keterangan'],
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
                                              );
                                            }),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text(
                                      'Detail Pengeluaran',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 30),
                                    pengeluaranData.isEmpty
                                        ? const Text(
                                            "Belum ada data pengeluaran")
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: pengeluaranData.length,
                                            itemBuilder: (context, index) {
                                              final pengeluaran =
                                                  pengeluaranData[index];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 20),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                height: 20),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .calendar_month,
                                                                    color: Colors
                                                                        .black),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                  pengeluaran[
                                                                          'tgl'] ??
                                                                      '28 Desember 2024',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Text(
                                                              rupiah(pengeluaran[
                                                                  'jumlah']),
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      pengeluaran['foto'] !=
                                                              null
                                                          ? Column(
                                                              children: [
                                                                Text(
                                                                  'Digunakan :',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    child: Image
                                                                        .network(
                                                                      "https://pexadont.agsa.site/uploads/pengeluaran_kas/${pengeluaran['foto']}",
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        pengeluaran[
                                                            'keterangan'],
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
                                              );
                                            })
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
