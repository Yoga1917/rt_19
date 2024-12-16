import 'package:flutter/material.dart';
import 'package:rt_19/widget/toggle_tabs.dart';

class InputKASPage extends StatefulWidget {
  @override
  State<InputKASPage> createState() => _InputKASPageState();
}

class _InputKASPageState extends State<InputKASPage> {
  bool isPemasukanSelected = true;

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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InputKASPage()),
                                          );
                                        },
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextFormField(
                                        readOnly: true,
                                        onTap: () {},
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.upload_file),
                                          labelText: 'Upload Nota',
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
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => LoginPage()),
                                          // );
                                        },
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
