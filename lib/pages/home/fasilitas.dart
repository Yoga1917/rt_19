import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rt_19/pages/fasilitas/edit_fasilitas.dart';
import 'package:rt_19/pages/fasilitas/input_fasilitas.dart';
import 'package:http/http.dart' as http;
import 'package:rt_19/pages/halaman_utama/home.dart';

class FasilitasPage extends StatefulWidget {
  @override
  State<FasilitasPage> createState() => _FasilitasPageState();
}

class _FasilitasPageState extends State<FasilitasPage> {
  List<dynamic> fasilitasList = [];
  List<dynamic> filteredFasilitasList = [];
  int totalFasilitas = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = true;
  String? aksiBy;

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
                  'id_fasilitas': item['id_fasilitas'],
                  'nama': item['nama'],
                  'jml': item['jml'],
                  'status': item['status'],
                  'foto': item['foto']
                })
            .toList();
        filteredFasilitasList = fasilitasList;
        isLoading = false;
        totalFasilitas = fasilitasList.length;
        aksiBy = data['aksiBy'];
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  void searchFasilitas(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredFasilitasList = fasilitasList;
        isSearching = false;
      });
      return;
    }

    final suggestions = fasilitasList.where((fasilitas) {
      final fasilitasName = fasilitas['nama'].toLowerCase();
      return fasilitasName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredFasilitasList = suggestions;
      filteredFasilitasList.sort((a, b) {
        if (a['nama'].toLowerCase() == cleanedQuery) return -1;
        if (b['nama'].toLowerCase() == cleanedQuery) return 1;
        return a['nama'].compareTo(b['nama']);
      });
    });
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff30C083)),
              ),
            )
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
                            controller: searchController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              hintText: 'Cari Fasilitas...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Color(0xff30C083)),
                              ),
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  searchFasilitas(searchController.text);
                                },
                                child: Icon(Icons.search, color: Colors.black),
                              ),
                              suffixIcon: isSearching
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: Colors.black),
                                      onPressed: () {
                                        searchController.clear();
                                        searchFasilitas('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: searchFasilitas,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('Total Fasilitas : $totalFasilitas Fasilitas'),
                  SizedBox(
                    height: 20,
                  ),
                  if (filteredFasilitasList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: Text(
                        'Data tidak ditemukan.',
                      ),
                    ),
                  if (filteredFasilitasList.isNotEmpty)
                    for (var fasilitas in filteredFasilitasList)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                      fasilitas['nama'],
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
                                    SizedBox(height: 10),
                                    Text(
                                      'Terakhir diedit oleh :\n${aksiBy}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditFasilitasPage(
                                              fasilitas['id_fasilitas'].toString(),
                                              fasilitas['nama'].toString(),
                                              fasilitas['jml'].toString(),
                                              fasilitas['status'].toString()
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xff30C083),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                  SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
}
