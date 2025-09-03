import 'package:flutter/material.dart';

class DetailSuratPage extends StatelessWidget {
  final Map<String, dynamic> surat;

  const DetailSuratPage({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Surat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jenis: ${surat['jenis']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Nomor: ${surat['nomor']}"),
            Text("Perihal: ${surat['perihal']}"),
            Text("Tanggal: ${surat['tanggal']}"),
            const Divider(),
            Text("Pengirim: ${surat['pengirim']}"),
            Text("Penerima: ${surat['penerima']}"),
            const SizedBox(height: 16),
            Text("Isi Surat:", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(surat['isi']),
          ],
        ),
      ),
    );
  }
}
