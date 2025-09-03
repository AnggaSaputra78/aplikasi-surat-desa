import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../services/db_service.dart';

class DetailLetterScreen extends StatelessWidget {
  final Letter letter;
  const DetailLetterScreen({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Surat')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jenis: ${letter.type}', style: TextStyle(fontSize: 16)),
            Text('No Surat: ${letter.noSurat}', style: TextStyle(fontSize: 16)),
            Text('Dari/Kepada: ${letter.dariAtauKepada}', style: TextStyle(fontSize: 16)),
            Text('Perihal: ${letter.perihal}', style: TextStyle(fontSize: 16)),
            Text('Tanggal: ${letter.tanggal}', style: TextStyle(fontSize: 16)),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                await DBService.deleteLetter(letter.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Hapus Surat'),
            )
          ],
        ),
      ),
    );
  }
}
