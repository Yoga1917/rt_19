import 'dart:io';

class Warga {
  final String nama;
  final String nik;
  final String nomorRumah;
  final String alamat;
  final DateTime tanggalLahir;
  final String jenisKelamin;
  final String nomorTelepon;
  final File? foto;

  Warga({
    required this.nama,
    required this.nik,
    required this.nomorRumah,
    required this.alamat,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.nomorTelepon,
    required this.foto,
  });
}
