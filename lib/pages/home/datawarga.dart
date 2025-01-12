import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:rt_19/widget/toggle_tabs.dart';

class DataWargaPage extends StatefulWidget {
  @override
  _DataWargaPageState createState() => _DataWargaPageState();
}

class _DataWargaPageState extends State<DataWargaPage> {
  bool isDataAktifSelected = true;
  List<dynamic> wargaList = [];
  List<dynamic> filteredWargaList = [];
  List<dynamic> wargaInactiveList = [];
  List<dynamic> filteredWargaInactiveList = [];

  int totalWarga = 0;
  int totalWargaInactive = 0;

  TextEditingController searchController = TextEditingController();
  TextEditingController searchInactiveController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;
  bool loadingUpdate = false;

  @override
  void initState() {
    super.initState();
    fetchWargaData();
  }

  Future<void> fetchWargaData() async {
    final response =
        await http.get(Uri.parse('https://pexadont.agsa.site/api/warga'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        wargaList =
            data['data'].where((item) => item['status'] == "1").toList();
        filteredWargaList = wargaList;
        wargaInactiveList =
            data['data'].where((item) => item['status'] == "2").toList();
        filteredWargaInactiveList = wargaInactiveList;

        totalWarga = wargaList.length;
        totalWargaInactive = wargaInactiveList.length;

        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void searchWarga(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredWargaList = wargaList;
        isSearching = false;
      });
      return;
    }

    final suggestions = wargaList.where((warga) {
      final wargaName = warga['nama'].toLowerCase();
      return wargaName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredWargaList = suggestions;
      filteredWargaList.sort((a, b) {
        if (a['nama'].toLowerCase() == cleanedQuery) return -1;
        if (b['nama'].toLowerCase() == cleanedQuery) return 1;
        return a['nama'].compareTo(b['nama']);
      });
    });
  }

  void searchWargaInactive(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredWargaInactiveList = wargaInactiveList;
        isSearching = false;
      });
      return;
    }

    final suggestions = wargaInactiveList.where((warga) {
      final wargaName = warga['nama'].toLowerCase();
      return wargaName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredWargaInactiveList = suggestions;
      filteredWargaInactiveList.sort((a, b) {
        if (a['nama'].toLowerCase() == cleanedQuery) return -1;
        if (b['nama'].toLowerCase() == cleanedQuery) return 1;
        return a['nama'].compareTo(b['nama']);
      });
    });
  }

  void _updateStatus(
      nik, nama, tglLahir, jenisKelamin, noRumah, noWa, status) async {
    setState(() => loadingUpdate = true);

    var request = http.MultipartRequest('POST',
        Uri.parse('https://pexadont.agsa.site/api/warga/update/${nik}'));
    request.fields['nik'] = nik;
    request.fields['nama'] = nama;
    request.fields['tgl_lahir'] = tglLahir;
    request.fields['jenis_kelamin'] = jenisKelamin;
    request.fields['no_rumah'] = noRumah;
    request.fields['no_wa'] = noWa;
    request.fields['status'] = status;

    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);
    var response = jsonDecode(responseData.body);

    print(response);

    if (response["status"] == 202) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['data'])),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DataWargaPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update status warga")),
      );
    }

    setState(() => loadingUpdate = false);
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
          'Data Warga',
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
          : Column(
              children: [
                // Tidak discroll: Text total warga dan ToggleTabs
                SizedBox(height: 20),
                Text('Total Warga : ${totalWarga + totalWargaInactive} Warga'),
                SizedBox(height: 20),
                ToggleTabs(
                  isSelectedLeft: isDataAktifSelected,
                  leftLabel: '    Aktif    ',
                  rightLabel: 'Non Aktif',
                  onToggle: (value) {
                    setState(() {
                      isDataAktifSelected = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                // Tidak discroll: Fitur pencarian
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: TextField(
                    controller: isDataAktifSelected
                        ? searchController
                        : searchInactiveController,
                    decoration: InputDecoration(
                      hintText: isDataAktifSelected
                          ? 'Cari data warga Aktif...'
                          : 'Cari data warga Non Aktif...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff30C083)),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: isSearching
                          ? IconButton(
                              icon:
                                  const Icon(Icons.clear, color: Colors.black),
                              onPressed: () {
                                isDataAktifSelected
                                    ? searchController.clear()
                                    : searchInactiveController.clear();
                                searchWarga('');
                                searchWargaInactive('');
                              },
                            )
                          : null,
                    ),
                    onChanged:
                        isDataAktifSelected ? searchWarga : searchWargaInactive,
                  ),
                ),
                Text(isDataAktifSelected
                    ? 'Total Warga Aktif : $totalWarga Warga'
                    : 'Total Warga Non Aktif : $totalWargaInactive Warga'),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: isDataAktifSelected
                        ? (filteredWargaList.isEmpty
                            ? Center(child: Text("Data tidak ditemukan."))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredWargaList.length,
                                itemBuilder: (context, index) {
                                  final warga = filteredWargaList[index];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                (warga['foto'] != null)
                                                    ? 'https://pexadont.agsa.site/uploads/warga/${warga['foto']}'
                                                    : 'https://placehold.co/300x300.png',
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
                                                  warga['nama'] ??
                                                      'Unknown Name',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Nik : ${warga['nik']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Tanggal Lahir : ${formatDate(warga['tgl_lahir'])}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Jenis Kelamin : ${warga['jenis_kelamin']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'No. Rumah : ${warga['no_rumah']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                SizedBox(height: 20),
                                                GestureDetector(
                                                  onTap: () => _updateStatus(
                                                    warga['nik'],
                                                    warga['nama'],
                                                    warga['tgl_lahir'],
                                                    warga['jenis_kelamin'],
                                                    warga['no_rumah'],
                                                    warga['no_wa'],
                                                    "2",
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xff30C083),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Text(
                                                        loadingUpdate
                                                            ? 'Update...'
                                                            : 'Aktif      ',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 30),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }))
                        : (filteredWargaInactiveList.isEmpty
                            ? Center(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text("Data tidak ditemukan.")))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredWargaInactiveList.length,
                                itemBuilder: (context, index) {
                                  final warga =
                                      filteredWargaInactiveList[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                (warga['foto'] != null)
                                                    ? 'https://pexadont.agsa.site/uploads/warga/${warga['foto']}'
                                                    : 'https://placehold.co/300x300.png',
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
                                                  warga['nama'] ??
                                                      'Unknown Name',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Nik : ${warga['nik']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Tanggal Lahir : ${warga['tgl_lahir']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Jenis Kelamin : ${warga['jenis_kelamin']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'No. Rumah : ${warga['no_rumah']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                SizedBox(height: 20),
                                                GestureDetector(
                                                  onTap: () => _updateStatus(
                                                    warga['nik'],
                                                    warga['nama'],
                                                    warga['tgl_lahir'],
                                                    warga['jenis_kelamin'],
                                                    warga['no_rumah'],
                                                    warga['no_wa'],
                                                    "1",
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.red[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Text(
                                                        loadingUpdate
                                                            ? 'Update...'
                                                            : 'Tidak Aktif',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 30),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })),
                  ),
                ),
                SizedBox(height: 20)
              ],
            ),
    );
  }
}
