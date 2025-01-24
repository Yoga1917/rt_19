import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaduanPage extends StatefulWidget {
  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String? jabatan;
  int totalPengaduan = 0;
  List pengaduanData = [];
  List<dynamic> filteredPengaduanList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;
  String formattedTotalPengaduan = '';

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

    setState(() {
      isLoading = true;
    });

    try {
      final endpoint = jabatan == "Ketua RT"
          ? ["Kinerja", "Fasilitas"]
          : [
              jabatan == "Sekretaris"
                  ? "Kegiatan"
                  : jabatan == "Bendahara"
                      ? "Keuangan"
                      : jabatan == "Kordinator Kebersihan"
                          ? "Kebersihan"
                          : "Keamanan"
            ];

      List combinedData = [];
      for (var jenis in endpoint) {
        final response = await http.get(
            Uri.parse("https://pexadont.agsa.site/api/pengaduan/jenis/$jenis"));
        final data = json.decode(response.body)['data'];
        combinedData.addAll(data);
      }

      combinedData.sort((a, b) => b['tgl'].compareTo(a['tgl']));

      combinedData = combinedData.map((item) {
        item['foto_warga'] = item['foto_warga'] != null
            ? "https://pexadont.agsa.site/uploads/warga/${item['foto_warga']}"
            : null;

        item['fotoAksiBy'] = item['fotoAksiBy'] != null
            ? "https://pexadont.agsa.site/uploads/warga/${item['fotoAksiBy']}"
            : null;

        return item;
      }).toList();

      setState(() {
        pengaduanData = combinedData;
        filteredPengaduanList = combinedData;
        totalPengaduan = combinedData.length;

        formattedTotalPengaduan =
            NumberFormat.decimalPattern('id').format(totalPengaduan);

        isLoading = false;
      });
    } catch (e, stacktrace) {
      print("Terjadi kesalahan mengambil data pengaduan: $e");
      print(stacktrace);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _balasPengaduan(String id_pengaduan, String balasan) async {
    if (balasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pesan balasan tidak boleh kosong!")),
      );
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://pexadont.agsa.site/api/pengaduan/balas'));
    request.fields['id_pengaduan'] = id_pengaduan;
    request.fields['balasan'] = balasan;

    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);
    var response = jsonDecode(responseData.body);

    if (response["status"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Balasan pengaduan berhasil dikirim!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PengaduanPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim balasan pengaduan!")),
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
      final pengaduanName = pengaduan['jenis'].toLowerCase();
      return pengaduanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredPengaduanList = suggestions;
      filteredPengaduanList.sort((a, b) {
        if (a['jenis'].toLowerCase() == cleanedQuery) return -1;
        if (b['jenis'].toLowerCase() == cleanedQuery) return 1;
        return a['jenis'].compareTo(b['jenis']);
      });
    });
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
          'Pengaduan Warga',
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
          : GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: LayoutBuilder(builder: (context, constraints) {
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: TextField(
                          controller: searchController,
                          cursorColor: Color(0xff30C083),
                          decoration: InputDecoration(
                            hintText: 'Cari Jenis Pengaduan...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xff30C083)),
                            ),
                            prefixIcon: GestureDetector(
                              onTap: () {
                                searchPengaduan(searchController.text);
                              },
                              child: Icon(Icons.search),
                            ),
                            suffixIcon: isSearching
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      searchPengaduan('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: searchPengaduan,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Pengaduan : '),
                          Text(
                            NumberFormat.decimalPattern('id')
                                .format(totalPengaduan),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' Pengaduan'),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: filteredPengaduanList.isEmpty
                            ? Center(
                                child: Text(
                                  "Data tidak ditemukan.",
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredPengaduanList.length,
                                itemBuilder: (context, index) {
                                  final pengaduan =
                                      filteredPengaduanList[index];
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
                                            color:
                                                Colors.black.withOpacity(0.2),
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
                                                    Icon(
                                                      Icons.calendar_month,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      '${formatDate(pengaduan['tgl'])}',
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Dialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child: Image
                                                                    .network(
                                                                  pengaduan[
                                                                      'foto_warga'],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(
                                                          pengaduan[
                                                              'foto_warga'],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          pengaduan['nama'],
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          pengaduan['nik'],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Mengadukan :',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          pengaduan['foto'] == null
                                              ? SizedBox(height: 5)
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.network(
                                                      'https://pexadont.agsa.site/uploads/pengaduan/${pengaduan['foto']}',
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(
                                              pengaduan['isi'],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          pengaduan['balasan'] == null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        TextEditingController
                                                            messageController =
                                                            TextEditingController();

                                                        return AlertDialog(
                                                          title: Text(
                                                              'Ketik Pesan'),
                                                          content: TextField(
                                                            controller:
                                                                messageController,
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
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                'Kirim',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xff30C083),
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                'Batal',
                                                                style:
                                                                    TextStyle(
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
                                                        color:
                                                            Color(0xff30C083),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: const Text(
                                                        'Balas',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff30C083),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Balasan Oleh',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        5),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Dialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                        child: Image
                                                                            .network(
                                                                          '${pengaduan['fotoAksiBy']}',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              double.infinity,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 10,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                  '${pengaduan['fotoAksiBy']}',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            '${pengaduan['aksiBy']} :',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(pengaduan['balasan'])
                                                  ],
                                                ),
                                          SizedBox(
                                            height: 20,
                                          ),
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
              }),
            ),
    );
  }
}
