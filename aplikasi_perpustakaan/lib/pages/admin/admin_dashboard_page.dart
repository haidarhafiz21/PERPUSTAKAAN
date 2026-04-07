import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'select_member_page.dart';
import 'scan_return_page.dart';
import 'borrow_list_page.dart';
import 'history_pembayaran_page.dart';
import 'verifikasi_pembayaran_page.dart'; // TAMBAHAN

class AdminDashboardPage extends StatefulWidget {
  final String nama;
  final int userId;
  final String fotoWajah;

  const AdminDashboardPage({
    super.key,
    required this.nama,
    required this.userId,
    required this.fotoWajah,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int aktif = 0;
  int terlambat = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/borrows/stats"),
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;

      setState(() {
        aktif = data['aktif'] ?? 0;
        terlambat = data['terlambat'] ?? 0;
      });
    } catch (e) {
      print("Error load stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: const Color(0xff355f57),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.fotoWajah.isNotEmpty
                  ? MemoryImage(base64Decode(widget.fotoWajah))
                  : null,
              child: widget.fotoWajah.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Admin Dashboard",
                    style: TextStyle(fontSize: 16)),
                Text(widget.nama,
                    style: const TextStyle(fontSize: 13))
              ],
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// CARD STATS (BISA DIKLIK)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const BorrowListPage(type: "active"),
                        ),
                      );
                    },
                    child: _statCard(
                      aktif.toString(),
                      "Peminjaman Aktif",
                      Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const BorrowListPage(type: "late"),
                        ),
                      );
                    },
                    child: _statCard(
                      terlambat.toString(),
                      "Peminjaman Terlambat",
                      Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// SCAN PEMINJAMAN
            _menuCard(
              context,
              icon: Icons.qr_code_scanner,
              title: "Scan Peminjaman Buku",
              page: SelectMemberPage(type: "borrow"),
            ),

            const SizedBox(height: 10),

            /// SCAN RETURN
            _menuCard(
              context,
              icon: Icons.assignment_return,
              title: "Scan Pengembalian Buku",
              page: SelectMemberPage(type: "return"),
            ),

            const SizedBox(height: 10),

            /// VERIFIKASI PEMBAYARAN
            _menuCard(
              context,
              icon: Icons.money,
              title: "Verifikasi Pembayaran",
              page: const VerifikasiPembayaranPage(),
            ),

            const SizedBox(height: 10),

            /// HISTORY PEMBAYARAN
            _menuCard(
              context,
              icon: Icons.payment,
              title: "History Pembayaran Denda",
              page: const HistoryPembayaranPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String number, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _menuCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Widget page}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}