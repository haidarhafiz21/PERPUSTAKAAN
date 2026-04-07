import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  File? imageFile;
  String? fotoBase64;

  final ImagePicker picker = ImagePicker();

  // =============================
  // AMBIL FOTO
  // =============================
  Future<void> ambilFoto() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        setState(() {
          imageFile = File(image.path);
          fotoBase64 = base64Encode(bytes);
        });

        print("FOTO BERHASIL DIAMBIL");
      } else {
        print("User batal ambil foto");
      }
    } catch (e) {
      print("ERROR CAMERA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka kamera")),
      );
    }
  }

  // =============================
  // REGISTER
  // =============================
  Future<void> register() async {

    print("TOMBOL DAFTAR DITEKAN");

    if (namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        fotoBase64 == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi")),
      );
      return;
    }

    try {

      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama": namaController.text,
          "alamat": alamatController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "foto": fotoBase64,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Registrasi gagal")),
        );
      }

    } catch (e) {
      print("REGISTER ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak dapat terhubung ke server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // FOTO
            Center(
              child: GestureDetector(
                onTap: ambilFoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      imageFile != null ? FileImage(imageFile!) : null,
                  child: imageFile == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),

            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: "Alamat"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: register,
              child: const Text("Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}
 