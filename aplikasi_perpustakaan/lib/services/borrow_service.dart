import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class BorrowService {

  /// ================= REGISTER =================
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String alamat,
    required String email,
    required String password,
    required String foto,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama_lengkap": nama,
          "alamat": alamat,
          "email": email,
          "password": password,
          "foto_wajah": foto,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Koneksi ke server gagal"
      };
    }
  }

  /// ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Koneksi ke server gagal"
      };
    }
  }

  /// ================= BOOKING USER =================
  static Future<Map<String, dynamic>> booking({
    required int userId,
    required int bookId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.booking),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "book_id": bookId,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Booking gagal"
      };
    }
  }

  /// ================= SCAN ADMIN =================
  static Future<Map<String, dynamic>> scanBorrow({
    required int userId,
    required int bookId,
    String fotoScan = "",
    String fotoLive = "",
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.scanBorrow),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "book_id": bookId,
          "foto_scan": fotoScan,
          "foto_live": fotoLive
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Scan buku gagal"
      };
    }
  }

  /// ================= RETURN =================
  static Future<Map<String, dynamic>> returnBook({
    required int bookId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.returnBook),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "book_id": bookId,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Return gagal"
      };
    }
  }

  /// ================= STATUS AKTIF =================
  static Future<List<dynamic>> getActiveBorrow(int userId) async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.activeBorrows}?user_id=$userId"),
      );

      if (res.body == "null") return [];

      final data = jsonDecode(res.body);

      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic>) {
        return [data];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// ================= RIWAYAT USER =================
  static Future<List> getUserBorrows(int userId) async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.userBorrows}/$userId"),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }

  /// ================= ADMIN: BOOKING USER =================
  static Future<Map<String, dynamic>?> getUserBooking(int userId) async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.userBooking}/$userId"),
      );

      if (res.body == "null") return null;

      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  /// ================= ADMIN: SEMUA PEMINJAMAN =================
  static Future<List> getAllBorrows() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.allBorrows),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }

  /// ================= ADMIN: LIST MEMBER =================
  static Future<List> getMembers() async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.members));
      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }
}