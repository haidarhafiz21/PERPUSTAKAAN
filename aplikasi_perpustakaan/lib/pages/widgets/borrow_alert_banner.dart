import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BorrowAlertBanner extends StatefulWidget {
  final Widget child;
  const BorrowAlertBanner({super.key, required this.child});

  @override
  State<BorrowAlertBanner> createState() => _BorrowAlertBannerState();
}

class _BorrowAlertBannerState extends State<BorrowAlertBanner> {
  Duration? _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final endMillis = prefs.getInt('borrow_pickup_deadline');

    if (endMillis == null) {
      if (mounted) setState(() => _remaining = null);
      return;
    }

    final diff =
        DateTime.fromMillisecondsSinceEpoch(endMillis).difference(DateTime.now());

    if (diff.isNegative) {
      await prefs.remove('borrow_pickup_deadline');
      await prefs.remove('borrow_book');
      if (mounted) setState(() => _remaining = null);
    } else {
      if (mounted) setState(() => _remaining = diff);
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_remaining != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Buku sudah disiapkan, segera ambil (${_format(_remaining!)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
