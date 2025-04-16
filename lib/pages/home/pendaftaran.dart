import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:rt_19/pages/lokasi_maps.dart';
import 'package:rt_19/widget/toggle_tabs.dart';

class PendaftaranPage extends StatefulWidget {
  @override
  _PendaftaranPageState createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage> {
  List<dynamic> alldata = [];
  List<dynamic> dataKeluarga = [];
  List<dynamic> dataKepalaKeluarga = [];
  List<dynamic> dataAnggotaKeluarga = [];
  bool isLoading = true;
  bool isKepalaSelected = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final responseWarga =
          await http.get(Uri.parse('https://pexadont.agsa.site/api/warga'));

      final responseKeluarga =
          await http.get(Uri.parse('https://pexadont.agsa.site/api/keluarga'));

      if (responseWarga.statusCode == 200 &&
          responseKeluarga.statusCode == 200) {
        final jsonDataWarga = json.decode(responseWarga.body);
        final jsonDataKeluarga = json.decode(responseKeluarga.body);
        setState(() {
          dataKeluarga = jsonDataKeluarga['data'];

          // Filter data dengan status "0"
          alldata = jsonDataWarga['data']
              .where((item) => item['status'] == "0")
              .toList();

          dataKepalaKeluarga = alldata
              .where((item) => item['status_keluarga'] == "Kepala Keluarga")
              .map((warga) {
            var keluarga = dataKeluarga.firstWhere(
              (kel) => kel['no_kk'] == warga['no_kk'],
              orElse: () => {},
            );
            return Map<String, dynamic>.from(warga)..addAll(keluarga ?? {});
          }).toList();

          dataAnggotaKeluarga = alldata
              .where((item) =>
                  item['status_keluarga'] == "Anak" ||
                  item['status_keluarga'] == "Istri")
              .map((warga) {
            var keluarga = dataKeluarga.firstWhere(
              (kel) => kel['no_kk'] == warga['no_kk'],
              orElse: () => {},
            );
            return Map<String, dynamic>.from(keluarga ?? {})
              ..addAll(warga)
              ..['nik'] = warga['nik'];
          }).toList();
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

  Future<void> _acceptKeluarga(String no_kk) async {
    final String apiUrl =
        'https://pexadont.agsa.site/api/keluarga/terima?no_kk=${no_kk}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pendaftaran Keluarga berhasil diterima.")),
        );

        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal menerima pendaftaran, coba ulangi beberapa saat.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal, coba ulangi beberapa saat.")),
      );
      print('Error occurred: $e');
    }
  }

  Future<void> _tolakKeluarga(String no_kk) async {
    final url = 'https://pexadont.agsa.site/api/keluarga/tolak?no_kk=${no_kk}';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pendaftaran Keluarga ditolak.")),
      );

      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Gagal menolak pendaftaran, coba ulangi beberapa saat.")),
      );
    }
  }

  Future<void> _acceptWarga(String nik) async {
    final String apiUrl =
        'https://pexadont.agsa.site/api/warga/terima?nik=${nik}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pendaftaran warga berhasil diterima.")),
        );

        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal menerima pendaftaran, coba ulangi beberapa saat.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal, coba ulangi beberapa saat.")),
      );
      print('Error occurred: $e');
    }
  }

  Future<void> _tolakWarga(String nik, String keterangan) async {
    final url =
        'https://pexadont.agsa.site/api/warga/tolak?nik=${nik}&keterangan=${Uri.encodeComponent(keterangan)}';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pendaftaran warga ditolak.")),
      );

      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Gagal menolak pendaftaran, coba ulangi beberapa saat.")),
      );
    }
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

  Future<void> _showTolakDialog(String nik) async {
    final TextEditingController keteranganController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Keterangan Penolakan'),
          content: TextField(
            controller: keteranganController,
            decoration: InputDecoration(hintText: "Masukkan keterangan..."),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Kirim'),
              onPressed: () {
                String keterangan = keteranganController.text;
                if (keterangan.isNotEmpty) {
                  _tolakWarga(nik, keterangan);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Keterangan tidak boleh kosong')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
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
      body: Column(
        children: [
          SizedBox(height: 30),
          ToggleTabs(
              isSelectedLeft: isKepalaSelected,
              leftLabel: '  Kepala  ',
              rightLabel: "Anggota",
              onToggle: (value) {
                setState(() {
                  isKepalaSelected = value;
                });
              }),
          Expanded(
            child: isKepalaSelected
                ? isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff30C083),
                        ),
                      )
                    : dataKepalaKeluarga.isEmpty
                        ? Center(child: Text('Tidak ada data pendaftaran.'))
                        : ListView.builder(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, top: 30),
                            itemCount: dataKepalaKeluarga.length,
                            itemBuilder: (context, index) {
                              final item = dataKepalaKeluarga[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            'https://pexadont.agsa.site/uploads/warga/${item['foto']}',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          children: [
                                            Text(
                                              item['nama'] ?? '',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'NIK: ${item['nik']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'NO KK: ${item['no_kk']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Jenis Kelamin: ${item['jenis_kelamin']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tempat Lahir: ${item['tempat_lahir']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tanggal Lahir : ${formatDate(item['tgl_lahir'])}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Agama : ${item['agama']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Status Menikah : ${item['status_nikah']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Pendidikan : ${item['pendidikan'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Pekerjaan : ${item['pekerjaan'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Gaji : ${item['gaji'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Nama Ayah : ${item['nama_ayah'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Nama Ibu : ${item['nama_ibu'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Status Keluarga : ${item['status_keluarga']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Nomor Rumah : ${item['no_rumah']}',
                                            ),
                                            SizedBox(height: 2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Lokasi Maps : "),
                                                GestureDetector(
                                                  onTap: () {
                                                    // Pastikan item memiliki data latitude dan longitude dari keluarga
                                                    double lat = double.tryParse(
                                                            item['latitude'] ??
                                                                '0') ??
                                                        0;
                                                    double lng = double.tryParse(
                                                            item['longitude'] ??
                                                                '0') ??
                                                        0;

                                                    if (lat == 0 || lng == 0) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Lokasi tidak tersedia')),
                                                      );
                                                      return;
                                                    }

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LokasiMapPage(
                                                          latitude: lat,
                                                          longitude: lng,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Lihat Peta',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _showTolakDialog(item['nik']);
                                              _tolakKeluarga(item['no_kk']);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xff30C083),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Tolak   ',
                                                  style: TextStyle(
                                                    color: Color(0xff30C083),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _acceptWarga(item['nik']);
                                              _acceptKeluarga(item['no_kk']);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xff30C083),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xff30C083),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Terima',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
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
                          )
                : isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff30C083),
                        ),
                      )
                    : dataAnggotaKeluarga.isEmpty
                        ? Center(child: Text('Tidak ada data pendaftaran.'))
                        : ListView.builder(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, top: 30),
                            itemCount: dataAnggotaKeluarga.length,
                            itemBuilder: (context, index) {
                              final item = dataAnggotaKeluarga[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
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
                                        child: item['foto'] != null &&
                                                item['foto']
                                                    .toString()
                                                    .isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  'https://pexadont.agsa.site/uploads/warga/${item['foto']}',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Icon(Icons.error),
                                                ),
                                              )
                                            : SizedBox(),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          children: [
                                            Text(
                                              item['nama'] ?? '',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'NIK : ${item['nik']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'NO KK : ${item['no_kk']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Jenis Kelamin : ${item['jenis_kelamin']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tempat Lahir: ${item['tempat_lahir']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tanggal Lahir : ${formatDate(item['tgl_lahir'])}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Agama : ${item['agama']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Status Menikah : ${item['status_nikah']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Pendidikan : ${item['pendidikan'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Pekerjaan : ${item['pekerjaan'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Gaji : ${item['gaji'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Nama Ayah : ${item['nama_ayah'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Nama Ibu : ${item['nama_ibu'] ?? '-'}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Status Keluarga : ${item['status_keluarga']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Nomor Rumah : ${item['no_rumah']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Kepala Keluarga : ${item['kepala_keluarga']}',
                                            ),
                                            SizedBox(height: 2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Lokasi Maps : "),
                                                GestureDetector(
                                                  onTap: () {
                                                    // Pastikan item memiliki data latitude dan longitude dari keluarga
                                                    double lat = double.tryParse(
                                                            item['latitude'] ??
                                                                '0') ??
                                                        0;
                                                    double lng = double.tryParse(
                                                            item['longitude'] ??
                                                                '0') ??
                                                        0;

                                                    if (lat == 0 || lng == 0) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Lokasi tidak tersedia')),
                                                      );
                                                      return;
                                                    }

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LokasiMapPage(
                                                          latitude: lat,
                                                          longitude: lng,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Lihat Peta',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _showTolakDialog(item['nik']);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xff30C083),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Tolak   ',
                                                  style: TextStyle(
                                                    color: Color(0xff30C083),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _acceptWarga(item['nik']);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xff30C083),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xff30C083),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Terima',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
