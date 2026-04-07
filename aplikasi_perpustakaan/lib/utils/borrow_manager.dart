import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BorrowManager {
  static final BorrowManager _instance = BorrowManager._internal();
  factory BorrowManager() => _instance;
  BorrowManager._internal();

  Timer? _timer;
  OverlayEntry? _overlay;

  void start(BuildContext context) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _check(context);
    });
  }

  Future<void> _check(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final endTime = prefs.getInt('borrow_end_time');
    final book = prefs.getString('borrow_book');

    if (endTime == null || book == null) {
      _remove();
      return;
    }

    final diff =
        DateTime.fromMillisecondsSinceEpoch(endTime).difference(DateTime.now());

    if (diff.isNegative) {
      await prefs.remove('borrow_end_time');
      await prefs.remove('borrow_book');
      _remove();
      return;
    }

    _show(context, book, diff);
  }

  void _show(BuildContext context, String book, Duration d) {
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.orange.shade100,
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: Text('Segera ambil buku'),
            subtitle: Text(
              '$book • ${_fmt(d)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  void _remove() {
    _overlay?.remove();
    _overlay = null;
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
