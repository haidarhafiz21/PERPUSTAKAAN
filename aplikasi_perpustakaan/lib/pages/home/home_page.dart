import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import '../books/books_by_rak_page.dart';
import '../borrow/face_verification_page.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String role;
  final String nama;
  final String fotoWajah;

  const HomePage({
    super.key,
    required this.userId,
    required this.role,
    required this.nama,
    required this.fotoWajah,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List recommendedBooks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRecommended();
  }

  Future<void> loadRecommended() async {
    final data = await BookService.getRecommended(widget.role);

    if (!mounted) return;

    setState(() {
      recommendedBooks = data;
      loading = false;
    });
  }

  Widget rakItem(String namaRak, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BooksByRakPage(
              rak: namaRak,
              userId: widget.userId,
              role: widget.role,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                namaRak,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rekomendasiCard(book) {
    final isDigital = book['is_digital'] == true;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: const Center(
              child: Icon(Icons.book, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  book['judul'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  book['penulis'] ?? "-",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDigital ? Colors.green : Colors.red,
                    minimumSize: const Size(double.infinity, 35),
                  ),
                  onPressed: () {
                    if (isDigital) {
                      // buka buku digital
                      Navigator.pushNamed(context, '/read',
                          arguments: book['id']);
                    } else {
                      // pinjam buku fisik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FaceVerificationPage(
                            userId: widget.userId,
                            role: widget.role,
                            bookId: book['id'],
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(isDigital ? "Baca" : "Pinjam"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: widget.fotoWajah.isNotEmpty
                        ? MemoryImage(base64Decode(widget.fotoWajah))
                        : null,
                    child: widget.fotoWajah.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Selamat Datang\n${widget.nama}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.account_balance_wallet),
                  const SizedBox(width: 15),
                  const Icon(Icons.notifications),
                ],
              ),

              const SizedBox(height: 20),

              /// REKOMENDASI
              const Text(
                "Rekomendasi Buku",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 230,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: recommendedBooks
                            .map((b) => rekomendasiCard(b))
                            .toList(),
                      ),
              ),

              const SizedBox(height: 20),

              /// RAK BUKU
              const Text(
                "Rak Buku",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: [
                  rakItem("Hukum Pidana", Icons.gavel),
                  rakItem("Hukum Perdata", Icons.balance),
                  rakItem("Kriminologi", Icons.search),
                  rakItem("Peraturan Kejaksaan", Icons.description),
                  rakItem("Administrasi", Icons.account_balance),
                  rakItem("Buku Umum", Icons.book),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}