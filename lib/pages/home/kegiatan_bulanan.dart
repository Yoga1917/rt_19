import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  
  @override
  void initState() {
    super.initState();
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

    if(tgl == "" || keterangan == ""){
      showSnackbar("Isi data yang diperlukan!");
    }else{
      var request = http.MultipartRequest('POST', Uri.parse('https://pexadont.agsa.site/api/rkb/simpan'));
      request.fields['tgl'] = tgl;
      request.fields['keterangan'] = keterangan;

      var streamedResponse = await request.send();
      var responseData = await http.Response.fromStream(streamedResponse);
      var response = jsonDecode(responseData.body);
      
      if (response["status"] == 201) {
        showSnackbar("Kegiatan bulanan berhasil disimpan.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KegiatanBulananPage()),
        );
      }else{
        showSnackbar("Gagal menyimpan kegiatan bulanan.");
      }
    }
  }
  
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatTgl(String tgl){
    final tanggal = DateFormat("yyyy-MM-dd").parse(tgl);
    final bulans = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return DateFormat("dd").format(tanggal) +" "+ bulans[int.parse(DateFormat("MM").format(tanggal))-1];
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _tglController,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2010),
                                lastDate: DateTime(2050),
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
                                  _tglController.text = "${pickedDate.toLocal()}".split(' ')[0];
                                });
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today),
                              labelText: 'Tanggal',
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _keteranganController,
                            maxLines: 5,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              labelText: 'Keterangan Kegiatan',
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
                            onTap: () => _kirimRkb(),
                            child: Container(
                              width: double.infinity,
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
                SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xff30C083),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: Color(0xff30C083),
                    iconEnabledColor: Colors.white,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Pilih Tahun',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    value: selectedYear,
                    items: generateYearList()
                        .map<DropdownMenuItem<String>>((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            year,
                            style: TextStyle(color: Colors.white),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                rkbBulan,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              rkbKegiatan.length > 0
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for(var item in rkbKegiatan) Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      formatTgl(item['tgl']) +" => "+ item['keterangan'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20)
                                ],
                              )
                              : Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: const Text(
                                  'Tidak ada kegiatan di bulan ini',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  List<String> generateYearList() {
    int currentYear = DateTime.now().year;
    List<String> years = [];

    for (int i = currentYear - 10; i <= currentYear; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
