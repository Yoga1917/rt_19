import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/home/kegiatan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputKegiatanPage extends StatefulWidget {
  @override
  State<InputKegiatanPage> createState() => _InputKegiatanPageState();
}

class _InputKegiatanPageState extends State<InputKegiatanPage> {
  final TextEditingController nikController = TextEditingController();

  final TextEditingController keteranganController = TextEditingController();
  File? _proposal;
  bool isLoading = false;
  bool validNIK = false;
  bool nikLoading = false;
  String? pelaksana;
  String? pilihBulan;
  String? pilihKegiatan;
  List<dynamic> rkbData = [];
  List<dynamic> _allWargaData = [];
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? rkbDataFiltered;

  @override
  void initState() {
    super.initState();
    _getRkb();
    _fetchAllWarga();
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _proposal = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Tidak ada file yang dipilih')));
    }
  }

  void _kirimData() async {
    if (isLoading) return;

    if (pilihKegiatan == null ||
        nikController.text.isEmpty ||
        keteranganController.text.isEmpty ||
        _proposal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harap Lengkapi semua data yang ada!')));
    } else {
      setState(() {
        isLoading = true;
      });

      _postKegiatan();
    }
  }

  void _postKegiatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_pengurus = prefs.getString('id_pengurus');

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://pexadont.agsa.site/api/kegiatan/simpan'));
    request.fields['nik'] = nikController.text;
    request.fields['nama_kegiatan'] = pilihKegiatan!;
    request.fields['keterangan'] = keteranganController.text;
    request.fields['id_pengurus'] = id_pengurus!;

    if (_proposal != null) {
      request.files
          .add(await http.MultipartFile.fromPath('proposal', _proposal!.path));
    }

    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);
    var response = jsonDecode(responseData.body);

    if (response["status"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => KegiatanPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan data kegiatan.")),
      );
    }
  }

  void _searchByName(String name) {
    if (name.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = _allWargaData
          .where((warga) =>
              warga["nama"].toLowerCase().contains(name.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchAllWarga() async {
    final request = await http.get(
      Uri.parse('https://pexadont.agsa.site/api/warga'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    if (response["status"] == 200) {
      setState(() {
        _allWargaData = response["data"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data warga')),
      );
    }
  }

  void _getRkb() async {
    try {
      final response = await http.get(
        Uri.parse('https://pexadont.agsa.site/api/rkb'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          rkbData = responseData['data'];
        });
      } else {
        showSnackbar('Gagal mendapatkan data kegiatan');
      }
    } catch (e) {
      showSnackbar('Gagal mendapatkan data kegiatan');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _pilihBulan(bulan) {
    setState(() {
      pilihBulan = bulan;
      pilihKegiatan = null;

      rkbDataFiltered = null;
    });

    final selectedData = rkbData.firstWhere(
      (item) => item["bulan"] == pilihBulan,
      orElse: () => null,
    );

    setState(() {
      rkbDataFiltered = selectedData;
    });

    if (selectedData['data'].isEmpty) {
      showSnackbar("Tidak ada kegiatan di bulan tersebut!");
    }
  }

  void _pilihKegiatan(kegiatan) {
    setState(() {
      pilihKegiatan = kegiatan;
    });

    final selectedRkb = rkbData.firstWhere(
      (item) => item["bulan"] == pilihBulan,
      orElse: () => null,
    );
    final getKegiatanSelected = selectedRkb['data'].firstWhere(
      (item) => item["keterangan"] == kegiatan,
      orElse: () => null,
    );
    if (getKegiatanSelected != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Input Kegiatan',
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
              MaterialPageRoute(builder: (context) => KegiatanPage()),
            );
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Column();
            } else {
              return Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        children: [
                          if (!validNIK)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 30, bottom: 30),
                              child: TextFormField(
                                initialValue: pelaksana,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: 'Cari Nama Pelaksana',
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: const Color(0xff30C083),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  _searchByName(value);
                                },
                              ),
                            ),
                          if (_searchResults.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final data = _searchResults[index];
                                  return ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  (data['foto'] != null)
                                                      ? 'https://pexadont.agsa.site/uploads/warga/${data['foto']}'
                                                      : 'https://placehold.co/300x300.png',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              (data['foto'] != null)
                                                  ? NetworkImage(
                                                      'https://pexadont.agsa.site/uploads/warga/${data['foto']}',
                                                    )
                                                  : null),
                                    ),
                                    title: Text(data['nama']),
                                    subtitle: Text('NIK: ${data['nik']}'),
                                    onTap: () {
                                      setState(() {
                                        pelaksana = data['nama'];
                                        nikController.text = data['nik'];
                                        validNIK = true;
                                        _searchResults = [];
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          if (validNIK)
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 30, bottom: 20),
                              child: TextFormField(
                                readOnly: true,
                                initialValue: pelaksana,
                                cursorColor: Color(0xff30C083),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: 'Nama Pelaksana',
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: const Color(0xff30C083),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (validNIK)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Pilih Bulan Kegiatan',
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xff30C083),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                  ),
                                ),
                                items: [
                                  'Januari ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Februari ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Maret ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'April ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Mei ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Juni ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Juli ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Agustus ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'September ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Oktober ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'November ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                  'Desember ' +
                                      DateFormat('yyyy')
                                          .format(new DateTime.now()),
                                ].map((String month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  );
                                }).toList(),
                                onChanged: (String? newMonth) =>
                                    _pilihBulan(newMonth),
                              ),
                            ),
                          if (validNIK && pilihBulan != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Pilih Kegiatan',
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xff30C083),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.event),
                                ),
                                items: (rkbDataFiltered != null &&
                                        rkbDataFiltered!['data'] != null)
                                    ? rkbDataFiltered!['data']
                                        .map<DropdownMenuItem<String>>(
                                            (activity) {
                                        return DropdownMenuItem<String>(
                                          value: activity['keterangan'],
                                          child: Text(activity['keterangan']),
                                        );
                                      }).toList()
                                    : [],
                                value: pilihKegiatan,
                                onChanged: (String? newActivity) =>
                                    _pilihKegiatan(newActivity),
                              ),
                            ),
                          if (validNIK)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: TextFormField(
                                readOnly: true,
                                onTap: _pickPDF,
                                controller: TextEditingController(
                                  text: _proposal != null
                                      ? _proposal!.path.split('/').last
                                      : '',
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.upload_file),
                                  labelText: 'Proposal',
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  hintText: _proposal == null
                                      ? 'Upload file proposal'
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xff30C083),
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: _proposal != null
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _proposal = null;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          if (validNIK)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: keteranganController,
                                maxLines: 5,
                                cursorColor: Color(0xff30C083),
                                decoration: InputDecoration(
                                  labelText: 'Deskripsi Kegiatan',
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: const Color(0xff30C083),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (validNIK)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () => _kirimData(),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 30),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff30C083),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(
                                      isLoading ? 'Mengirim...' : 'Kirim',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              );
            }
          }),
        ),
      ),
    );
  }
}
