import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BuatSuratPage extends StatefulWidget {
  // Tambahkan parameter callback untuk mengembalikan data
  final Function(Map<String, dynamic>)? onSuratCreated;
  
  const BuatSuratPage({super.key, this.onSuratCreated});

  @override
  State<BuatSuratPage> createState() => _BuatSuratPageState();
}

class _BuatSuratPageState extends State<BuatSuratPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomorController = TextEditingController();
  final _perihalController = TextEditingController();
  final _pengirimController = TextEditingController();
  final _penerimaController = TextEditingController();
  final _isiController = TextEditingController();

  String? _jenisSurat;
  DateTime? _tanggalSurat;

  bool _isLoading = false;

  Future<void> simpanSurat() async {
    if (!_formKey.currentState!.validate() ||
        _jenisSurat == null ||
        _tanggalSurat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Harap lengkapi semua data")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final suratBaru = {
        "jenis": _jenisSurat,
        "nomor": _nomorController.text,
        "perihal": _perihalController.text,
        "tanggal": _tanggalSurat!.toIso8601String(),
        "pengirim": _pengirimController.text,
        "penerima": _penerimaController.text,
        "isi": _isiController.text,
      };

      await ApiService.tambahSurat(suratBaru);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Surat berhasil disimpan")),
      );

      // Panggil callback jika ada
      if (widget.onSuratCreated != null) {
        widget.onSuratCreated!(suratBaru);
      }
      
      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Gagal menyimpan surat: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalSurat = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Surat Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _jenisSurat,
                  items: const [
                    DropdownMenuItem(value: "Masuk", child: Text("Surat Masuk")),
                    DropdownMenuItem(value: "Keluar", child: Text("Surat Keluar")),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Jenis Surat",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() => _jenisSurat = value);
                  },
                  validator: (value) =>
                      value == null ? "Jenis surat harus dipilih" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nomorController,
                  decoration: const InputDecoration(
                    labelText: "Nomor Surat",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Nomor surat wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _perihalController,
                  decoration: const InputDecoration(
                    labelText: "Perihal",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Perihal wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tanggalSurat == null
                            ? "Pilih tanggal surat"
                            : "Tanggal: ${_tanggalSurat!.toLocal()}".split(" ")[0],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: pilihTanggal,
                      child: const Text("Pilih Tanggal"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _pengirimController,
                  decoration: const InputDecoration(
                    labelText: "Pengirim",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Pengirim wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _penerimaController,
                  decoration: const InputDecoration(
                    labelText: "Penerima",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Penerima wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _isiController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Isi Surat",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Isi surat wajib diisi" : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : simpanSurat,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Simpan"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}