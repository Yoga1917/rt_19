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
  final TextEditingController pelaksanaController = TextEditingController();
  final TextEditingController tglController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  File? _proposal;
  bool isLoading = false;

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
      pelaksanaController.text.isEmpty ||
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
    request.fields['ketua_pelaksana'] = pelaksanaController.text;
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
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: pelaksanaController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Nama Ketua Pelaksana',
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
                          height: 20,
                        ),
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
                          height: 20,
                        ),
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
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () => _kirimData(),
                            child: Container(
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
                        SizedBox(
                          height: 30,
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
