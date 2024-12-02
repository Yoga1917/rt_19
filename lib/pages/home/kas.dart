import 'package:flutter/material.dart';
import 'package:rt_19/pages/kas_RT/input_kas.dart';
import 'package:rt_19/widget/kartu_laporan.dart';
import 'package:rt_19/widget/kartu_total_laporan.dart';

class KasPage extends StatefulWidget {
  @override
  State<KasPage> createState() => _KasPageState();
}

class _KasPageState extends State<KasPage> {
  String? selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Uang KAS RT',
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InputKasPage()),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff30C083),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Kas RT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
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
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text('Sisa Dana Kas : Rp. 100.000.000'),
                SizedBox(
                  height: 30,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    KartuLaporan(
                      month: 'Januari',
                      date: '01-01-2023',
                      income: 'Rp 1,000,000',
                      expense: 'Rp 500,000',
                      description:
                          'Pengeluaran digunakan untuk membeli peralatan kebersihan',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Februari',
                      date: '01-02-2023',
                      income: 'Rp 1,200,000',
                      expense: 'Rp 600,000',
                      description:
                          'Pengeluaran digunakan untuk membeli bahan bakar genset',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Maret',
                      date: '01-03-2023',
                      income: 'Rp 1,100,000',
                      expense: 'Rp 700,000',
                      description:
                          'Pengeluaran digunakan untuk perbaikan jalan',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'April',
                      date: '01-04-2023',
                      income: 'Rp 1,300,000',
                      expense: 'Rp 800,000',
                      description:
                          'Pengeluaran digunakan untuk acara 17 Agustus',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Mei',
                      date: '01-05-2023',
                      income: 'Rp 1,400,000',
                      expense: 'Rp 900,000',
                      description:
                          'Pengeluaran digunakan untuk membeli alat olahraga',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Juni',
                      date: '01-06-2023',
                      income: 'Rp 1,500,000',
                      expense: 'Rp 1,000,000',
                      description:
                          'Pengeluaran digunakan untuk perbaikan saluran air',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Juli',
                      date: '01-07-2023',
                      income: 'Rp 1,600,000',
                      expense: 'Rp 1,100,000',
                      description:
                          'Pengeluaran digunakan untuk membeli alat kebersihan',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Agustus',
                      date: '01-08-2023',
                      income: 'Rp 1,700,000',
                      expense: 'Rp 1,200,000',
                      description:
                          'Pengeluaran digunakan untuk membeli bahan bakar genset',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'September',
                      date: '01-09-2023',
                      income: 'Rp 1,800,000',
                      expense: 'Rp 1,300,000',
                      description:
                          'Pengeluaran digunakan untuk perbaikan jalan',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Oktober',
                      date: '01-10-2023',
                      income: 'Rp 1,900,000',
                      expense: 'Rp 1,400,000',
                      description:
                          'Pengeluaran digunakan untuk acara 17 Agustus',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'November',
                      date: '01-11-2023',
                      income: 'Rp 2,000,000',
                      expense: 'Rp 1,500,000',
                      description:
                          'Pengeluaran digunakan untuk membeli alat olahraga',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    KartuLaporan(
                      month: 'Desember',
                      date: '01-12-2023',
                      income: 'Rp 2,100,000',
                      expense: 'Rp 1,600,000',
                      description:
                          'Pengeluaran digunakan untuk perbaikan saluran air',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    TotalCard(
                        totalIncome: 'Rp 18,800,000',
                        totalExpense: 'Rp 12,000,000',
                        remainingFunds: 'Rp 6,800,000'),
                  ],
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

    for (int i = currentYear - 10; i <= 2070; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
