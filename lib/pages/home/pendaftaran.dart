import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendaftaranPage extends StatefulWidget {
  @override
  _PendaftaranPageState createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage> {
  List<dynamic> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://pexadont.agsa.site/api/warga'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          // Filter data dengan status "0"
          data = jsonData['data'].where((item) => item['status'] == "0").toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data dari server')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _acceptWarga(nik, nama, tgl_lahir, jenis_kelamin, no_rumah, no_wa) async {
    final String apiUrl = 'https://pexadont.agsa.site/api/warga/update/${nik}';

    final Map<String, dynamic> requestBody = {
      'nik': nik,
      'nama': nama,
      'tgl_lahir': tgl_lahir,
      'jenis_kelamin': jenis_kelamin,
      'no_rumah': no_rumah,
      'no_wa': no_wa,
      'status': "1",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pendaftaran warga berhasil diterima.")),
        );

        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menerima pendaftaran, coba ulangi beberapa saat.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal, coba ulangi beberapa saat.")),
      );
      print('Error occurred: $e');
    }
  }

  Future<void> _tolakWarga(String nik) async {
    final url = 'https://pexadont.agsa.site/api/warga/delete/${nik}';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pendaftaran warga ditolak.")),
    );
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pendaftaran Akun',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Center(child: Text('Tidak ada data pendaftaran.'))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: Colors.grey),
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
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://pexadont.agsa.site/uploads/warga/${item['foto']}',
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Column(
                                children: [
                                  Text(
                                    item['nama'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('NIK: ${item['nik']}'),
                                  Text('Tanggal Lahir: ${item['tgl_lahir']}'),
                                  Text('Jenis Kelamin: ${item['jenis_kelamin']}'),
                                  Text('No. Rumah: ${item['no_rumah']}'),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _tolakWarga(item['nik']);
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xff30C083),
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: const Text(
                                        'Tolak',
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
                                GestureDetector(
                                  onTap: () {
                                    _acceptWarga(item['nik'], item['nama'], item['tgl_lahir'], item['jenis_kelamin'], item['no_rumah'], item['no_wa']);
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
                                        'Terima',
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
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
