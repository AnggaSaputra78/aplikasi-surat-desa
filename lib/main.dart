import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/surat_masuk.dart';
import 'pages/surat_keluar.dart';
import 'pages/buat_surat.dart';

void main() {
  runApp(const SuratDesaApp());
}

class SuratDesaApp extends StatelessWidget {
  const SuratDesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Surat Desa',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true, // Tambahkan untuk material design 3
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/surat-masuk': (context) => const SuratMasukPage(),
        '/surat-keluar': (context) => const SuratKeluarPage(),
        '/buat-surat': (context) => const BuatSuratPage(),
      },
      // Tambahkan error builder untuk menangani error navigasi
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
      },
      // Debug mode banner
      debugShowCheckedModeBanner: false,
    );
  }
}