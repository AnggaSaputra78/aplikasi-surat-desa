import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = "http://10.0.2.2:3000"; // kalau Android Emulator
  static const String baseUrl = "http://localhost:3000"; // kalau web / desktop
  // static const String baseUrl = "http://192.168.x.x:3000"; // kalau device fisik

  static Future<void> tambahSurat(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/surat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal simpan: ${response.body}");
    }
  }

  static Future<List<dynamic>> getSurat({String? jenis}) async {
    final uri = jenis != null
        ? Uri.parse("$baseUrl/surat?jenis=$jenis")
        : Uri.parse("$baseUrl/surat");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal ambil data: ${response.body}");
    }
  }
}
