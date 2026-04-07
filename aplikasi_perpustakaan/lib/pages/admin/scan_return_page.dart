import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanReturnPage extends StatefulWidget {

  const ScanReturnPage({super.key});

  @override
  State<ScanReturnPage> createState() => _ScanReturnPageState();

}

class _ScanReturnPageState extends State<ScanReturnPage> {

  bool processing = false;

  void _onDetect(barcodeCapture){

    if(processing) return;

    final barcode = barcodeCapture.barcodes.first.rawValue;

    if(barcode == null) return;

    setState(()=>processing = true);

    final int bookId = int.tryParse(barcode) ?? 0;

    if(bookId == 0){

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Barcode tidak valid")));

      setState(()=>processing = false);

      return;

    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Buku berhasil dikembalikan")));

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: const Text('Scan Pengembalian')),

      body: MobileScanner(
        onDetect: _onDetect,
      ),

    );

  }

}