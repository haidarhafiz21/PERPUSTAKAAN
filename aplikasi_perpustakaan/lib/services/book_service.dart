import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class BookService {
  static Future<List> getDigitalBooks() async {
    final res = await http.get(
      Uri.parse(ApiConfig.digitalBooks),
    );
    return jsonDecode(res.body);
  }

  static Future<List> getRecommended(String role) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.recommendedBooks}?role=$role"),
    );
    return jsonDecode(res.body);
  }

  static Future<List> getBooksByRack(String rak, String role) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.booksByRack}?rak=$rak&role=$role"),
    );
    return jsonDecode(res.body);
  }
}