import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../services/db_service.dart';
import '../widgets/letter_card.dart';
import 'add_letter_screen.dart';
import 'detail_letter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Letter> letters = [];

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  void _loadLetters() async {
    final data = await DBService.getLetters();
    setState(() => letters = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Surat Desa')),
      body: letters.isEmpty
          ? Center(child: Text('Belum ada surat'))
          : ListView.builder(
              itemCount: letters.length,
              itemBuilder: (context, i) {
                return LetterCard(
                  letter: letters[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailLetterScreen(letter: letters[i]),
                    ),
                  ).then((_) => _loadLetters()),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddLetterScreen()),
          );
          _loadLetters();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
