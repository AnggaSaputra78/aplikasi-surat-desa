import 'package:flutter/material.dart';
import '../models/letter.dart';

class LetterCard extends StatelessWidget {
  final Letter letter;
  final VoidCallback? onTap;

  const LetterCard({super.key, required this.letter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          letter.type == 'Masuk' ? Icons.mail : Icons.send,
          color: letter.type == 'Masuk' ? Colors.blue : Colors.red,
        ),
        title: Text('${letter.noSurat} - ${letter.perihal}'),
        subtitle: Text('${letter.dariAtauKepada} (${letter.tanggal})'),
        onTap: onTap,
      ),
    );
  }
}
