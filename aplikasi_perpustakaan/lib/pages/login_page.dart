import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/borrow_service.dart';
import 'main_navigation.dart';
import 'admin/main_admin_page.dart'; // UBAH KE MAIN ADMIN
import 'auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    final res = await BorrowService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (res['success'] == true) {
      final user = res['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id']);
      await prefs.setString('nama', user['nama']);
      await prefs.setString('role', user['role']);
      await prefs.setString('foto_wajah', user['foto_wajah'] ?? "");

      /// JIKA ADMIN / PEGAWAI
      if (user['role'] == 'admin_mobile' || user['role'] == 'pegawai') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainAdminPage(
              nama: user['nama'],
              userId: user['id'],
              fotoWajah: user['foto_wajah'] ?? "",
            ),
          ),
        );
      } 
      /// JIKA MEMBER / PUBLIK
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(
              userId: user['id'],
              nama: user['nama'],
              role: user['role'],
              fotoWajah: user['foto_wajah'] ?? "",
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Login gagal")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Perpustakaan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              child: const Text("Belum punya akun? Register"),
            )
          ],
        ),
      ),
    );
  }
}