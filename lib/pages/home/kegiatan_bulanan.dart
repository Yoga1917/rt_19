import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';

class KegiatanBulananPage extends StatefulWidget {
  @override
  State<KegiatanBulananPage> createState() => _KegiatanBulananPageState();
}

class _KegiatanBulananPageState extends State<KegiatanBulananPage> {
  final TextEditingController _tglController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  String? selectedYear;
  List<dynamic> rkbData = [];
  bool isLoading = true;
  String? aksiBy;
  String? fotoAksiBy;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toString();
    _getRkb();
  }

  void _getRkb() async {
    var tahun = selectedYear ?? DateTime.now().year;

    try {
      final response = await http.get(
        Uri.parse('https://pexadont.agsa.site/api/rkb?tahun=${tahun}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          rkbData = responseData['data'];
          isLoading = false;
          aksiBy = responseData['aksiBy'];
          fotoAksiBy = responseData['fotoAksiBy'];
        });
      } else {
        showSnackbar('Gagal memuat kegiatan bulanan');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _kirimRkb() async {
    var tgl = _tglController.text;
    var keterangan = _keteranganController.text;

    if (tgl == "" || keterangan == "") {
      showSnackbar("Harap lengkapi semua data!");
    } else {
      setState(() {
        isSubmitting = true;
      });

      var request = http.MultipartRequest(
          'POST', Uri.parse('https://pexadont.agsa.site/api/rkb/simpan'));
      request.fields['tgl'] = tgl;
      request.fields['keterangan'] = keterangan;

      var streamedResponse = await request.send();
      var responseData = await http.Response.fromStream(streamedResponse);
      var response = jsonDecode(responseData.body);

      setState(() {
        isSubmitting = false;
      });

      if (response["status"] == 201) {
        showSnackbar("Rencana kegiatan bulanan berhasil disimpan.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KegiatanBulananPage()),
        );
      } else {
        showSnackbar("Gagal menyimpan kegiatan bulanan.");
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatTgl(String tgl) {
    final tanggal = DateFormat("yyyy-MM-dd").parse(tgl);
    final bulans = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return DateFormat("dd").format(tanggal) +
        " " +
        bulans[int.parse(DateFormat("MM").format(tanggal)) - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Kegiatan Bulanan',
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xff30C083),
              ),
            )
          : GestureDetector(
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
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Input Kegiatan Bulanan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                    controller: _tglController,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2010),
                                        lastDate: DateTime(2050),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              primaryColor: Color(0xff30C083),
                                              colorScheme: ColorScheme.light(
                                                  primary: Color(0xff30C083)),
                                              buttonTheme: ButtonThemeData(
                                                  textTheme:
                                                      ButtonTextTheme.primary),
                                            ),
                                            child: child ?? Container(),
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _tglController.text =
                                              "${pickedDate.toLocal()}"
                                                  .split(' ')[0];
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.calendar_today),
                                      labelText: 'Tanggal Kegiatan',
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
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                    controller: _keteranganController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.event),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: GestureDetector(
                                    onTap: () => _kirimRkb(),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff30C083),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text(
                                          isSubmitting ? 'Kirim...' : 'Kirim',
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
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xff30C083),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            dropdownColor: Color(0xff30C083),
                            iconEnabledColor: Colors.white,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                '',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            value: selectedYear,
                            items: generateYearList()
                                .map<DropdownMenuItem<String>>((String year) {
                              return DropdownMenuItem<String>(
                                value: year,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 20, right: 5),
                                  child: Text(
                                    year,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedYear = newValue;
                              });
                              _getRkb();
                            },
                            itemHeight: null,
                          ),
                        ),
                        SizedBox(height: 30),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: rkbData.length,
                            itemBuilder: (context, index) {
                              final rkbBulan = rkbData[index]['bulan'];
                              final rkbKegiatan = rkbData[index]['data'];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20),
                                        Text(
                                          rkbBulan,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        if (rkbKegiatan.length > 0)
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: Image.network(
                                                            'https://pexadont.agsa.site/uploads/warga/$fotoAksiBy',
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: NetworkImage(
                                                    'https://pexadont.agsa.site/uploads/warga/$fotoAksiBy',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(aksiBy!),
                                            ],
                                          ),
                                        SizedBox(height: 10),
                                        rkbKegiatan.length > 0
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (var item in rkbKegiatan)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 5),
                                                      child: Text(
                                                        formatTgl(item['tgl']) +
                                                            " => " +
                                                            item['keterangan'],
                                                      ),
                                                    ),
                                                  const SizedBox(height: 20)
                                                ],
                                              )
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: const Text(
                                                  'Tidak ada kegiatan di bulan ini.',
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    );
                  }
                }),
              ),
            ),
    );
  }

  List<String> generateYearList() {
    int currentYear = DateTime.now().year;
    List<String> years = [];

    for (int i = 2014; i <= currentYear; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
