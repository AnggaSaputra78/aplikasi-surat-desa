class Surat {
  final String id;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final bool isMasuk; // true = surat masuk, false = surat keluar

  Surat({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.isMasuk,
  });
}
