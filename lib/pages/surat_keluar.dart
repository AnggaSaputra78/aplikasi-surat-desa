import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuratKeluarPage extends StatefulWidget {
  const SuratKeluarPage({super.key});

  @override
  _SuratKeluarPageState createState() => _SuratKeluarPageState();
}

class _SuratKeluarPageState extends State<SuratKeluarPage> {
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
        surat = data.where((s) => s["jenis"] == "Keluar").toList();
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
      // Pastikan hanya menambahkan surat keluar
      if (result["jenis"] == "Keluar") {
        setState(() {
          surat.add(result);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Surat keluar baru berhasil ditambahkan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surat Keluar"),
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
              ? Center(child: Text("Tidak ada surat keluar"))
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
                            Text("Penerima: ${item["penerima"] ?? "Tidak ada penerima"}"),
                            Text("Status: ${_getStatusSurat(item)}"),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Colors.green),
                        onTap: () {
                          // Aksi ketika surat diklik
                          _showDetailSurat(item);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBuatSurat,
        child: Icon(Icons.add),
        tooltip: 'Buat Surat Keluar Baru',
      ),
    );
  }

  // Fungsi untuk memformat tanggal
  String _formatTanggal(String? tanggalString) {
    if (tanggalString == null) return "Tidak ada tanggal";
    
    try {
      final tanggal = DateTime.parse(tanggalString);
      return "${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}";
    } catch (e) {
      return "Format tanggal tidak valid";
    }
  }

  // Fungsi untuk mendapatkan status surat
  String _getStatusSurat(Map<String, dynamic> item) {
    // Anda bisa menambahkan logika status sesuai kebutuhan
    return "Terkirim"; // Contoh sederhana
  }

  // Fungsi untuk menampilkan detail surat
  void _showDetailSurat(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Detail Surat Keluar"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Nomor: ${item["nomor"] ?? "-"}"),
                Text("Perihal: ${item["perihal"] ?? "-"}"),
                Text("Tanggal: ${_formatTanggal(item["tanggal"])}"),
                Text("Penerima: ${item["penerima"] ?? "-"}"),
                Text("Pengirim: ${item["pengirim"] ?? "-"}"),
                SizedBox(height: 10),
                Text("Isi Surat:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(item["isi"] ?? "Tidak ada konten"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Tutup"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}