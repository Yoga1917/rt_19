import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PengaduanPage extends StatefulWidget {
  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String? jabatan;
  List pengaduanData = [];
  List<dynamic> filteredPengaduanList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadJabatan();
    _fetchPengaduan();
  }

  void _loadJabatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      jabatan = prefs.getString('jabatan');
    });
  }

  Future<void> _fetchPengaduan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jabatan = prefs.getString('jabatan');

    try {
      if (jabatan == "Ketua RT") {
        final kinerjaResponse = await http.get(Uri.parse(
            "https://pexadont.agsa.site/api/pengaduan/jenis/Kinerja"));
        final fasilitasResponse = await http.get(Uri.parse(
            "https://pexadont.agsa.site/api/pengaduan/jenis/Fasilitas"));
        final kinerjaData = json.decode(kinerjaResponse.body)['data'];
        final fasilitasData = json.decode(fasilitasResponse.body)['data'];

        // gabung data
        List datas = [...kinerjaData, ...fasilitasData];
        // order by tgl
        datas.sort((a, b) => b['tgl'].compareTo(a['tgl']));

        setState(() {
          pengaduanData = datas;
        });
      } else if (jabatan == "Sekretaris") {
        final kegiatanResponse = await http.get(Uri.parse(
            "https://pexadont.agsa.site/api/pengaduan/jenis/Kegiatan"));
        final kegiatanData = json.decode(kegiatanResponse.body)['data'];

        kegiatanData.sort((a, b) => b['tgl'].compareTo(a['tgl']));

        setState(() {
          pengaduanData = kegiatanData;
        });
      } else if (jabatan == "Bendahara") {
        final keuanganResponse = await http.get(Uri.parse(
            "https://pexadont.agsa.site/api/pengaduan/jenis/Keuangan"));
        final keuanganData = json.decode(keuanganResponse.body)['data'];

        keuanganData.sort((a, b) => b['tgl'].compareTo(a['tgl']));

        setState(() {
          pengaduanData = keuanganData;
        });
      } else if (jabatan == "Kordinator Kebersihan") {
        final kebersihanResponse = await http.get(Uri.parse(
            "https://pexadont.agsa.site/api/pengaduan/jenis/Kebersihan"));
        final kebersihanData = json.decode(kebersihanResponse.body)['data'];

        kebersihanData.sort((a, b) => b['tgl'].compareTo(a['tgl']));

        setState(() {
          pengaduanData = kebersihanData;
        });
      } else if (jabatan == "Kordinator Keamanan") {
        final keamananResponse = await http.get(Uri.parse(
            "https://pexadont.agsa.site/api/pengaduan/jenis/Keamanan"));
        final keamananData = json.decode(keamananResponse.body)['data'];

        keamananData.sort((a, b) => b['tgl'].compareTo(a['tgl']));

        setState(() {
          pengaduanData = keamananData;
        });
      }
    } catch (e) {
      print("Terjadi kesalahan mengambil data pengaduan");
    }
  }

  void _balasPengaduan(String id_pengaduan, String balasan) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://pexadont.agsa.site/api/pengaduan/balas'));
    request.fields['id_pengaduan'] = id_pengaduan;
    request.fields['balasan'] = balasan;

    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);
    var response = jsonDecode(responseData.body);

    if (response["status"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Balasan pengaduan berhasil dikirim')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PengaduanPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim balasan pengaduan")),
      );
    }
  }

  void searchPengaduan(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredPengaduanList = pengaduanData;
        isSearching = false;
      });
      return;
    }

    final suggestions = pengaduanData.where((pengaduan) {
      final pengaduanName = pengaduan['nama'].toLowerCase();
      return pengaduanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredPengaduanList = suggestions;
      filteredPengaduanList.sort((a, b) {
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
          'Pengaduan Warga',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Column();
        } else {
          return Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Menampilkan pengaduan untuk ',
                      ),
                      TextSpan(
                        text: jabatan ?? "-",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: '.',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: TextField(
                  controller: searchController,
                  cursorColor: Color(0xff30C083),
                  decoration: InputDecoration(
                    hintText: 'Cari data Pengaduan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff30C083)),
                    ),
                    prefixIcon: GestureDetector(
                      onTap: () {
                        searchPengaduan(searchController.text);
                      },
                      child: Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Text('Total Pengaduan : ${pengaduanData.length} Pengaduan'),
              SizedBox(
                height: 20,
              ),
              pengaduanData.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: 150),
                        Center(
                          child: Text(
                            "Belum ada data pengaduan.",
                          ),
                        ),
                      ],
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: pengaduanData.length,
                          itemBuilder: (context, index) {
                            final pengaduan = pengaduanData[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 20),
                                          Text(
                                            'Pengaduan ${pengaduan['jenis']}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month,
                                                  color: Colors.black),
                                              SizedBox(width: 5),
                                              Text(
                                                pengaduan['tgl'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            pengaduan['nama'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            pengaduan['nik'],
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Mengadukan :',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    pengaduan['foto'] == null
                                        ? SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 10,
                                                bottom: 20),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                'https://pexadont.agsa.site/uploads/pengaduan/${pengaduan['foto']}',
                                                // fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text(
                                        pengaduan['isi'],
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    pengaduan['balasan'] == null
                                        ? GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  TextEditingController
                                                      messageController =
                                                      TextEditingController();

                                                  return AlertDialog(
                                                    title: Text('Ketik Pesan'),
                                                    content: TextField(
                                                      controller:
                                                          messageController,
                                                      cursorColor:
                                                          Color(0xff30C083),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Masukkan pesan...",
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xff30C083)),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          String message =
                                                              messageController
                                                                  .text;
                                                          _balasPengaduan(
                                                              pengaduan[
                                                                  'id_pengaduan'],
                                                              message);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Kirim',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xff30C083),
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Batal',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xff30C083),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
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
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Balas',
                                                  style: TextStyle(
                                                    color: Color(0xff30C083),
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            margin:
                                                const EdgeInsets.only(top: 20),
                                            child: Text(
                                                "Balasan : ${pengaduan['balasan']}"),
                                          ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
            ],
          );
        }
      }),
    );
  }
}
