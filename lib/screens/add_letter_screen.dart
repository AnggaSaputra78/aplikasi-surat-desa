import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../services/db_service.dart';

class AddLetterScreen extends StatefulWidget {
  const AddLetterScreen({super.key});

  @override
  _AddLetterScreenState createState() => _AddLetterScreenState();
}

class _AddLetterScreenState extends State<AddLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController noCtrl = TextEditingController();
  final TextEditingController dariCtrl = TextEditingController();
  final TextEditingController perihalCtrl = TextEditingController();
  final TextEditingController tglCtrl = TextEditingController();
  String type = 'Masuk';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Surat')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: "Jenis Surat"),
                items: ['Masuk', 'Keluar']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => type = v ?? 'Masuk'),
              ),
              TextFormField(
                controller: noCtrl,
                decoration: const InputDecoration(labelText: 'Nomor Surat'),
                validator: (val) =>
                    val == null || val.isEmpty ? "Nomor surat wajib diisi" : null,
              ),
              TextFormField(
                controller: dariCtrl,
                decoration: const InputDecoration(labelText: 'Dari/Kepada'),
                validator: (val) =>
                    val == null || val.isEmpty ? "Dari/Kepada wajib diisi" : null,
              ),
              TextFormField(
                controller: perihalCtrl,
                decoration: const InputDecoration(labelText: 'Perihal'),
                validator: (val) =>
                    val == null || val.isEmpty ? "Perihal wajib diisi" : null,
              ),
              TextFormField(
                controller: tglCtrl,
                decoration: const InputDecoration(labelText: 'Tanggal'),
                validator: (val) =>
                    val == null || val.isEmpty ? "Tanggal wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final letter = Letter(
                      type: type,
                      noSurat: noCtrl.text.trim(),
                      dariAtauKepada: dariCtrl.text.trim(),
                      perihal: perihalCtrl.text.trim(),
                      tanggal: tglCtrl.text.trim(),
                    );
                    await DBService.insertLetter(letter);

                    // kasih feedback sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Surat berhasil disimpan")),
                    );

                    // kirim "true" biar tidak null
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
