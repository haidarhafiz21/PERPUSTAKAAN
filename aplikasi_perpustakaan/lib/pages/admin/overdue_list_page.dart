import 'package:flutter/material.dart';

class OverdueListPage extends StatelessWidget {
  const OverdueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peminjaman Terlambat')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Fajar Rahman'),
            subtitle: Text('Terlambat 3 hari'),
            trailing: Icon(Icons.warning, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
