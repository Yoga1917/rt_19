import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rt_19/pages/pemberitahuan/input_pemberitahuan.dart';
import 'package:http/http.dart' as http;

class PemberitahuanPage extends StatefulWidget {
  @override
  State<PemberitahuanPage> createState() => _PemberitahuanPageState();
}

class _PemberitahuanPageState extends State<PemberitahuanPage> {
  List<dynamic> pemberitahuanList = [];
  List<dynamic> filteredPemberitahuanList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPemberitahuanData();
  }

  Future<void> fetchPemberitahuanData() async {
    final response = await http
        .get(Uri.parse('https://pexadont.agsa.site/api/pemberitahuan'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pemberitahuanList = (data['data'] as List)
            .map((item) => {
                  'pemberitahuan': item['pemberitahuan'],
                  'deskripsi': item['deskripsi'],
                  'tgl': item['tgl'],
                  'file': item['file']
                })
            .toList();
        filteredPemberitahuanList = pemberitahuanList;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  void searchPemberitahuan(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredPemberitahuanList = pemberitahuanList;
        isSearching = false;
      });
      return;
    }

    final suggestions = pemberitahuanList.where((pemberitahuan) {
      final pemberitahuanName = pemberitahuan['pemberitahuan'].toLowerCase();
      return pemberitahuanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredPemberitahuanList = suggestions;
      filteredPemberitahuanList.sort((a, b) {
        if (a['pemberitahuan'].toLowerCase() == cleanedQuery) return -1;
        if (b['pemberitahuan'].toLowerCase() == cleanedQuery) return 1;
        return a['pemberitahuan'].compareTo(b['pemberitahuan']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pemberitahuan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
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
                                    builder: (context) =>
                                        InputPemberitahuanPage()),
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
                                      'Beritahu',
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
                              controller: searchController,
                              cursorColor: Color(0xff30C083),
                              decoration: InputDecoration(
                                hintText: 'Cari Pemberitahuan...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Color(0xff30C083)),
                                ),
                                suffixIcon: isSearching
                                    ? IconButton(
                                        icon: Icon(Icons.clear,
                                            color: Colors.black),
                                        onPressed: () {
                                          searchController.clear();
                                          searchPemberitahuan('');
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: searchPemberitahuan,
                            ),
                          ),
                        ]),
                  ),
                  if (filteredPemberitahuanList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff30C083),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (filteredPemberitahuanList.isNotEmpty)
                    for (var pemberitahuan in filteredPemberitahuanList)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Container(
                          width: double.infinity,
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
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        pemberitahuan['pemberitahuan'],
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month_outlined),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            pemberitahuan['tgl'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
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
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            pemberitahuan['deskripsi'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () async {},
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff30C083),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.download,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Download',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
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
                      ),
                ],
              ),
            ),
    );
  }
}
