import 'package:flutter/material.dart';
import '../../services/borrow_service.dart';

class PinjamanPage extends StatefulWidget {
  final int userId;

  const PinjamanPage({super.key, required this.userId});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage> {
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
      data = result.where((e) => e['status'] != 'dikembalikan').toList();
      loading = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'booking':
        return Colors.orange;
      case 'dipinjam':
        return Colors.green;
      case 'terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinjaman Aktif')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Tidak ada pinjaman"))
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