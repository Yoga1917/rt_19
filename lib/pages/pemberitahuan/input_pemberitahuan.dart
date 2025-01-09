import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rt_19/pages/home/pemberitahuan.dart';

class InputPemberitahuanPage extends StatefulWidget {
  @override
  State<InputPemberitahuanPage> createState() => _InputPemberitahuanPageState();
}

class _InputPemberitahuanPageState extends State<InputPemberitahuanPage> {
  final TextEditingController pemberitahuanController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  File? _file;
  bool isLoading = false;

  Future<void> _pickPDF() async {
    // Memilih file dengan tipe pdf
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Membatasi hanya memilih file PDF
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!); // Menyimpan file yang dipilih
      });
    } else {
      // Menangani jika tidak ada file yang dipilih
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Tidak ada file yang dipilih')));
    }
  }

  Future<void> _kirimData() async {
    if (pemberitahuanController.text.isEmpty ||
        deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama dan Isi Pemberitahuan harus diisi!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pexadont.agsa.site/api/pemberitahuan/simpan'),
      );
      request.fields['pemberitahuan'] = pemberitahuanController.text;
      request.fields['deskripsi'] = deskripsiController.text;
      if (_file != null) {
        request.files
            .add(await http.MultipartFile.fromPath('file', _file!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print("Response Data: $responseData");

        if (responseData['status'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Data pemberitahuan berhasil ditambahkan')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PemberitahuanPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseData['message'] ?? 'Gagal mengirim data')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan pada server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Input Pemberitahuan',
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
              MaterialPageRoute(builder: (context) => PemberitahuanPage()),
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
                            controller: pemberitahuanController,
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.notifications_active_sharp),
                              labelText: 'Nama Pemberitahuan',
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
                              text: _file != null
                                  ? _file!.path.split('/').last
                                  : '', // Menampilkan nama file jika ada
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.upload_file),
                              labelText: 'Upload File Surat',
                              floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              hintText: _file == null
                                  ? 'Pilih file PDF'
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
                              suffixIcon: _file != null
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color:
                                              Colors.red), // Tombol hapus file
                                      onPressed: () {
                                        setState(() {
                                          _file = null; // Menghapus file
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: deskripsiController,
                            maxLines: 5,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              labelText: 'Isi Pemberitahuan',
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
                            onTap: isLoading ? null : _kirimData,
                            child: Container(
                              width: double.infinity,
                              height: 55,
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
