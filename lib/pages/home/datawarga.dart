import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataWargaPage extends StatefulWidget {
  @override
  _DataWargaPageState createState() => _DataWargaPageState();
}

class _DataWargaPageState extends State<DataWargaPage> {
  List<dynamic> wargaList = [];
  int totalWarga = 0;

  @override
  void initState() {
    super.initState();
    fetchWargaData();
  }

  Future<void> fetchWargaData() async {
    final response = await http.get(Uri.parse('https://pexadont.agsa.site/api/warga'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        wargaList = data['data'].where((item) => item['status'] == "1").toList();
        totalWarga = wargaList.length;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _hapusWarga(String nik) async {
    final url = 'https://pexadont.agsa.site/api/warga/delete/${nik}';
    await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data warga dihapus.")),
    );

    fetchWargaData();
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: TextField(
                  cursorColor: Color(0xff30C083),
                  decoration: InputDecoration(
                    hintText: 'Cari data warga...',
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
              Text('Total Warga : $totalWarga Warga'),
              SizedBox(
                height: 30,
              ),
              if (wargaList.isNotEmpty) ...[
                for (var warga in wargaList)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.grey),
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
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                (warga['foto'] != null) ? 'https://pexadont.agsa.site/uploads/warga/${warga['foto']}' : 'https://placehold.co/300x300.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  warga['nama'] ?? 'Unknown Name',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Nik : ${warga['nik']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Tanggal Lahir : ${warga['tgl_lahir']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Jenis Kelamin : ${warga['jenis_kelamin']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'No. Rumah : ${warga['no_rumah']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    _hapusWarga(warga['nik']);
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff30C083),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              SizedBox(
                height: 50,
              ),
            ],
          );
        }),
      ),
    );
  }
}