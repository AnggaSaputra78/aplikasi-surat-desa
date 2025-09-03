import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuratMasukPage extends StatefulWidget {
  const SuratMasukPage({super.key});

  @override
  _SuratMasukPageState createState() => _SuratMasukPageState();
}

class _SuratMasukPageState extends State<SuratMasukPage> {
  List<dynamic> surat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurat();
  }

  void _loadSurat() async {
    try {
      final data = await ApiService.getSurat();
      setState(() {
        surat = data.where((s) => s["jenis"] == "Masuk").toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat surat: $e")),
      );
    }
  }

  // Navigasi ke halaman buat surat
  void _navigateToBuatSurat() async {
    // Navigasi ke halaman buat surat dan tunggu hasilnya
    final result = await Navigator.pushNamed(context, '/buat-surat');
    
    // Jika ada hasil (surat baru), tambahkan ke daftar
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        surat.add(result);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Surat baru berhasil ditambahkan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surat Masuk"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSurat,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : surat.isEmpty
              ? Center(child: Text("Tidak ada surat masuk"))
              : ListView.builder(
                  itemCount: surat.length,
                  itemBuilder: (context, index) {
                    final item = surat[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(item["perihal"] ?? "Tidak ada perihal"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nomor: ${item["nomor"] ?? "Tidak ada nomor"}"),
                            Text("Tanggal: ${_formatTanggal(item["tanggal"])}"),
                            Text("Pengirim: ${item["pengirim"] ?? "Tidak ada pengirim"}"),
                          ],
                        ),
                        // Hapus tombol delete jika tidak ada fungsi hapus di ApiService
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBuatSurat,
        child: Icon(Icons.add),
        tooltip: 'Buat Surat Baru',
      ),
    );
  }

  // Fungsi untuk memformat tanggal
  String _formatTanggal(String? tanggalString) {
    if (tanggalString == null) return "Tidak ada tanggal";
    
    try {
      final tanggal = DateTime.parse(tanggalString);
      return "${tanggal.day}/${tanggal.month}/${tanggal.year}";
    } catch (e) {
      return "Format tanggal tidak valid";
    }
  }
}