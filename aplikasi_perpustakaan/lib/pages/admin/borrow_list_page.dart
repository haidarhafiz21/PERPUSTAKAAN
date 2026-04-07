import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class BorrowListPage extends StatefulWidget {
  final String type;

  const BorrowListPage({super.key, required this.type});

  @override
  State<BorrowListPage> createState() => _BorrowListPageState();
}

class _BorrowListPageState extends State<BorrowListPage> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    String url = widget.type == "active"
        ? "${ApiConfig.baseUrl}/borrows/active-list"
        : "${ApiConfig.baseUrl}/borrows/late-list";

    final res = await http.get(Uri.parse(url));
    final json = jsonDecode(res.body);

    setState(() {
      data = json;
      loading = false;
    });
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    DateTime dt = DateTime.parse(date);
    return DateFormat("dd MMM yyyy").format(dt);
  }

  Color statusColor() {
    return widget.type == "active" ? Colors.green : Colors.red;
  }

  String statusText() {
    return widget.type == "active"
        ? "Sedang Dipinjam"
        : "Terlambat";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == "active"
            ? "Peminjaman Aktif"
            : "Peminjaman Terlambat"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Tidak ada data"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final d = data[i];

                    return Card(
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: statusColor(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.book,
                                  color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['nama_lengkap'] ?? "-",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text("Buku: ${d['judul']}"),
                                  const SizedBox(height: 4),
                                  Text(
                                    statusText(),
                                    style: TextStyle(
                                      color: statusColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Pinjam : ${formatDate(d['tanggal_pinjam'])}"),
                                  Text(
                                      "Kembali : ${formatDate(d['tanggal_kembali'])}"),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}