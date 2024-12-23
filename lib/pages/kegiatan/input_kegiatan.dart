import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:rt_19/pages/home/kegiatan.dart';

class InputKegiatanPage extends StatefulWidget {
  @override
  State<InputKegiatanPage> createState() => _InputKegiatanPageState();
}

class _InputKegiatanPageState extends State<InputKegiatanPage> {
  final TextEditingController kegiatanController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController tglController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  File? _proposal;
  bool isLoading = false;
  bool validNIK = false;
  bool nikLoading = false;
  String? pelaksana;

  Future<void> _pickPDF() async {
    // Memilih file dengan tipe pdf
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Membatasi hanya memilih file PDF
    );

    if (result != null) {
      setState(() {
        _proposal = File(result.files.single.path!); // Menyimpan file yang dipilih
      });
    } else {
      // Menangani jika tidak ada file yang dipilih
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Tidak ada file yang dipilih')));
    }
  }

  void _kirimData() async {
    if(
      kegiatanController.text.isEmpty ||
      nikController.text.isEmpty ||
      tglController.text.isEmpty ||
      keteranganController.text.isEmpty ||
      _proposal == null
    ){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lengkapi data yang diperlukan!')));
    }else{
      setState(() {
        isLoading = true;
      });

      _postKegiatan();
    }
  }

  void _postKegiatan() async {
    var request = http.MultipartRequest('POST', Uri.parse('https://pexadont.agsa.site/api/kegiatan/simpan'));
    request.fields['nik'] = nikController.text;
    request.fields['nama_kegiatan'] = kegiatanController.text;
    request.fields['keterangan'] = keteranganController.text;
    request.fields['tgl'] = tglController.text;
    if (_proposal != null) {
      request.files.add(
          await http.MultipartFile.fromPath('proposal', _proposal!.path));
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
      print(response);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan data kegiatan.")),
      );
    }
  }

  void _cekNIK() async {
    setState(() {
      nikLoading = true;
    });

    if (nikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi data NIK!')),
      );
      setState(() {
        nikLoading = false;
      });
      return;
    }

    if (nikController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIK harus 16 digit angka!')),
      );
      setState(() {
        nikLoading = false;
      });
      return;
    }

    if (int.tryParse(nikController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data NIK harus berupa angka!')),
      );
      setState(() {
        nikLoading = false;
      });
      return;
    }

    final request = await http.get(
      Uri.parse(
          'https://pexadont.agsa.site/api/warga/edit/${nikController.text}'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    setState(() {
      nikLoading = false;
    });

    if (response["status"] == 200) {
      setState(() {
        pelaksana = response["data"]["nama"];
        validNIK = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data warga tidak ditemukan')),
      );
    }
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
      body: SingleChildScrollView(
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
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: kegiatanController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.event),
                              labelText: 'Nama Kegiatan',
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
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: nikController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'NIK Pelaksana',
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
                        if(!validNIK)
                        InkWell(
                          onTap: () => _cekNIK(),
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xff30C083),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                nikLoading ? 'Loading...' : 'Cek Data',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        if(validNIK)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        if(validNIK)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: tglController,
                            cursorColor: Colors.black,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: Color(0xff30C083),
                                      colorScheme: ColorScheme.light(
                                          primary: Color(0xff30C083)),
                                      buttonTheme: ButtonThemeData(
                                          textTheme: ButtonTextTheme.primary),
                                    ),
                                    child: child ?? Container(),
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  tglController.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                                });
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today),
                              labelText: 'Tanggal Acara',
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
                        SizedBox(
                          height: 15,
                        ),
                        if(validNIK)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            readOnly: true,
                            onTap: _pickPDF, // Fungsi untuk memilih file PDF
                            controller: TextEditingController(
                              text: _proposal != null
                                  ? _proposal!.path.split('/').last
                                  : '', // Menampilkan nama file jika ada
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.upload_file),
                              labelText: 'Proposal',
                              floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              hintText: _proposal == null
                                  ? 'Upload file proposal'
                                  : null, // Menambahkan hint jika belum ada file
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
                                          color:
                                              Colors.red), // Tombol hapus file
                                      onPressed: () {
                                        setState(() {
                                          _proposal = null; // Menghapus file
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if(validNIK)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: keteranganController,
                            maxLines: 3,
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
                        if(validNIK)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                    fontWeight: FontWeight.w900,
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
              ],
            );
          }
        }),
      ),
    );
  }
}
