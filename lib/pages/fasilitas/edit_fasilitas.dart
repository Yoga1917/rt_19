import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rt_19/pages/home/fasilitas.dart';
import 'package:http/http.dart' as http;

class EditFasilitasPage extends StatefulWidget {
  final String id_fasilitas;
  final String nama;
  final String jml;
  final String status;

  const EditFasilitasPage(this.id_fasilitas, this.nama, this.jml, this.status);

  @override
  State<EditFasilitasPage> createState() => _EditFasilitasPageState();
}

class _EditFasilitasPageState extends State<EditFasilitasPage> {
  final TextEditingController jumlahController = TextEditingController();
  String? kondisi;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    jumlahController.text = widget.jml;
    kondisi = widget.status;
  }

  Future<void> _kirimData() async {
    if (jumlahController.text == widget.jml && kondisi == widget.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data yang diubah.')),
      );
      return;
    }

    if (jumlahController.text.isEmpty || kondisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi data yang diperlukan!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://pexadont.agsa.site/api/fasilitas/update/${widget.id_fasilitas}'));
      request.fields['nama'] = widget.nama;
      request.fields['jml'] = jumlahController.text;
      request.fields['status'] = kondisi!;

      var streamedResponse = await request.send();
      var responseData = await http.Response.fromStream(streamedResponse);
      var response = jsonDecode(responseData.body);

      if (response['status'] == 202) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Data fasilitas berhasil diperbarui')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FasilitasPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah data')),
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
          'Edit Fasilitas',
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
              MaterialPageRoute(builder: (context) => FasilitasPage()),
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
                            value: widget.status,
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
                                kondisi = newValue!;
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
                            onTap: isLoading ? null : _kirimData,
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
