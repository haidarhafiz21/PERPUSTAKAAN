import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';
import 'booking_detail_page.dart';

class SelectMemberPage extends StatefulWidget {
  final String type; // borrow / return

  const SelectMemberPage({
    super.key,
    required this.type,
  });

  @override
  State<SelectMemberPage> createState() => _SelectMemberPageState();
}

class _SelectMemberPageState extends State<SelectMemberPage> {
  final searchController = TextEditingController();

  List members = [];
  List filteredMembers = [];

  bool loading = true;

  String adminFoto = "";
  int adminId = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadAdmin();
    await loadMembers();
  }

  Future<void> loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    adminFoto = prefs.getString("foto_wajah") ?? "";
    adminId = prefs.getInt("user_id") ?? 0;

    print("ADMIN ID: $adminId");
  }

  Future<void> loadMembers() async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.members));
      final data = jsonDecode(res.body);

      setState(() {
        members = data;
        filteredMembers = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void searchMember(String text) {
    final results = members.where((m) {
      final nama = m['nama_lengkap'].toString().toLowerCase();
      return nama.contains(text.toLowerCase());
    }).toList();

    setState(() => filteredMembers = results);
  }

  void pilihMember(Map member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailPage(
          userId: member["id"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Anggota"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchMember,
                    decoration: const InputDecoration(
                      hintText: "Cari anggota...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.person),
                          ),
                          title: Text(member["nama_lengkap"]),
                          subtitle: Text(member["email"]),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => pilihMember(member),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}