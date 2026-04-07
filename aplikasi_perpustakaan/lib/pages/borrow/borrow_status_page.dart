import 'package:flutter/material.dart';
import '../../services/borrow_service.dart';

class BorrowStatusPage extends StatefulWidget {
  final int userId;

  const BorrowStatusPage({super.key, required this.userId});

  @override
  State<BorrowStatusPage> createState() => _BorrowStatusPageState();
}

class _BorrowStatusPageState extends State<BorrowStatusPage> {
  List<dynamic> borrows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await BorrowService.getActiveBorrow(widget.userId);

    if (!mounted) return;

    setState(() {
      borrows = data;
      loading = false;
    });
  }

  /// FORMAT TANGGAL INDONESIA
  String formatTanggal(String? tanggal) {
    if (tanggal == null) return "-";

    try {
      DateTime dt = DateTime.parse(tanggal).toLocal();

      List<String> bulan = [
        "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
        "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
      ];

      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return tanggal;
    }
  }

  /// HITUNG TERLAMBAT
  String hitungTerlambat(String? kembali, String status) {
    if (kembali == null) return "-";
    if (status != "terlambat") return "-";

    try {
      DateTime tglKembali = DateTime.parse(kembali);
      DateTime sekarang = DateTime.now();

      int selisih = sekarang.difference(tglKembali).inDays;

      if (selisih <= 0) return "-";

      return "$selisih hari";
    } catch (e) {
      return "-";
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'booking':
        return Colors.orange;
      case 'dipinjam':
        return Colors.green;
      case 'terlambat':
        return Colors.red;
      case 'dikembalikan':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'booking':
        return "Menunggu Diambil";
      case 'dipinjam':
        return "Sedang Dipinjam";
      case 'terlambat':
        return "Terlambat";
      case 'dikembalikan':
        return "Dikembalikan";
      default:
        return status;
    }
  }

  String formatDenda(dynamic denda) {
    if (denda == null) return "-";
    if (denda == 0) return "-";
    return "Rp $denda";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Peminjaman"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : borrows.isEmpty
              ? const Center(child: Text("Tidak ada peminjaman"))
              : ListView.builder(
                  itemCount: borrows.length,
                  itemBuilder: (context, i) {
                    final b = borrows[i];

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
                                color: statusColor(b['status']),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.book, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b['judul'] ?? "-",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    statusText(b['status']),
                                    style: TextStyle(
                                      color: statusColor(b['status']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Pinjam : ${formatTanggal(b['tanggal_pinjam'])}"),
                                  Text("Kembali : ${formatTanggal(b['tanggal_kembali'])}"),
                                  Text("Terlambat : ${hitungTerlambat(b['tanggal_kembali'], b['status'])}"),
                                  Text("Denda : ${formatDenda(b['denda'])}"),
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