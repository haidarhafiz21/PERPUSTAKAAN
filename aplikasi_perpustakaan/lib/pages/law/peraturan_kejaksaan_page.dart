import 'package:flutter/material.dart';

class PeraturanKejaksaanPage extends StatelessWidget {
  const PeraturanKejaksaanPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<String> peraturan = [

      "Peraturan Jaksa Agung No 1 Tahun 2021",
      "Peraturan Jaksa Agung No 15 Tahun 2020",
      "Peraturan Jaksa Agung No 28 Tahun 2014",
      "Peraturan Jaksa Agung No 6 Tahun 2019",
      "Peraturan Jaksa Agung No 17 Tahun 2014"

    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Peraturan Kejaksaan"),
      ),

      body: ListView.builder(

        itemCount: peraturan.length,

        itemBuilder: (context, index) {

          return Card(

            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            child: ListTile(

              leading: const Icon(
                Icons.description,
                color: Colors.red,
              ),

              title: Text(peraturan[index]),

            ),

          );

        },

      ),

    );

  }

}