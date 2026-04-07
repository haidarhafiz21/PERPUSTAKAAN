import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'borrow_success_page.dart';

class ScanBorrowPage extends StatefulWidget {
  final int userId; // ID MEMBER (BUKAN ADMIN)

  const ScanBorrowPage({super.key, required this.userId});

  @override
  State<ScanBorrowPage> createState() => _ScanBorrowPageState();
}

class _ScanBorrowPageState extends State<ScanBorrowPage> {
  bool processing = false;
  final MobileScannerController controller = MobileScannerController();

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (processing) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    print("BARCODE TERBACA: $barcode");

    final int bookId = int.tryParse(barcode) ?? 0;

    if (bookId == 0) {
      _error('Barcode tidak valid');
      return;
    }

    setState(() => processing = true);
    controller.stop();

    try {
      final res = await http.post(
        Uri.parse(ApiConfig.scanBorrow),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "book_id": bookId
        }),
      );

      final data = jsonDecode(res.body);

      print("RESPON SCAN: $data");

      if (!mounted) return;

      if (data["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BorrowSuccessPage(
              nama: data["nama"] ?? "-",
              judulBuku: data["judul"] ?? "-",
              tanggalKembali: data["tanggal_kembali"] ?? "-",
            ),
          ),
        );
      } else {
        _error(data["message"]);
        setState(() => processing = false);
        controller.start();
      }
    } catch (e) {
      print("ERROR SCAN API: $e");
      _error("Gagal scan buku");
      setState(() => processing = false);
      controller.start();
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Buku')),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
      ),
    );
  }
}