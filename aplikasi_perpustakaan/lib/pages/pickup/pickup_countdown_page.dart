import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickupCountdownPage extends StatefulWidget {
  final int userId;

  const PickupCountdownPage({
    super.key,
    required this.userId,
  });

  @override
  State<PickupCountdownPage> createState() => _PickupCountdownPageState();
}

class _PickupCountdownPageState extends State<PickupCountdownPage> {
  Timer? timer;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    loadDeadline();
  }

  Future<void> loadDeadline() async {
    final prefs = await SharedPreferences.getInstance();
    final deadlineMillis = prefs.getInt('borrow_pickup_deadline');

    if (deadlineMillis == null) return;

    final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMillis);

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = deadline.difference(now);

      setState(() {
        remaining = diff.isNegative ? Duration.zero : diff;
      });

      if (diff.isNegative) {
        timer?.cancel();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Waktu pengambilan habis")),
        );

        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return Scaffold(
      appBar: AppBar(title: const Text("Waktu Pengambilan Buku")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Silakan ambil buku sebelum waktu habis",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "$minutes:${seconds.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}