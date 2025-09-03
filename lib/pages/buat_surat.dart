import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BuatSuratPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSuratCreated;
  final String? jenisSuratDefault;
  
  const BuatSuratPage({super.key, this.onSuratCreated, this.jenisSuratDefault});

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
  final _lampiranController = TextEditingController();
  final _sifatController = TextEditingController();

  String? _jenisSurat;
  DateTime? _tanggalSurat;
  String? _tempatPembuatan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.jenisSuratDefault != null) {
      _jenisSurat = widget.jenisSuratDefault;
    }
    _tempatPembuatan = "Desa Contoh";
    _sifatController.text = "Biasa";
  }

  Future<void> _exportToWord() async {
    if (!_formKey.currentState!.validate() || _jenisSurat == null || _tanggalSurat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Harap lengkapi semua data sebelum ekspor")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create a simple text document (simulasi dokumen Word)
      final String content = _generateWordContent();
      
      // Get directory for saving
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/surat_${_nomorController.text.replaceAll('/', '_')}.docx';
      final File file = File(path);
      
      // Write content to file
      await file.writeAsString(content);

      // Open the file
      await OpenFile.open(path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Surat berhasil diekspor: $path")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Gagal mengekspor: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateWordContent() {
    return '''
SURAT ${_jenisSurat == 'Masuk' ? 'MASUK' : 'KELUAR'}

Nomor    : ${_nomorController.text}
Lampiran : ${_lampiranController.text.isNotEmpty ? _lampiranController.text : '-'}
Hal         : ${_perihalController.text}
Sifat      : ${_sifatController.text}

Kepada Yth.
${_penerimaController.text}
Di Tempat

Dengan hormat,

${_isiController.text}

${_tempatPembuatan ?? ""}, ${_formatTanggalIndonesia(_tanggalSurat ?? DateTime.now())}

Hormat kami,

${_pengirimController.text}
(_________________________)
NIP/Jabatan
''';
  }

  Future<void> _importFromWord() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        final String content = await file.readAsString();
        
        // Simple parsing dari file teks
        _parseWordContent(content);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Dokumen berhasil diimpor")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Gagal mengimpor: $e")),
      );
    }
  }

  void _parseWordContent(String text) {
    // Simple parsing logic - adjust based on your template
    final lines = text.split('\n');
    
    for (String line in lines) {
      if (line.contains('Nomor') && line.contains(':')) {
        final parts = line.split(':');
        if (parts.length > 1) _nomorController.text = parts[1].trim();
      } else if (line.contains('Hal') && line.contains(':')) {
        final parts = line.split(':');
        if (parts.length > 1) _perihalController.text = parts[1].trim();
      } else if (line.contains('Kepada Yth.')) {
        // Get next line as penerima
        final index = lines.indexOf(line);
        if (index + 1 < lines.length) {
          _penerimaController.text = lines[index + 1].trim();
        }
      } else if (line.contains('Dengan hormat,')) {
        // Get content after this line
        final index = lines.indexOf(line);
        String isi = '';
        for (int i = index + 1; i < lines.length; i++) {
          if (lines[i].contains(_tempatPembuatan ?? "")) break;
          isi += lines[i] + '\n';
        }
        _isiController.text = isi.trim();
      }
    }
  }

  Future<void> simpanSurat() async {
    if (!_formKey.currentState!.validate() || _jenisSurat == null || _tanggalSurat == null) {
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
        "tempat": _tempatPembuatan,
        "sifat": _sifatController.text,
        "lampiran": _lampiranController.text,
      };

      await ApiService.tambahSurat(suratBaru);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Surat berhasil disimpan")),
      );

      if (widget.onSuratCreated != null) {
        widget.onSuratCreated!(suratBaru);
      }
      
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

  String _formatTanggalIndonesia(DateTime tanggal) {
    final List<String> bulan = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    
    return "${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}";
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
      appBar: AppBar(
        title: const Text("Buat Surat"),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importFromWord,
            tooltip: "Impor dari File",
          ),
        ],
      ),
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
                    labelText: "Jenis Surat *",
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
                    labelText: "Nomor Surat *",
                    hintText: "Contoh: 005/DPRD/IX/2023",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Nomor surat wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _perihalController,
                  decoration: const InputDecoration(
                    labelText: "Perihal *",
                    hintText: "Contoh: Undangan Rapat",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Perihal wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _sifatController,
                  decoration: const InputDecoration(
                    labelText: "Sifat Surat",
                    hintText: "Contoh: Penting, Rahasia, Biasa",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lampiranController,
                  decoration: const InputDecoration(
                    labelText: "Lampiran",
                    hintText: "Contoh: 1 (satu) berkas",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: _tempatPembuatan,
                  decoration: const InputDecoration(
                    labelText: "Tempat Pembuatan",
                    hintText: "Contoh: Desa Mekarjaya",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _tempatPembuatan = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tanggalSurat == null
                            ? "Pilih tanggal surat *"
                            : "Tanggal: ${_formatTanggalIndonesia(_tanggalSurat!)}",
                        style: TextStyle(
                          color: _tanggalSurat == null ? Colors.red : Colors.black,
                        ),
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
                    labelText: "Pengirim/Instansi *",
                    hintText: "Contoh: Kantor Desa Mekarjaya",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Pengirim wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _penerimaController,
                  decoration: const InputDecoration(
                    labelText: "Penerima/Instansi *",
                    hintText: "Contoh: PT. Contoh Indonesia",
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
                    labelText: "Isi Pokok Surat *",
                    hintText: "Tuliskan inti dari surat yang akan dikirim...",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Isi surat wajib diisi" : null,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _exportToWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Ekspor ke File", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : simpanSurat,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Simpan ke Sistem"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}