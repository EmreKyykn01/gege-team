import 'package:flutter/material.dart';

class SavedAddressesView extends StatelessWidget {
  const SavedAddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Kayıtlı Adreslerim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAddressCard("Ev", "Levent Mah. Çiçek Sok. No: 12 D: 4\nBeşiktaş / İstanbul", Icons.home_rounded, true),
          const SizedBox(height: 16),
          _buildAddressCard("İş", "Maslak Mah. Meydan Sok. Plaza Kat: 5\nSarıyer / İstanbul", Icons.work_rounded, false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Yeni adres ekleme formu açılacak
        },
        backgroundColor: const Color(0xFF1A1A1A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Yeni Adres Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAddressCard(String title, String address, IconData icon, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDefault ? const Color(0xFF1DE9B6) : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE0F7FA), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF00BFA5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (isDefault)
                      const Text("Varsayılan", style: TextStyle(color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(address, style: const TextStyle(color: Colors.grey, height: 1.4)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}