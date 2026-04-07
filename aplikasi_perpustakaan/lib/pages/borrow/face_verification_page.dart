import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import '../pickup/pickup_countdown_page.dart';
import '../admin/scan_book_page.dart';

class FaceVerificationPage extends StatefulWidget {
  final int userId;
  final int bookId;
  final String role;

  const FaceVerificationPage({
    super.key,
    required this.userId,
    required this.bookId,
    required this.role,
  });

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  final picker = ImagePicker();

  String foto1 = "";
  String foto2 = "";

  bool step1Done = false;
  bool step2Done = false;
  bool loading = false;
  bool pickingImage = false;

  /// ================= AMBIL FOTO 1 =================
  Future<void> ambilFoto1() async {
    if (pickingImage) return;
    pickingImage = true;

    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      foto1 = base64Encode(bytes);
      setState(() => step1Done = true);
    }

    pickingImage = false;
  }

  /// ================= AMBIL FOTO 2 =================
  Future<void> ambilFoto2() async {
    if (pickingImage) return;
    pickingImage = true;

    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      foto2 = base64Encode(bytes);
      setState(() => step2Done = true);
    }

    pickingImage = false;
  }

  /// ================= VERIFIKASI WAJAH =================
  Future<void> verifikasi() async {
    if (!step1Done || !step2Done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data tidak lengkap")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final verify = await http.post(
        Uri.parse(ApiConfig.verifyFace),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "foto_scan": foto1,
          "foto_liveness": foto2
        }),
      );

      final verifyData = jsonDecode(verify.body);

      if (verifyData["match"] == true) {
        /// ================= ADMIN FLOW =================
        if (widget.role == "admin_mobile") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ScanBookPage(userId: widget.userId),
            ),
          );
        }

        /// ================= USER FLOW =================
        else {
          final booking = await http.post(
            Uri.parse(ApiConfig.booking),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "user_id": widget.userId,
              "book_id": widget.bookId
            }),
          );

          final bookingData = jsonDecode(booking.body);

          if (bookingData["success"] == true) {
            final prefs = await SharedPreferences.getInstance();

            final batasAmbil = DateTime.parse(bookingData["batas_ambil"]);

            await prefs.setInt(
              'borrow_pickup_deadline',
              batasAmbil.millisecondsSinceEpoch,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PickupCountdownPage(userId: widget.userId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(bookingData["message"])),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(verifyData["message"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Koneksi error")),
      );
    }

    setState(() => loading = false);
  }

  /// ================= UI STEP =================
  Widget stepCard({
    required String title,
    required String subtitle,
    required bool done,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt, color: Colors.red),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            child: const Text("Ulangi"),
          ),
          const SizedBox(width: 10),
          Icon(
            done ? Icons.check_circle : Icons.circle_outlined,
            color: done ? Colors.green : Colors.grey,
          )
        ],
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Wajah")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.red),
            const SizedBox(height: 10),
            const Text(
              "Verifikasi Identitas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text("Ikuti langkah berikut untuk memastikan keamanan"),
            const SizedBox(height: 20),
            stepCard(
              title: "1. Ambil Foto Normal",
              subtitle: "Hadapkan wajah lurus ke kamera",
              done: step1Done,
              onTap: ambilFoto1,
            ),
            stepCard(
              title: "2. Ambil Foto Kedua",
              subtitle: "Ambil foto saat kepala miring",
              done: step2Done,
              onTap: ambilFoto2,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: loading ? null : verifikasi,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verifikasi Sekarang"),
              ),
            )
          ],
        ),
      ),
    );
  }
}