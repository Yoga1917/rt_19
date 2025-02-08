import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rt_19/pages/halaman_utama/home.dart';
import 'package:rt_19/pages/pengurus/input_pengurus.dart';

class PengurusPage extends StatefulWidget {
  @override
  _PengurusPageState createState() => _PengurusPageState();
}

class _PengurusPageState extends State<PengurusPage> {
  String? selectedPeriode;
  List<dynamic> pengurusData = [];
  bool isLoading = true;
  bool loadingUpdate = false;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    generatePeriodList();
    selectedPeriode = getCurrentPeriod();
    fetchPengurusData();
  }

  // Fungsi untuk mendapatkan periode yang sesuai dengan tahun sekarang
  String? getCurrentPeriod() {
    int currentYear = DateTime.now().year;
    List<String> periods = generatePeriodList();
    // Cari periode yang mencakup tahun sekarang
    for (String period in periods) {
      int startYear = int.parse(period.split('-')[0]);
      int endYear = int.parse(period.split('-')[1]);
      if (currentYear >= startYear && currentYear <= endYear) {
        return period;
      }
    }
    return null;
  }

  List<String> generatePeriodList() {
    int currentYear = DateTime.now().year;
    int startYear = 2014;
    List<String> periods = [];

    for (int i = startYear; i <= currentYear + 10; i += 5) {
      int endYear = i + 5;
      periods.add('$i-$endYear');
    }

    List<String> selectedPeriods = [];

    for (int i = periods.length - 1; i >= 0; i--) {
      String period = periods[i];
      int startPeriod = int.parse(period.split('-')[0]);
      int endPeriod = int.parse(period.split('-')[1]);

      if (currentYear >= startPeriod && currentYear <= endPeriod) {
        selectedPeriods.add(period);
        break;
      }
    }

    for (int i = periods.length - 1; i >= 0; i--) {
      String period = periods[i];
      int startPeriod = int.parse(period.split('-')[0]);

      if (!selectedPeriods.contains(period) && startPeriod <= currentYear) {
        selectedPeriods.add(period);
      }
    }

    selectedPeriods.sort((a, b) {
      int aStart = int.parse(a.split('-')[0]);
      int bStart = int.parse(b.split('-')[0]);
      return bStart.compareTo(aStart);
    });

    return selectedPeriods;
  }

  Future<void> fetchPengurusData() async {
    String url = selectedPeriode == null
        ? 'https://pexadont.agsa.site/api/pengurus'
        : 'https://pexadont.agsa.site/api/pengurus?periode=${selectedPeriode}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (!responseData['error']) {
          setState(() {
            pengurusData = responseData['data']
                .map((item) =>
                    {...item, 'status_pengurus': item['status_pengurus']})
                .toList();
            isLoading = false;
          });
        } else {
          showSnackbar(responseData['message']);
        }
      } else {
        showSnackbar('Gagal memuat data pengurus');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  Future<void> _updateStatus(
    String id_pengurus,
    String nik,
    String jabatan,
    String periode,
    String status_pengurus,
  ) async {
    setState(() => loadingUpdate = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pexadont.agsa.site/api/pengurus/update/$id_pengurus'),
      );

      request.fields['id_pengurus'] = id_pengurus;
      request.fields['nik'] = nik;
      request.fields['jabatan'] = jabatan;
      request.fields['periode'] = periode;
      request.fields['status_pengurus'] = status_pengurus;

      var responseData = await http.Response.fromStream(await request.send());
      var response = jsonDecode(responseData.body);

      if (response["status"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status akun pengurus berhasil diubah!')),
        );
        setState(() {
          isActive = status_pengurus == "1";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update status akun warga!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      setState(() => loadingUpdate = false);
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          'Pengurus RT',
          style: TextStyle(color: Colors.white),
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
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Column();
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InputPengurusPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Pengurus',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xff30C083),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Color(0xff30C083),
                              iconEnabledColor: Colors.white,
                              hint: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              value: selectedPeriode,
                              items: generatePeriodList().map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPeriode = newValue;
                                });
                                fetchPengurusData();
                              },
                              itemHeight: null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: pengurusData.isNotEmpty
                            ? SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pengurusData.length,
                                  itemBuilder: (context, index) {
                                    final pengurus = pengurusData[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(height: 20),
                                          Text(
                                            pengurus['jabatan'],
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                'https://pexadont.agsa.site/uploads/warga/${pengurus['foto']}',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  pengurus['nama'],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'NIK : ${pengurus['nik']}',
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Tanggal Lahir : ${formatDate(pengurus['tgl_lahir'])}',
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Jenis Kelamin : ${pengurus['jenis_kelamin']}',
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'No. Rumah : ${pengurus['no_rumah']}',
                                                ),
                                                SizedBox(height: 20),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (loadingUpdate) return;

                                                    final newStatus = pengurus[
                                                                'status_pengurus'] ==
                                                            "1"
                                                        ? "2"
                                                        : "1";

                                                    await _updateStatus(
                                                      pengurus['id_pengurus'],
                                                      pengurus['nik'],
                                                      pengurus['jabatan'],
                                                      pengurus['periode'],
                                                      newStatus,
                                                    );

                                                    setState(() {
                                                      pengurusData[index][
                                                              'status_pengurus'] =
                                                          newStatus;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: pengurus[
                                                                  'status_pengurus'] ==
                                                              "1"
                                                          ? const Color(
                                                              0xff30C083)
                                                          : Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Text(
                                                        loadingUpdate
                                                            ? 'Update...'
                                                            : (pengurus['status_pengurus'] ==
                                                                    "1"
                                                                ? 'Aktif'
                                                                : 'Tidak Aktif'),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 18,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                    "Tidak ada data pengurus di periode ini."),
                              ),
                      ),
                    ],
                  ),
                );
              }
            }),
    );
  }
}
