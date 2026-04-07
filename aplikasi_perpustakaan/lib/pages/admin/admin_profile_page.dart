import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';

class AdminProfilePage extends StatefulWidget {
  final String nama;
  final String fotoWajah;

  const AdminProfilePage({
    super.key,
    required this.nama,
    required this.fotoWajah,
  });

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final picker = ImagePicker();
  String foto = "";

  @override
  void initState() {
    super.initState();
    foto = widget.fotoWajah;
  }

  Future<void> ambilFoto() async {
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('foto_wajah', base64Image);

    setState(() {
      foto = base64Image;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),

      /// APPBAR HIJAU
      appBar: AppBar(
        backgroundColor: const Color(0xff355f57),
        title: const Text("Profil Admin"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 30),

          /// FOTO PROFIL
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundImage:
                  foto.isNotEmpty ? MemoryImage(base64Decode(foto)) : null,
              child: foto.isEmpty
                  ? const Icon(Icons.person, size: 70)
                  : null,
            ),
          ),

          const SizedBox(height: 20),

          /// NAMA ADMIN
          Center(
            child: Text(
              widget.nama,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 40),

          /// UPDATE FOTO
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              "Update Foto Wajah",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff355f57),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: ambilFoto,
          ),

          const SizedBox(height: 20),

          /// LOGOUT
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: logout,
          ),
        ],
      ),
    );
  }
}