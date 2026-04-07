import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import '../borrow/face_verification_page.dart';
import 'book_detail_page.dart';

class BooksByRakPage extends StatefulWidget {
  final String rak;
  final int userId;
  final String role;

  const BooksByRakPage({
    super.key,
    required this.rak,
    required this.userId,
    required this.role,
  });

  @override
  State<BooksByRakPage> createState() => _BooksByRakPageState();
}

class _BooksByRakPageState extends State<BooksByRakPage> {
  List books = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final data = await BookService.getBooksByRack(
      widget.rak,
      widget.role,
    );

    setState(() {
      books = data;
      loading = false;
    });
  }

  Widget bookCard(Map book) {
    final isDigital = book['is_digital'] == true;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
              color: Colors.grey.shade300,
              child: const Icon(Icons.book),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['judul'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(book['penulis'] ?? "-"),
                  const SizedBox(height: 5),
                  Text(
                    book['deskripsi'] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(book: book),
                        ),
                      );
                    },
                    child: const Text(
                      "Baca selengkapnya",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDigital ? Colors.green : Colors.red,
              ),
              onPressed: () {
                if (isDigital) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(book: book),
                    ),
                  );
                } else {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.rak)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text("Tidak ada buku di rak ini"))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, i) {
                    return bookCard(books[i]);
                  },
                ),
    );
  }
}