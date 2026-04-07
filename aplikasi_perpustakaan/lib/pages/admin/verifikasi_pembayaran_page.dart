import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class VerifikasiPembayaranPage extends StatefulWidget {
  const VerifikasiPembayaranPage({super.key});

  @override
  State<VerifikasiPembayaranPage> createState() =>
      _VerifikasiPembayaranPageState();
}

class _VerifikasiPembayaranPageState
    extends State<VerifikasiPembayaranPage> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/borrows/denda-list"),
      );

      final json = jsonDecode(res.body);

      setState(() {
        data = json;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> bayar(int id, int jumlah) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/borrows/bayar-offline"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "peminjaman_id": id,
        "jumlah": jumlah,
      }),
    );

    final json = jsonDecode(res.body);

    if (json["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pembayaran berhasil")),
      );
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Pembayaran Denda")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Tidak ada denda"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final d = data[i];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(d['nama_lengkap']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Buku: ${d['judul']}"),
                            Text("Denda: Rp ${d['denda']}"),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => bayar(d['id'], d['denda']),
                          child: const Text("Bayar"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}