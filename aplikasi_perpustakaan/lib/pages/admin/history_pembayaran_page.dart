import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'package:intl/intl.dart';

class HistoryPembayaranPage extends StatefulWidget {
  const HistoryPembayaranPage({super.key});

  @override
  State<HistoryPembayaranPage> createState() => _HistoryPembayaranPageState();
}

class _HistoryPembayaranPageState extends State<HistoryPembayaranPage> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/borrows/history-pembayaran"),
    );

    final json = jsonDecode(res.body);

    setState(() {
      data = json;
      loading = false;
    });
  }

  String formatDate(String date) {
    return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History Pembayaran Denda")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Belum ada pembayaran"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final d = data[i];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.payment, color: Colors.green),
                        title: Text(d['nama_lengkap']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Buku: ${d['judul']}"),
                            Text("Jumlah: Rp ${d['jumlah']}"),
                            Text("Metode: ${d['metode']}"),
                            Text("Tanggal: ${formatDate(d['tanggal'])}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}