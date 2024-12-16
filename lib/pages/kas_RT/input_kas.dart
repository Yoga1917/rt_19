import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rt_19/pages/kas_RT/detail_kas.dart';
import 'package:rt_19/widget/toggle_tabs.dart';

class InputKASPage extends StatefulWidget {
  @override
  State<InputKASPage> createState() => _InputKASPageState();
}

class _InputKASPageState extends State<InputKASPage> {
  bool isPemasukanSelected = true;
  String? id_kas;
  String? periode = "Periode Kas...";
  final TextEditingController _jumlahPemasukanController = TextEditingController();
  final TextEditingController _keteranganPemasukanController = TextEditingController();
  final TextEditingController _jumlahPengeluaranController = TextEditingController();
  final TextEditingController _keteranganPengeluaranController = TextEditingController();
  File? _fotoPengeluaran;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fotoPengeluaran = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLastKas();
  }

  void _getLastKas() async {
    final request = await http.get(
      Uri.parse('https://pexadont.agsa.site/api/kas/last'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    if (response["status"] == 200) {
      setState(() {
        id_kas = response["data"]["id_kas"];
        periode = response["data"]["bulan"] + " "+ response["data"]["tahun"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data kas tidak ditemukan')),
      );
    }
  }
  
  void _simpanPemasukan() {
    if (_jumlahPemasukanController.text != "" || _keteranganPemasukanController.text != "") {
      print('Jumlah: ${_jumlahPemasukanController.text}');
      print('Keterangan: ${_keteranganPemasukanController.text}');

      _postPemasukan();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi data yang diperlukan!')),
      );
    }
  }
  
  void _simpanPengeluaran() {
    if (_jumlahPengeluaranController.text != "" || _keteranganPengeluaranController.text != "") {
      print('Jumlah: ${_jumlahPengeluaranController.text}');
      print('Keterangan: ${_keteranganPengeluaranController.text}');
      print('Foto: ${_fotoPengeluaran}');

      _postPengeluaran();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi data yang diperlukan!')),
      );
    }
  }
  
  void _postPemasukan() async {
    var request = http.MultipartRequest('POST', Uri.parse('https://pexadont.agsa.site/api/kas/pemasukan/simpan'));
    request.fields['id_kas'] = id_kas.toString();
    request.fields['jumlah'] = _jumlahPemasukanController.text;
    request.fields['keterangan'] = _keteranganPemasukanController.text;

    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);
    var response = jsonDecode(responseData.body);

    if (response["status"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pemasukan kas berhasil ditambahkan')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailKASPage(id_kas.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data pemasukan")),
      );
    }
  }
  
  void _postPengeluaran() async {
    var request = http.MultipartRequest('POST', Uri.parse('https://pexadont.agsa.site/api/kas/pengeluaran/simpan'));
    request.fields['id_kas'] = id_kas.toString();
    request.fields['jumlah'] = _jumlahPengeluaranController.text;
    request.fields['keterangan'] = _keteranganPengeluaranController.text;
    if(_fotoPengeluaran != null){
      request.files.add(await http.MultipartFile.fromPath('foto', _fotoPengeluaran!.path));
    }

    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);
    var response = jsonDecode(responseData.body);

    if (response["status"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengeluaran kas berhasil ditambahkan')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailKASPage(id_kas.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data pengeluaran")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Input Kas RT',
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
                SizedBox(height: 30),
                ToggleTabs(
                  isSelectedLeft: isPemasukanSelected,
                  leftLabel: 'Pemasukan',
                  rightLabel: 'Pengeluaran',
                  onToggle: (value) {
                    setState(() {
                      isPemasukanSelected = value;
                    });
                  },
                ),
                SizedBox(height: 30),
                Text(periode.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                SizedBox(height: 30),
                Center(
                  child: isPemasukanSelected
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
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
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextFormField(
                                        controller: _jumlahPemasukanController,
                                        keyboardType: TextInputType.number,
                                        cursorColor: Color(0xff30C083),
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.attach_money),
                                          labelText: 'Pemasukan',
                                          floatingLabelStyle: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextFormField(
                                        controller: _keteranganPemasukanController,
                                        maxLines: 5,
                                        cursorColor: Color(0xff30C083),
                                        decoration: InputDecoration(
                                          labelText: 'Keterangan',
                                          floatingLabelStyle: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: GestureDetector(
                                        onTap: () => _simpanPemasukan(),
                                        child: Container(
                                          width: double.infinity,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xff30C083),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                        )
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
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
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextFormField(
                                        controller: _jumlahPengeluaranController,
                                        cursorColor: Color(0xff30C083),
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.money_off),
                                          labelText: 'Pengeluaran',
                                          floatingLabelStyle: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: const Color(0xff30C083),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
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
                                                Text("Upload Nota")
                                              ],
                                            ),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    if (_fotoPengeluaran != null) // Display image preview if selected
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Image.file(
                                          _fotoPengeluaran!,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextFormField(
                                        controller: _keteranganPengeluaranController,
                                        maxLines: 5,
                                        cursorColor: Color(0xff30C083),
                                        decoration: InputDecoration(
                                          labelText: 'Keterangan',
                                          floatingLabelStyle: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: GestureDetector(
                                        onTap: () => _simpanPengeluaran(),
                                        child: Container(
                                          width: double.infinity,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xff30C083),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
