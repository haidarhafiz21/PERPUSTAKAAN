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
  bool expired = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Future<void> startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final deadlineMillis = prefs.getInt('borrow_pickup_deadline');

    if (deadlineMillis == null) {
      Navigator.pop(context);
      return;
    }

    final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMillis);

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = deadline.difference(now);

      if (diff.isNegative) {
        timer?.cancel();
        setState(() {
          expired = true;
          remaining = Duration.zero;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Waktu pengambilan habis")),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });

      } else {
        setState(() {
          remaining = diff;
        });
      }
    });
  }

  String formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (h > 0) {
      return "$h:$m:$s";
    } else {
      return "$m:$s";
    }
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
        child: expired
            ? const Text(
                "Waktu habis",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Column(
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
                    formatTime(remaining),
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