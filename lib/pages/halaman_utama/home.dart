import 'package:flutter/material.dart';
import 'package:rt_19/pages/home/fasilitas.dart';
import 'package:rt_19/pages/home/kas.dart';
import 'package:rt_19/pages/home/kegiatan.dart';
import 'package:rt_19/pages/home/pemberitahuan.dart';
import 'package:rt_19/pages/home/pendaftaran.dart';
import 'package:rt_19/pages/home/pengaduan.dart';
import 'package:rt_19/pages/home/pengurus.dart';
import 'package:rt_19/pages/home/datawarga.dart';
import 'package:rt_19/pages/home/kegiatan_bulanan.dart';
import 'package:rt_19/pages/mulai/login.dart';
import 'package:rt_19/widget/custom_category_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? jabatan;

  @override
  void initState() {
    super.initState();
    _loadJabatan();
  }

  void _loadJabatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      jabatan = prefs.getString('jabatan');
    });
  }

  void _logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(jabatan);

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Color(0xff30C083),
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Text(
                    'Hai.. Pengurus RT 19',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Data yang akurat sangat penting untuk kepentingan bersama',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20, bottom: 30),
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                ),
                children: [
                  if(jabatan == "Sekretaris")
                  CustomCategoryContainer(
                    icon: Icons.group,
                    text: 'Data Warga',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DataWargaPage()),
                      );
                    },
                  ),
                  CustomCategoryContainer(
                    icon: Icons.feedback,
                    text: 'Pengaduan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PengaduanPage()),
                      );
                    },
                  ),
                  if(jabatan == "Bendahara")
                  CustomCategoryContainer(
                    icon: Icons.account_balance_wallet,
                    text: 'KAS',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KasPage()),
                      );
                    },
                  ),
                  if(jabatan == "Sekretaris")
                  CustomCategoryContainer(
                    icon: Icons.event,
                    text: 'Kegiatan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KegiatanPage()),
                      );
                    },
                  ),
                  if(jabatan == "Ketua RT")
                  CustomCategoryContainer(
                    icon: Icons.person,
                    text: 'Pengurus',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PengurusPage()),
                      );
                    },
                  ),
                  if(jabatan == "Ketua RT")
                  CustomCategoryContainer(
                    icon: Icons.home,
                    text: 'Fasilitas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FasilitasPage()),
                      );
                    },
                  ),
                  if(jabatan == "Sekretaris")
                  CustomCategoryContainer(
                    icon: Icons.calendar_month,
                    text: 'RKB',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                KegiatanBulananPage()),
                      );
                    },
                  ),
                  if(jabatan == "Sekretaris")
                  CustomCategoryContainer(
                    icon: Icons.notifications_active_sharp,
                    text: 'Pemberitahuan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PemberitahuanPage()),
                      );
                    },
                  ),
                  if(jabatan == "Sekretaris")
                  CustomCategoryContainer(
                    icon: Icons.person_add,
                    text: 'Pendaftaran',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PendaftaranPage()),
                      );
                    },
                  ),
                  CustomCategoryContainer(
                    icon: Icons.logout,
                    text: 'Logout',
                    onTap: () => _logout(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
