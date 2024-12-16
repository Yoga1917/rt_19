import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rt_19/pages/home/fasilitas.dart';

class InputFasilitasPage extends StatefulWidget {
  @override
  State<InputFasilitasPage> createState() => _InputFasilitasPageState();
}

class _InputFasilitasPageState extends State<InputFasilitasPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController kondisiController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _kirimData() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://pexadont.agsa.site/api/fasilitas/simpan'));
    request.fields['nama'] = namaController.text;
    request.fields['jml'] = jumlahController.text;
    request.fields['status'] = kondisiController.text;
    request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var responseData = jsonDecode(response.body);

    if (responseData['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Berhasil dikirim.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FasilitasPage()),
      );
    } else {
      if (responseData['data']['foto'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['data']['foto'])),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Input Fasilitas',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
                            controller: namaController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.home),
                              labelText: 'Nama Fasilitas',
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
                            controller: jumlahController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.list),
                              labelText: 'Jumlah',
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
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.info),
                              labelText: 'Kondisi',
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
                            ),
                            items: [
                              'Baik',
                              'Tidak Baik',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                kondisiController.text = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.upload_file),
                                    SizedBox(width: 10),
                                    Text("Upload Foto")
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(height: 20),
                        if (_image != null) // Display image preview if selected
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Image.file(
                              _image!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              _kirimData();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: const Text(
                                  'Kirim',
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
