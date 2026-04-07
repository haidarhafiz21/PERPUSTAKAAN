import 'package:flutter/material.dart';

class PengembalianPage extends StatelessWidget {
  const PengembalianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Silakan serahkan buku ke petugas\nuntuk proses pengembalian',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
