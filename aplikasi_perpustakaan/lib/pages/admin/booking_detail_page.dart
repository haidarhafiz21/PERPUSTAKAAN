import 'package:flutter/material.dart';
import '../../services/borrow_service.dart';
import '../borrow/face_verification_page.dart';

class BookingDetailPage extends StatefulWidget {
  final int userId;

  const BookingDetailPage({super.key, required this.userId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  Map<String, dynamic>? booking;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    final data = await BorrowService.getUserBooking(widget.userId);

    if (!mounted) return;

    setState(() {
      booking = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking User")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? const Center(child: Text("Tidak ada booking aktif"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "BARCODE: ${booking!["buku_id"]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Icon(Icons.book, size: 80),
                          const SizedBox(height: 20),
                          Text(
                            booking!["judul"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Batas Ambil:\n${booking!["batas_ambil"]}",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.face),
                            label: const Text("Verifikasi & Scan Buku"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FaceVerificationPage(
                                    userId: widget.userId,
                                    bookId: booking!["buku_id"],
                                    role: "admin_mobile",
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}