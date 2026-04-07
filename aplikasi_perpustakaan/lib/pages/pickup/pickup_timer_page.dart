import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickupTimerPage extends StatefulWidget {
  final int userId;

  const PickupTimerPage({super.key, required this.userId});

  @override
  State<PickupTimerPage> createState() => _PickupTimerPageState();
}

class _PickupTimerPageState extends State<PickupTimerPage> {
  Timer? timer;
  Duration remaining = const Duration(minutes: 60);

  @override
  void initState() {
    super.initState();
    loadDeadline();
  }

  Future<void> loadDeadline() async {
    final prefs = await SharedPreferences.getInstance();
    final endMillis = prefs.getInt('pickup_deadline');

    if (endMillis == null) {
      setState(() => remaining = const Duration(minutes: 60));
      return;
    }

    final deadline = DateTime.fromMillisecondsSinceEpoch(endMillis);

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = deadline.difference(DateTime.now());

      if (diff.isNegative) {
        timer?.cancel();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Waktu pengambilan habis")),
          );
        }
      } else {
        setState(() => remaining = diff);
      }
    });
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              format(remaining),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Jika waktu habis, booking dibatalkan"),
          ],
        ),
      ),
    );
  }
}