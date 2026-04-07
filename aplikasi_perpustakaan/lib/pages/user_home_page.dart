import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  final String nama;
  const UserHomePage({super.key, required this.nama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perpustakaan')),
      body: Center(
        child: Text(
          'Selamat datang, $nama',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
