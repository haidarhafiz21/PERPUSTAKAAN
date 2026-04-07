import 'package:flutter/material.dart';
import '../../services/borrow_service.dart';

class RiwayatPage extends StatefulWidget {
  final int userId;

  const RiwayatPage({super.key, required this.userId});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await BorrowService.getUserBorrows(widget.userId);

    setState(() {
      data = result.where((e) => e['status'] == 'dikembalikan').toList();
      loading = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'dikembalikan':
        return Colors.blue;
      case 'terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Belum ada riwayat"))
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final item = data[i];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(item['judul'] ?? "-"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${item['status']}"),
                              Text("Pinjam: ${item['tanggal_pinjam'] ?? '-'}"),
                              Text("Kembali: ${item['tanggal_kembali'] ?? '-'}"),
                              Text("Denda: Rp ${item['denda'] ?? 0}"),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: statusColor(item['status']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['status'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}