import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rt_19/pages/home/pengurus.dart';

class InputPengurusPage extends StatefulWidget {
  @override
  _InputPengurusPageState createState() => _InputPengurusPageState();
}

class _InputPengurusPageState extends State<InputPengurusPage> {
  final TextEditingController _nikController = TextEditingController();
  String? _nama;
  String? _tglLahir;
  String? _noRumah;
  String? _foto;

  String? _selectedJabatan;
  String? _selectedPeriode;
  bool isLoading = false;

  void _cekNIK() async {
    setState(() {
      isLoading = true;
    });

    if (_nikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi data NIK!')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (_nikController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIK harus 16 digit angka!')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (int.tryParse(_nikController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data NIK harus berupa angka!')),
      );
      setState(() {
        isLoading = false;
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
      isLoading = false;
    });

    if (response["status"] == 200) {
      setState(() {
        _nama = response["data"]["nama"];
        _tglLahir = response["data"]["tgl_lahir"];
        _noRumah = response["data"]["no_rumah"];
        _foto = response["data"]["foto"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data warga tidak ditemukan')),
      );
    }
  }

  void _simpan() {
    if (_selectedJabatan != null || _selectedPeriode != null) {
      print('NIK: ${_nikController.text}');
      print('Jabatan: $_selectedJabatan');
      print('Periode: $_selectedPeriode');

      _savePengurus(_nikController.text, _selectedJabatan, _selectedPeriode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih jabatan dan periode pengurus terlebih dahulu!')),
      );
    }
  }

  void _savePengurus(nik, jabatan, periode) async {
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
        SnackBar(content: Text(response["data"])),
      );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 30),
              TextFormField(
                controller: _nikController,
                cursorColor: Color(0xff30C083),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.credit_card),
                  labelText: 'NIK',
                  floatingLabelStyle: const TextStyle(color: Colors.black),
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
                  if (!isLoading) {
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
                      isLoading ? 'Cek Warga...' : 'Cek Warga',
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
              if (_nama != null) ...[
                _foto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://pexadont.agsa.site/uploads/warga/${_foto}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Container(),
                SizedBox(height: 10),
                Text('${_nama}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Tanggal Lahir: $_tglLahir'),
                Text('No Rumah: $_noRumah'),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Jabatan',
                    floatingLabelStyle: const TextStyle(color: Colors.black),
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
                    prefixIcon: Icon(Icons.work, color: Colors.black),
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
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Periode',
                    floatingLabelStyle: const TextStyle(color: Colors.black),
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
                    prefixIcon: Icon(Icons.list, color: Colors.black),
                  ),
                  items: [
                    '2019-2024',
                    '2024-2029',
                    '2029-2034',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriode = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: isLoading ? null : _simpan,
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
                        isLoading ? 'Simpan...' : 'Simpan',
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
