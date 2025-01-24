import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/home/pengurus.dart';

class InputPengurusPage extends StatefulWidget {
  @override
  _InputPengurusPageState createState() => _InputPengurusPageState();
}

class _InputPengurusPageState extends State<InputPengurusPage> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _periodeController = TextEditingController();
  String? _nama;
  String? _tglLahir;
  String? _noRumah;
  String? _jenisKelamin;
  String? _foto;

  String? _selectedJabatan;
  bool isLoadingCek = false;
  bool isLoadingSimpan = false;
  bool isCekData = false;

  void _cekNIK() async {
    setState(() {
      isLoadingCek = true;
      isCekData = true;
    });

    if (_nikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi data NIK!')),
      );
      setState(() {
        isLoadingCek = false;
        isCekData = false;
      });
      return;
    }

    if (_nikController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIK harus 16 digit angka!')),
      );
      setState(() {
        isLoadingCek = false;
        isCekData = false;
      });
      return;
    }

    if (int.tryParse(_nikController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data NIK harus berupa angka!')),
      );
      setState(() {
        isLoadingCek = false;
        isCekData = false;
      });
      return;
    }

    final request = await http.get(
      Uri.parse(
          'https://pexadont.agsa.site/api/warga/edit/${_nikController.text}'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    setState(() {
      isLoadingCek = false;
    });

    if (response["status"] == 200) {
      setState(() {
        _nama = response["data"]["nama"];
        _tglLahir = response["data"]["tgl_lahir"];
        _jenisKelamin = response["data"]["jenis_kelamin"];
        _noRumah = response["data"]["no_rumah"];
        _foto = response["data"]["foto"];
      });
    } else {
      setState(() {
        _nama = null;
      });
    }
  }

  bool _isValidPeriode(String periode) {
    final RegExp regex = RegExp(r'^\d{4}-\d{4}$');
    return regex.hasMatch(periode);
  }

  void _simpan() {
    if (_selectedJabatan == null && _periodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih jabatan dan isi periode pengurus terlebih dahulu!',
          ),
        ),
      );
    } else if (_selectedJabatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih jabatan terlebih dahulu!'),
        ),
      );
    } else if (_periodeController.text.isEmpty ||
        !_isValidPeriode(_periodeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Isi periode pengurus dengan format yyyy-yyyy!'),
        ),
      );
    } else {
      _savePengurus(
          _nikController.text, _selectedJabatan, _periodeController.text);
    }
  }

  void _savePengurus(nik, jabatan, periode) async {
    setState(() {
      isLoadingSimpan = true;
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://pexadont.agsa.site/api/pengurus/simpan'));
      request.fields['nik'] = nik;
      request.fields['jabatan'] = jabatan;
      request.fields['periode'] = periode;

      var streamedResponse = await request.send();
      var responseData = await http.Response.fromStream(streamedResponse);
      var response = jsonDecode(responseData.body);

      if (response["status"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data pengurus berhasil ditambahkan')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PengurusPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Pengurus dengan NIK tersebut sudah menjabat di periode ini!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan, coba lagi!')),
      );
    } finally {
      setState(() {
        isLoadingSimpan = false;
      });
    }
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
          'Input Pengurus',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PengurusPage()),
            );
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 30),
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.credit_card),
                  labelText: 'NIK',
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
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (!isLoadingCek) {
                    _cekNIK();
                  }
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
                    child: Text(
                      isLoadingCek ? 'Cek Warga...' : 'Cek Warga',
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
              SizedBox(height: 30),
              Expanded(
                child: isLoadingCek
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff30C083),
                        ),
                      )
                    : _nama == null && isCekData
                        ? Center(
                            child: Text(
                              'Data tidak ditemukan.',
                            ),
                          )
                        : (_nama != null
                            ? SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (_foto != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          'https://pexadont.agsa.site/uploads/warga/${_foto}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '${_nama}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Jenis Kelamin: $_jenisKelamin',
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tanggal Lahir: ${_tglLahir != null ? formatDate(_tglLahir!) : 'Unknown'}',
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'No Rumah: $_noRumah',
                                    ),
                                    SizedBox(height: 20),
                                    DropdownButtonFormField<String>(
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        labelText: 'Jabatan',
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
                                            color: Color(0xff30C083),
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: const Icon(Icons.work),
                                      ),
                                      items: [
                                        'Ketua RT',
                                        'Sekretaris',
                                        'Bendahara',
                                        'Kordinator Kebersihan',
                                        'Kordinator Keamanan',
                                      ].map((String jabatan) {
                                        return DropdownMenuItem<String>(
                                          value: jabatan,
                                          child: Text(jabatan),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedJabatan = newValue;
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _periodeController,
                                      decoration: InputDecoration(
                                        prefixIcon:
                                            const Icon(Icons.credit_card),
                                        labelText: 'Periode',
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
                                            color: Color(0xff30C083),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: isLoadingSimpan ? null : _simpan,
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
                                          child: Text(
                                            isLoadingSimpan
                                                ? 'Simpan...'
                                                : 'Simpan',
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
                                    SizedBox(height: 30),
                                  ],
                                ),
                              )
                            : SizedBox()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
