import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../config/api_config.dart';

class BookDetailPage extends StatefulWidget {
  final Map book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  String? localPath;
  bool loading = false;

  Future<void> downloadPDF() async {
    setState(() => loading = true);

    try {
      final url = "${ApiConfig.baseUrl}/${widget.book['file_pdf']}";
      final response = await http.get(Uri.parse(url));

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/book.pdf");

      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        localPath = file.path;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['judul']),
      ),
      body: localPath != null
          ? PDFView(filePath: localPath!)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                  child: const Icon(Icons.book, size: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.book['judul'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Penulis: ${widget.book['penulis']}"),
                const SizedBox(height: 20),
                Text(widget.book['deskripsi'] ?? "-"),
                const SizedBox(height: 20),
                if (widget.book['is_digital'] == true)
                  ElevatedButton(
                    onPressed: loading ? null : downloadPDF,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Baca Buku"),
                  )
              ],
            ),
    );
  }
}