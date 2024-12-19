import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rt_19/pages/home/kegiatan.dart';
import 'package:file_picker/file_picker.dart';

class EditKegiatanPage extends StatefulWidget {
  final String id_kegiatan;
  const EditKegiatanPage(this.id_kegiatan);

  @override
  State<EditKegiatanPage> createState() => _EditKegiatanPageState();
}

class _EditKegiatanPageState extends State<EditKegiatanPage> {
  File? _lpj;
  bool isLoading = false;

  Future<void> _pickPDF() async {
    // Memilih file dengan tipe pdf
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Membatasi hanya memilih file PDF
    );

    if (result != null) {
      setState(() {
        _lpj = File(result.files.single.path!); // Menyimpan file yang dipilih
      });
    } else {
      // Menangani jika tidak ada file yang dipilih
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak ada file yang dipilih')));
    }
  }

  void _kirimData() async {
    if(_lpj == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lengkapi data yang diperlukan!')));
    }else{
      setState(() {
        isLoading = true;
      });

      var request = http.MultipartRequest('POST', Uri.parse('https://pexadont.agsa.site/api/kegiatan/lpj'));
      request.fields['id_kegiatan'] = widget.id_kegiatan;
      request.files.add(await http.MultipartFile.fromPath('lpj', _lpj!.path));

      var streamedResponse = await request.send();
      var responseData = await http.Response.fromStream(streamedResponse);
      var response = jsonDecode(responseData.body);

      if (response["status"] == 200) {
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
          const SnackBar(content: Text("Gagal upload LPJ.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Edit Kegiatan',
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
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            readOnly: true,
                            onTap: _pickPDF, // Fungsi untuk memilih file PDF
                            controller: TextEditingController(
                              text: _lpj != null
                                  ? _lpj!.path.split('/').last
                                  : '', // Menampilkan nama file jika ada
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.upload_file),
                              labelText: 'LPJ',
                              floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              hintText: _lpj == null
                                  ? 'Upload file LPJ'
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
                              suffixIcon: _lpj != null
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color:
                                              Colors.red), // Tombol hapus file
                                      onPressed: () {
                                        setState(() {
                                          _lpj = null; // Menghapus file
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
                                  style: const TextStyle(
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
